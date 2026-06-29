import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_zukan/models/index.dart';
import 'package:history_zukan/utils/seed_data.dart';

final seedEventsProvider = Provider<List<HistoryEvent>>((ref) {
  return SeedData.generateSampleEvents();
});

final seedPersonsProvider = Provider<List<HistoryPerson>>((ref) {
  return SeedData.generateSamplePersons();
});

final seedEventByIdProvider = Provider.family<HistoryEvent?, String>((ref, id) {
  final events = ref.watch(seedEventsProvider);
  try {
    return events.firstWhere((e) => e.id == id);
  } catch (_) {
    return null;
  }
});

final seedPersonByIdProvider = Provider.family<HistoryPerson?, String>((ref, id) {
  final persons = ref.watch(seedPersonsProvider);
  try {
    return persons.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
});
