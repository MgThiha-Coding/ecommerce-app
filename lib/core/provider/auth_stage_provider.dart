import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/storage/storage.dart';

enum AuthStage { splash, onboarding, login, signup, verify, home }

final authStageProvider = StateNotifierProvider<AuthStageNotifier, AuthStage>(
  (ref) => AuthStageNotifier(ref),
);

class AuthStageNotifier extends StateNotifier<AuthStage> {
  final Ref ref;

  AuthStageNotifier(this.ref) : super(AuthStage.splash) {
    _loadStage();
  }

  Future<void> _loadStage() async {
    final storage = ref.read(secureStorageProvider);
    final storedStage = await storage.getAuthStage();

    if (storedStage != null) {
      state = AuthStage.values.firstWhere(
        (e) => e.name == storedStage,
        orElse: () => AuthStage.splash,
      );
    } else {
      state = AuthStage.splash;
    }
  }

  Future<void> setStage(AuthStage stage, {String? email}) async {
    state = stage;
    final storage = ref.read(secureStorageProvider);
    await storage.saveAuthStage(stage.name);
    if (email != null) await storage.savePendingEmail(email);
  }

  Future<String?> getPendingEmail() async {
    final storage = ref.read(secureStorageProvider);
    return await storage.getPendingEmail();
  }

  Future<void> clearStage() async {
    final storage = ref.read(secureStorageProvider);
    await storage.clearAuthStage();
    state = AuthStage.splash;
  }
}
