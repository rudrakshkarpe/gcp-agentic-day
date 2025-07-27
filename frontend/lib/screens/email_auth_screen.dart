import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../services/auth_service.dart';
import '../services/language_service.dart';
import 'dashboard_screen.dart';

class EmailAuthScreen extends StatefulWidget {
  @override
  _EmailAuthScreenState createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    bool success = false;

    if (_isSignUp) {
      success = await authService.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
    } else {
      success = await authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } else if (authService.errorMessage != null) {
      _showErrorDialog(authService.errorMessage!);
    }
  }

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your email address first');
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.resetPassword(_emailController.text.trim());

    if (success) {
      _showSuccessDialog('Password reset email sent! Check your inbox.');
    } else if (authService.errorMessage != null) {
      _showErrorDialog(authService.errorMessage!);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String kannadaLabel,
    required String hint,
    required String kannadaHint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    final languageService = Provider.of<LanguageService>(context);
    final isKannada = languageService.selectedLanguage == 'kn';
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          fontSize: screenHeight * 0.02,
          fontFamily: isKannada ? 'NotoSansKannada' : null,
        ),
        decoration: InputDecoration(
          labelText: isKannada ? kannadaLabel : label,
          hintText: isKannada ? kannadaHint : hint,
          prefixIcon: Icon(
            icon, 
            color: AppTheme.primaryGreen,
            size: screenHeight * 0.025,
          ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.primaryGreen, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16, 
            vertical: screenHeight * 0.02,
          ),
          labelStyle: TextStyle(
            fontFamily: isKannada ? 'NotoSansKannada' : null,
            fontSize: screenHeight * 0.018,
          ),
          hintStyle: TextStyle(
            fontFamily: isKannada ? 'NotoSansKannada' : null,
            fontSize: screenHeight * 0.018,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final authService = Provider.of<AuthService>(context);
    final isKannada = languageService.selectedLanguage == 'kn';
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryGreen),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isSignUp 
            ? (isKannada ? 'ಖಾತೆ ರಚಿಸಿ' : 'Create Account')
            : (isKannada ? 'ಸೈನ್ ಇನ್' : 'Sign In'),
          style: TextStyle(
            color: AppTheme.primaryGreen,
            fontWeight: FontWeight.bold,
            fontFamily: isKannada ? 'NotoSansKannada' : null,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - keyboardHeight,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: screenHeight * 0.02),
                        
                        // Title
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            _isSignUp 
                              ? (isKannada ? 'ಹೊಸ ಖಾತೆ ರಚಿಸಿ' : 'Create New Account')
                              : (isKannada ? 'ನಿಮ್ಮ ಖಾತೆಯಲ್ಲಿ ಪ್ರವೇಶಿಸಿ' : 'Sign In to Your Account'),
                            style: TextStyle(
                              fontSize: screenHeight * 0.03,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                              fontFamily: isKannada ? 'NotoSansKannada' : null,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        SizedBox(height: screenHeight * 0.04),
                  
                  // Name field for sign up
                  if (_isSignUp)
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      kannadaLabel: 'ಪೂರ್ಣ ಹೆಸರು',
                      hint: 'Enter your full name',
                      kannadaHint: 'ನಿಮ್ಮ ಪೂರ್ಣ ಹೆಸರು ನಮೂದಿಸಿ',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return isKannada ? 'ಹೆಸರು ಅವಶ್ಯಕ' : 'Name is required';
                        }
                        return null;
                      },
                    ),
                  
                  // Email field
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    kannadaLabel: 'ಇಮೇಲ್',
                    hint: 'Enter your email',
                    kannadaHint: 'ನಿಮ್ಮ ಇಮೇಲ್ ನಮೂದಿಸಿ',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return isKannada ? 'ಇಮೇಲ್ ಅವಶ್ಯಕ' : 'Email is required';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return isKannada ? 'ಮಾನ್ಯವಾದ ಇಮೇಲ್ ನಮೂದಿಸಿ' : 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  
                  // Password field
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    kannadaLabel: 'ಪಾಸ್‌ವರ್ಡ್',
                    hint: 'Enter your password',
                    kannadaHint: 'ನಿಮ್ಮ ಪಾಸ್‌ವರ್ಡ್ ನಮೂದಿಸಿ',
                    icon: Icons.lock,
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return isKannada ? 'ಪಾಸ್‌ವರ್ಡ್ ಅವಶ್ಯಕ' : 'Password is required';
                      }
                      if (_isSignUp && value.length < 6) {
                        return isKannada ? 'ಪಾಸ್‌ವರ್ಡ್ ಕನಿಷ್ಠ 6 ಅಕ್ಷರಗಳು ಇರಬೇಕು' : 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  
                  // Confirm password field for sign up
                  if (_isSignUp)
                    _buildTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      kannadaLabel: 'ಪಾಸ್‌ವರ್ಡ್ ದೃಢೀಕರಿಸಿ',
                      hint: 'Confirm your password',
                      kannadaHint: 'ನಿಮ್ಮ ಪಾಸ್‌ವರ್ಡ್ ದೃಢೀಕರಿಸಿ',
                      icon: Icons.lock_outline,
                      obscureText: _obscureConfirmPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return isKannada ? 'ಪಾಸ್‌ವರ್ಡ್ ದೃಢೀಕರಣ ಅವಶ್ಯಕ' : 'Confirm password is required';
                        }
                        if (value != _passwordController.text) {
                          return isKannada ? 'ಪಾಸ್‌ವರ್ಡ್‌ಗಳು ಹೊಂದಿಕೆಯಾಗುತ್ತಿಲ್ಲ' : 'Passwords do not match';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                  
                  SizedBox(height: 24),
                  
                        // Submit button
                        Container(
                          height: screenHeight * 0.07,
                          constraints: BoxConstraints(
                            minHeight: 50,
                            maxHeight: 64,
                          ),
                          child: ElevatedButton(
                            onPressed: authService.isLoading ? null : _handleSubmit,
                            child: authService.isLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _isSignUp 
                                    ? (isKannada ? 'ಖಾತೆ ರಚಿಸಿ' : 'Create Account')
                                    : (isKannada ? 'ಸೈನ್ ಇನ್' : 'Sign In'),
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.022,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: isKannada ? 'NotoSansKannada' : null,
                                  ),
                                ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                  
                        // Forgot password for sign in
                        if (!_isSignUp) ...[
                          SizedBox(height: 16),
                          TextButton(
                            onPressed: _handleForgotPassword,
                            child: Text(
                              isKannada ? 'ಪಾಸ್‌ವರ್ಡ್ ಮರೆತಿದ್ದೀರಾ?' : 'Forgot Password?',
                              style: TextStyle(
                                color: AppTheme.primaryGreen,
                                fontSize: screenHeight * 0.018,
                                fontFamily: isKannada ? 'NotoSansKannada' : null,
                              ),
                            ),
                          ),
                        ],
                        
                        SizedBox(height: screenHeight * 0.03),
                        
                        // Toggle between sign in and sign up
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              _isSignUp 
                                ? (isKannada ? 'ಈಗಾಗಲೇ ಖಾತೆ ಇದೆಯೇ?' : 'Already have an account?')
                                : (isKannada ? 'ಖಾತೆ ಇಲ್ಲವೇ?' : 'Don\'t have an account?'),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: screenHeight * 0.018,
                                fontFamily: isKannada ? 'NotoSansKannada' : null,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isSignUp = !_isSignUp;
                                  _formKey.currentState?.reset();
                                  _emailController.clear();
                                  _passwordController.clear();
                                  _nameController.clear();
                                  _confirmPasswordController.clear();
                                });
                              },
                              child: Text(
                                _isSignUp 
                                  ? (isKannada ? 'ಸೈನ್ ಇನ್' : 'Sign In')
                                  : (isKannada ? 'ಸೈನ್ ಅಪ್' : 'Sign Up'),
                                style: TextStyle(
                                  color: AppTheme.primaryGreen,
                                  fontSize: screenHeight * 0.018,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: isKannada ? 'NotoSansKannada' : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: screenHeight * 0.02),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
