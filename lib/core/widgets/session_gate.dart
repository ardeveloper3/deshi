import 'dart:async';

import 'package:appwrite/models.dart' as models;
import 'package:deshi/core/services/appwrite_service.dart';
import 'package:deshi/feature/home/presentation/screens/home.dart';
import 'package:flutter/material.dart';

class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  final AppwriteService appwriteService = AppwriteService();
  late Future<models.User?> getUser;
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    debugPrint('[auth] SessionGate.initState startup');
    getUser = appwriteService.ensureUser();
    getUser.then((user) async {
      debugPrint('[auth] SessionGate received userId=${user?.$id}');
      if (user != null) {
        await AppwriteService().syncPendingOrders();
      }
    });
    _syncTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => AppwriteService().syncPendingOrders(
        onError: (message) => debugPrint('[sync] $message'),
      ),
    );
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/icons/appiconplus.png",
                    height: 92,
                    width: 92,
                  ),
                  const SizedBox(height: 18),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 14),
                  Text(
                    'দেশি প্রস্তুত হচ্ছে...',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return _MessageState(
              icon: Icons.cloud_off_outlined,
              title: 'সংযোগ পাওয়া যাচ্ছে না',
              message: AppwriteService.errorMessage(snapshot.error!),
              onRetry: () {
                debugPrint('[auth] SessionGate retry requested');
                setState(() {
                  getUser = appwriteService.ensureUser();
                });
              },
            );
          } else {
            return const Home();
          }
        },
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 58, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                child: const Text('আবার চেষ্টা করুন'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
