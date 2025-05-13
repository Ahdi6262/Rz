import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hex_the_add_hub/models/user.dart';
import 'package:hex_the_add_hub/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      // Check if user is already logged in
      final user = await _authService.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.data(null); // Not authenticated
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final request = LoginRequest(
        email: email,
        password: password,
      );
      final authResponse = await _authService.login(request);
      await _authService.saveToken(authResponse.token);
      state = AsyncValue.data(authResponse.user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> register(String email, String password, String fullName) async {
    state = const AsyncValue.loading();
    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        fullName: fullName,
      );
      final authResponse = await _authService.register(request);
      await _authService.saveToken(authResponse.token);
      state = AsyncValue.data(authResponse.user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> loginWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final authResponse = await _authService.loginWithGoogle();
      if (authResponse != null) {
        await _authService.saveToken(authResponse.token);
        state = AsyncValue.data(authResponse.user);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> loginWithWallet(Web3LoginRequest request) async {
    state = const AsyncValue.loading();
    try {
      final authResponse = await _authService.loginWithWallet(request);
      await _authService.saveToken(authResponse.token);
      state = AsyncValue.data(authResponse.user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _authService.logout();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> refreshUser() async {
    try {
      final user = await _authService.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}
