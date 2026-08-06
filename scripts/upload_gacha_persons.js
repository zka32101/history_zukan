/**
 * ============================================================================
 * Firestore Gacha Masters Upload Script
 * ============================================================================
 *
 * Purpose:
 *   - Load gacha_master.json (300 historical persons)
 *   - Upload each person to Firestore gacha_persons collection
 *   - Batch processing with progress output every 10 records
 *   - Error handling: skip failed records and continue
 *   - Firebase project: petit-works-education
 *
 * Prerequisites:
 *   1. Install dependencies:
 *      $ npm install firebase-admin dotenv
 *
 *   2. Set up Firebase credentials:
 *      - Download JSON service account key from Firebase Console
 *      - Place at: ./service-account-key.json
 *      - OR set GOOGLE_APPLICATION_CREDENTIALS environment variable
 *
 * Usage:
 *   $ node upload_gacha_persons.js
 *
 * Environment Variables:
 *   GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json (optional)
 *   FIREBASE_PROJECT_ID=petit-works-education (optional, set in script below)
 *
 * Output:
 *   - Progress: "Uploaded 10 / 300 persons..."
 *   - Summary: "✓ Successfully uploaded all 300 persons to Firestore"
 *   - Errors: "✗ Failed to upload person_xxx: <error message>"
 *
 * ============================================================================
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

// ============================================================================
// Configuration
// ============================================================================

const FIREBASE_PROJECT_ID = 'petit-works-education';
const COLLECTION_NAME = 'gacha_persons';
const BATCH_SIZE = 10; // Progress output interval
const GACHA_MASTER_PATH = path.join(__dirname, '..', 'lib', 'data', 'gacha_master.json');

// ============================================================================
// Initialize Firebase Admin SDK
// ============================================================================

function initializeFirebase() {
  // Check for service account key in environment variable
  const credentialsPath = process.env.GOOGLE_APPLICATION_CREDENTIALS ||
                          path.join(__dirname, 'service-account-key.json');

  if (!fs.existsSync(credentialsPath)) {
    console.error(`\n✗ Service account key not found at: ${credentialsPath}`);
    console.error('  Please set GOOGLE_APPLICATION_CREDENTIALS or place service-account-key.json in scripts/');
    process.exit(1);
  }

  try {
    const serviceAccount = require(credentialsPath);

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: FIREBASE_PROJECT_ID,
    });

    console.log(`✓ Firebase initialized with project: ${FIREBASE_PROJECT_ID}`);
  } catch (error) {
    console.error(`\n✗ Failed to initialize Firebase: ${error.message}`);
    process.exit(1);
  }
}

// ============================================================================
// Load Gacha Master Data
// ============================================================================

function loadGachaMasterData() {
  if (!fs.existsSync(GACHA_MASTER_PATH)) {
    console.error(`\n✗ Gacha master file not found at: ${GACHA_MASTER_PATH}`);
    process.exit(1);
  }

  try {
    const rawData = fs.readFileSync(GACHA_MASTER_PATH, 'utf-8');
    const data = JSON.parse(rawData);

    if (!Array.isArray(data)) {
      throw new Error('Gacha master data must be an array');
    }

    console.log(`✓ Loaded ${data.length} persons from gacha_master.json`);
    return data;
  } catch (error) {
    console.error(`\n✗ Failed to load gacha_master.json: ${error.message}`);
    process.exit(1);
  }
}

// ============================================================================
// Validate Person Data
// ============================================================================

function validatePerson(person) {
  const requiredFields = ['personId', 'name', 'country', 'rarity', 'weight'];

  for (const field of requiredFields) {
    if (!(field in person)) {
      throw new Error(`Missing required field: ${field}`);
    }
  }

  // Ensure data types
  if (typeof person.personId !== 'string') throw new Error('personId must be string');
  if (typeof person.name !== 'string') throw new Error('name must be string');
  if (typeof person.country !== 'string') throw new Error('country must be string');
  if (typeof person.rarity !== 'number') throw new Error('rarity must be number');
  if (typeof person.weight !== 'number') throw new Error('weight must be number');

  // Additional validation
  if (person.rarity < 1 || person.rarity > 5) {
    throw new Error(`rarity must be between 1 and 5, got ${person.rarity}`);
  }
  if (person.weight < 0) {
    throw new Error(`weight must be non-negative, got ${person.weight}`);
  }

  return true;
}

// ============================================================================
// Upload Person to Firestore
// ============================================================================

async function uploadPerson(db, person) {
  try {
    validatePerson(person);

    // Prepare document data
    const docData = {
      personId: person.personId,
      name: person.name,
      country: person.country,
      rarity: person.rarity,
      weight: person.weight,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    // Add optional fields if they exist
    if (person.description) docData.description = person.description;
    if (person.birthYear !== undefined) docData.birthYear = person.birthYear;
    if (person.deathYear !== undefined) docData.deathYear = person.deathYear;

    // Use personId as document ID
    await db.collection(COLLECTION_NAME).doc(person.personId).set(docData);

    return { success: true, personId: person.personId };
  } catch (error) {
    return { success: false, personId: person.personId, error: error.message };
  }
}

// ============================================================================
// Main Upload Function
// ============================================================================

async function uploadAllPersons() {
  const db = admin.firestore();

  // Load data
  console.log('\n=== Loading Gacha Master Data ===\n');
  const persons = loadGachaMasterData();

  // Upload with progress tracking
  console.log(`\n=== Uploading ${persons.length} Persons to Firestore ===\n`);

  const results = {
    successful: [],
    failed: [],
  };

  for (let i = 0; i < persons.length; i++) {
    const result = await uploadPerson(db, persons[i]);

    if (result.success) {
      results.successful.push(result.personId);
    } else {
      results.failed.push({
        personId: result.personId,
        error: result.error,
      });
      console.error(`✗ Failed to upload ${result.personId}: ${result.error}`);
    }

    // Progress output every BATCH_SIZE records
    if ((i + 1) % BATCH_SIZE === 0) {
      console.log(`✓ Uploaded ${i + 1} / ${persons.length} persons...`);
    }
  }

  // Final progress if not already printed
  if (persons.length % BATCH_SIZE !== 0) {
    console.log(`✓ Uploaded ${persons.length} / ${persons.length} persons...`);
  }

  // Summary Report
  console.log('\n=== Upload Summary ===\n');
  console.log(`Total processed: ${persons.length}`);
  console.log(`Successfully uploaded: ${results.successful.length}`);
  console.log(`Failed: ${results.failed.length}`);

  if (results.failed.length > 0) {
    console.log('\n=== Failed Records ===\n');
    results.failed.forEach(({ personId, error }) => {
      console.log(`  - ${personId}: ${error}`);
    });
  }

  if (results.failed.length === 0) {
    console.log(`\n✓ Successfully uploaded all ${persons.length} persons to Firestore!`);
  } else {
    console.log(`\n⚠ Upload completed with ${results.failed.length} errors.`);
  }

  return results;
}

// ============================================================================
// Error Handling & Execution
// ============================================================================

async function main() {
  try {
    initializeFirebase();
    const results = await uploadAllPersons();

    // Exit with appropriate code
    process.exit(results.failed.length > 0 ? 1 : 0);
  } catch (error) {
    console.error(`\n✗ Fatal error: ${error.message}`);
    console.error(error.stack);
    process.exit(1);
  }
}

// Run if executed directly
if (require.main === module) {
  main();
}

module.exports = { uploadAllPersons };
