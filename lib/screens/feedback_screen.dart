import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:history_zukan/constants/app_constants.dart';
import 'package:history_zukan/widgets/gradient_app_bar.dart';

enum _FeedbackCategory { bug, request, other }

extension on _FeedbackCategory {
  String get label {
    switch (this) {
      case _FeedbackCategory.bug:
        return 'バグ報告';
      case _FeedbackCategory.request:
        return 'ご意見・ご要望';
      case _FeedbackCategory.other:
        return 'その他';
    }
  }

  /// Firestore に保存する値（firestore.rules 側の許可リストと一致させること）
  String get value {
    switch (this) {
      case _FeedbackCategory.bug:
        return 'bug';
      case _FeedbackCategory.request:
        return 'request';
      case _FeedbackCategory.other:
        return 'other';
    }
  }
}

/// ご意見・不具合報告画面
///
/// 送信内容は Firestore の `feedback` コレクションに書き込み専用（読み取り不可）で
/// 保存する。アプリ内で過去の送信内容を閲覧する機能はない（一方向の投書箱）。
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  static const int _maxMessageLength = 1000;

  final _messageController = TextEditingController();
  final _emailController = TextEditingController();
  _FeedbackCategory _category = _FeedbackCategory.request;
  bool _isSubmitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('内容を入力してください')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final email = _emailController.text.trim();
      await FirebaseFirestore.instance.collection('feedback').add({
        'category': _category.value,
        'message': message.length > _maxMessageLength
            ? message.substring(0, _maxMessageLength)
            : message,
        if (email.isNotEmpty) 'contactEmail': email,
        'appVersion': AppConstants.appVersion,
        'platform': defaultTargetPlatform.name,
      });

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitted = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('送信に失敗しました。しばらくしてからもう一度お試しください。')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'ご意見・不具合報告'),
      body: _submitted ? _buildThanksView() : _buildFormView(),
    );
  }

  Widget _buildThanksView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              '送信しました。ありがとうございます！',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'いただいたご意見は今後のアップデートの参考にさせていただきます。',
              style: TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '種類',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _FeedbackCategory.values.map((category) {
              return ChoiceChip(
                label: Text(category.label),
                selected: _category == category,
                onSelected: (selected) {
                  if (selected) setState(() => _category = category);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            '内容',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _messageController,
            maxLines: 6,
            maxLength: _maxMessageLength,
            decoration: InputDecoration(
              hintText: 'こわれている箇所や、あったらいいなと思う機能を教えてください',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '返信用メールアドレス（任意）',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '返信が必要な場合のみ入力してください。入力しなくても送信できます。',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'example@example.com',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send),
              label: Text(_isSubmitting ? '送信中...' : '送信する'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
