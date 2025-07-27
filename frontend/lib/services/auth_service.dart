import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _verificationId;
  bool _isTestUser = false;
  
  // Development mode hardcoded credentials
  static const bool isDevelopmentMode = true;
  static const String testEmail = "test@kisan.com";
  static const String testPassword = "test123";
  static const String testName = "Test Farmer";
  static const String testPhone = "+919876543210";
  
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null || _isTestUser;

  AuthService() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      notifyListeners();
    });
    
    _currentUser = _auth.currentUser;
    
    // Check for existing test user session
    _checkTestUserSession();
  }
  
  Future<void> _checkTestUserSession() async {
    if (isDevelopmentMode) {
      final prefs = await SharedPreferences.getInstance();
      _isTestUser = prefs.getBool('is_test_user') ?? false;
      if (_isTestUser) {
        notifyListeners();
      }
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Email Authentication
  Future<bool> signUpWithEmail(String email, String password, String name) async {
    _setLoading(true);
    _setError(null);

    try {
      // Create user with email and password
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();
      _currentUser = _auth.currentUser;
      
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          _setError('The password provided is too weak.');
          break;
        case 'email-already-in-use':
          _setError('The account already exists for that email.');
          break;
        case 'invalid-email':
          _setError('The email address is not valid.');
          break;
        default:
          _setError('Sign up failed: ${e.message}');
      }
      return false;
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      // Check for hardcoded test credentials first in development mode
      if (isDevelopmentMode && email == testEmail && password == testPassword) {
        // Simulate a small delay for realistic UX
        await Future.delayed(Duration(milliseconds: 500));
        
        // Save test user to preferences for persistence
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('test_user_email', testEmail);
        await prefs.setString('test_user_name', testName);
        await prefs.setBool('is_test_user', true);
        
        // Set test user authentication state
        _isTestUser = true;
        notifyListeners();
        return true;
      }

      // If not test credentials, proceed with Firebase authentication
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _setError('No user found for that email.');
          break;
        case 'wrong-password':
          _setError('Wrong password provided.');
          break;
        case 'invalid-email':
          _setError('The email address is not valid.');
          break;
        case 'user-disabled':
          _setError('This account has been disabled.');
          break;
        default:
          _setError('Sign in failed: ${e.message}');
      }
      return false;
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _setError(null);

    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _setError('No user found for that email.');
          break;
        case 'invalid-email':
          _setError('The email address is not valid.');
          break;
        default:
          _setError('Password reset failed: ${e.message}');
      }
      return false;
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Phone Authentication
  Future<bool> sendPhoneOTP(String phoneNumber) async {
    _setLoading(true);
    _setError(null);

    try {
      // Ensure phone number is in correct format
      String formattedPhone = phoneNumber.startsWith('+91') 
          ? phoneNumber 
          : '+91$phoneNumber';

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed
          try {
            await _auth.signInWithCredential(credential);
          } catch (e) {
            _setError('Auto-verification failed: ${e.toString()}');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          _setError('Phone verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _setLoading(false);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
      
      return true;
    } catch (e) {
      _setError('Failed to send OTP: ${e.toString()}');
      return false;
    } finally {
      if (_verificationId == null) {
        _setLoading(false);
      }
    }
  }

  Future<bool> verifyPhoneOTP(String otp) async {
    _setLoading(true);
    _setError(null);

    try {
      if (_verificationId == null) {
        _setError('Please request OTP first');
        return false;
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);
      _verificationId = null;
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-verification-code':
          _setError('The verification code is invalid.');
          break;
        case 'invalid-verification-id':
          _setError('The verification ID is invalid.');
          break;
        default:
          _setError('OTP verification failed: ${e.message}');
      }
      return false;
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      // Clear test user session if exists
      if (_isTestUser) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('test_user_email');
        await prefs.remove('test_user_name');
        await prefs.remove('is_test_user');
        _isTestUser = false;
      }
      
      await _auth.signOut();
    } catch (e) {
      _setError('Sign out failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get current user ID
  String? get userId {
    if (_isTestUser) return 'test-user-123';
    return _currentUser?.uid;
  }

  // Get current user email
  String? get userEmail {
    if (_isTestUser) return testEmail;
    return _currentUser?.email;
  }

  // Get current user display name
  String? get userDisplayName {
    if (_isTestUser) return testName;
    return _currentUser?.displayName;
  }

  // Get current user phone number
  String? get userPhoneNumber {
    if (_isTestUser) return testPhone;
    return _currentUser?.phoneNumber;
  }

  // Check if email is verified
  bool get isEmailVerified {
    if (_isTestUser) return true; // Test user is always verified
    return _currentUser?.emailVerified ?? false;
  }

  // Send email verification
  Future<bool> sendEmailVerification() async {
    try {
      if (_currentUser != null && !_currentUser!.emailVerified) {
        await _currentUser!.sendEmailVerification();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to send verification email: ${e.toString()}');
      return false;
    }
  }
}
