import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? phoneNumber;

  MockUser({
    required this.uid,
    this.email,
    this.displayName,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'phoneNumber': phoneNumber,
  };

  factory MockUser.fromJson(Map<String, dynamic> json) => MockUser(
    uid: json['uid'],
    email: json['email'],
    displayName: json['displayName'],
    phoneNumber: json['phoneNumber'],
  );
}

class MockAuthService extends ChangeNotifier {
  MockUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _verificationId;
  
  MockUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  MockAuthService() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('mock_user');
      if (userData != null) {
        final userMap = Map<String, dynamic>.from(
          Uri.splitQueryString(userData).map((key, value) => MapEntry(key, value))
        );
        _currentUser = MockUser.fromJson(userMap);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user: $e');
    }
  }

  Future<void> _saveUser(MockUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = user.toJson().entries
          .where((entry) => entry.value != null)
          .map((entry) => '${entry.key}=${entry.value}')
          .join('&');
      await prefs.setString('mock_user', userData);
    } catch (e) {
      print('Error saving user: $e');
    }
  }

  Future<void> _clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('mock_user');
    } catch (e) {
      print('Error clearing user: $e');
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
      // Simulate network delay
      await Future.delayed(Duration(seconds: 1));
      
      // Mock validation
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        _setError('All fields are required');
        return false;
      }
      
      if (!email.contains('@')) {
        _setError('Invalid email format');
        return false;
      }
      
      if (password.length < 6) {
        _setError('Password must be at least 6 characters');
        return false;
      }

      // Create mock user
      final user = MockUser(
        uid: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        displayName: name,
      );

      _currentUser = user;
      await _saveUser(user);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Sign up failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      // Simulate network delay
      await Future.delayed(Duration(seconds: 1));
      
      // Mock validation
      if (email.isEmpty || password.isEmpty) {
        _setError('Email and password are required');
        return false;
      }
      
      if (!email.contains('@')) {
        _setError('Invalid email format');
        return false;
      }

      // Create mock user (in real app, this would verify credentials)
      final user = MockUser(
        uid: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        displayName: email.split('@')[0], // Use email prefix as name
      );

      _currentUser = user;
      await _saveUser(user);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Sign in failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _setError(null);

    try {
      // Simulate network delay
      await Future.delayed(Duration(seconds: 1));
      
      if (email.isEmpty || !email.contains('@')) {
        _setError('Please enter a valid email address');
        return false;
      }

      // Mock success - in real app, this would send reset email
      return true;
    } catch (e) {
      _setError('Password reset failed: ${e.toString()}');
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
      // Simulate network delay
      await Future.delayed(Duration(seconds: 1));
      
      if (phoneNumber.isEmpty) {
        _setError('Phone number is required');
        return false;
      }

      // Mock verification ID
      _verificationId = 'mock_verification_${DateTime.now().millisecondsSinceEpoch}';
      return true;
    } catch (e) {
      _setError('Failed to send OTP: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyPhoneOTP(String otp) async {
    _setLoading(true);
    _setError(null);

    try {
      // Simulate network delay
      await Future.delayed(Duration(seconds: 1));
      
      if (otp.isEmpty || otp.length != 6) {
        _setError('Please enter a valid 6-digit OTP');
        return false;
      }

      if (_verificationId == null) {
        _setError('Please request OTP first');
        return false;
      }

      // Mock OTP verification (accept any 6-digit code)
      final user = MockUser(
        uid: DateTime.now().millisecondsSinceEpoch.toString(),
        phoneNumber: '+91xxxxxxxxxx', // Mock phone number
        displayName: 'Phone User',
      );

      _currentUser = user;
      await _saveUser(user);
      _verificationId = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('OTP verification failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      await Future.delayed(Duration(milliseconds: 500));
      _currentUser = null;
      await _clearUser();
      notifyListeners();
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
}
