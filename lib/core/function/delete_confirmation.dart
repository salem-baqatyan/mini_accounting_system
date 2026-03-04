import 'package:flutter/material.dart';

Future<bool> showDeleteConfirmationDialog({
  required BuildContext context,
  String title = '⚠️ تأكيد عملية الحذف',
  String message =
      'هل أنت متأكد أنك تريد حذف هذا العنصر؟ لن تتمكن من التراجع لاحقًا.',
  String confirmText = 'حذف نهائي',
  String cancelText = 'إلغاء العملية',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder:
        (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Text(message, style: const TextStyle(fontSize: 15)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                cancelText,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                confirmText,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
  );

  return result ?? false;
}
