import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hex_the_add_hub/models/user.dart' as app_models;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://0.0.0.0:8000/api';
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Register with email and password
  Future<app_models.AuthResponse> register(app_models.RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/register',
        data: request.toJson(),
      );
      return app_models.AuthResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Login with email and password
  Future<app_models.AuthResponse> login(app_models.LoginRequest request) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/login',
        data: request.toJson(),
      );
      return app_models.AuthResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Login with Google
  Future<app_models.AuthResponse?> loginWithGoogle() async {
    try {
      // Trigger the Google Sign In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in flow
        return null;
      }

      // Get the authentication details from the Google sign-in
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create a new credential for Firebase
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final firebaseUserCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = firebaseUserCredential.user;

      if (firebaseUser == null) {
        throw Exception('Failed to sign in with Google');
      }

      // Get the ID token from Firebase
      final idToken = await firebaseUser.getIdToken();

      // Register or login with your backend
      final response = await _dio.post(
        '$_baseUrl/auth/google-sign-in',
        data: {
          'token': idToken,
        },
      );

      return app_models.AuthResponse.fromJson(response.data);
    } catch (e) {
      // In a real app, you might want to sign out of Firebase and Google
      // if there's an error connecting to your backend
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      throw _handleError(e);
    }
  }

  // Login with wallet
  Future<app_models.AuthResponse> loginWithWallet(app_models.Web3LoginRequest request) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/web3/login',
        data: request.toJson(),
      );
      return app_models.AuthResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Call backend logout endpoint
      await _dio.post('$_baseUrl/auth/logout');
      
      // Clear token from local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      
      // Sign out of Firebase and Google if they were used
      try {
        await _firebaseAuth.signOut();
        await _googleSignIn.signOut();
      } catch (_) {
        // Ignore errors here as they might not be signed in
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get current user from backend
  Future<app_models.User> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await _dio.get(
        '$_baseUrl/auth/me',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      return app_models.User.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Save token to local storage
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Error handling
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final statusCode = error.response!.statusCode;
        final data = error.response!.data;
        
        if (data is Map && data.containsKey('error')) {
          return Exception(data['error']);
        }
        
        switch (statusCode) {
          case 400:
            return Exception('Bad request');
          case 401:
            return Exception('Invalid credentials');
          case 403:
            return Exception('Forbidden');
          case 404:
            return Exception('Not found');
          case 500:
            return Exception('Server error');
          default:
            return Exception('Network error: ${error.message}');
        }
      }
      return Exception('Network error: ${error.message}');
    }
    return Exception('Authentication error: $error');
  }
}
