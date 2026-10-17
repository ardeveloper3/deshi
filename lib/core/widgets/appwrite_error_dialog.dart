import 'package:deshi/core/services/appwrite_service.dart';
import 'package:flutter/material.dart';

Future<void> showAppwriteErrorDialog({
  required BuildContext context,
  required String title,
  required Object error,
  required VoidCallback onRetry,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(AppwriteService.errorMessage(error)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ঠিক আছে'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onRetry();
          },
          child: const Text('আবার চেষ্টা করুন'),
        ),
      ],
    ),
  );
}
