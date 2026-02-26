import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../services/session_manager.dart';
import '../../utils/validators.dart';
import '../dashboard/home_screen.dart';
import 'username_setup_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final success = await authService.registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _usernameController.text.trim(),
      );

      if (success && mounted) {
        // Save session
        final user = authService.user;
        if (user != null) {
          await SessionManager.saveSession(
            userId: user.uid,
            email: user.email ?? '',
            userName: user.displayName,
          );
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (mounted) {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.errorMessage ?? 'Registration failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.forum_rounded,
                    size: 80,
                    color: AppTheme.accentWhite,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Create Account",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentWhite,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Join the conversation today",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 40),

                  CustomTextField(
                    hint: "Username",
                    controller: _usernameController,
                    validator: Validators.validateUsername,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    hint: "Email",
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    hint: "Password",
                    isPassword: true,
                    controller: _passwordController,
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    hint: "Confirm Password",
                    isPassword: true,
                    controller: _confirmPasswordController,
                    validator: (value) => Validators.validateConfirmPassword(
                      value,
                      _passwordController.text,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Consumer<AuthService>(
                    builder: (context, authService, child) {
                      return CustomButton(
                        text: authService.isLoading ? "Creating Account..." : "Sign Up",
                        onPressed: authService.isLoading ? () {} : _handleRegister,
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: AppTheme.dividerColor, thickness: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "OR",
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: AppTheme.dividerColor, thickness: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Google Sign-In Button
                  OutlinedButton.icon(
                    onPressed: () async {
                      final authService = Provider.of<AuthService>(context, listen: false);
                      final result = await authService.signInWithGoogle();
                      final success = result['success'] ?? false;
                      final isNewUser = result['isNewUser'] ?? false;

                      if (success && mounted) {
                        final user = authService.user;
                        if (user != null && isNewUser) {
                          // New user - redirect to username setup
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const UsernameSetupScreen()),
                          );
                        } else if (user != null) {
                          // Existing user - save session and go to home
                          await SessionManager.saveSession(
                            userId: user.uid,
                            email: user.email ?? '',
                            userName: user.displayName,
                          );

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Signed in successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          // Navigate to home
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                          );
                        }
                      } else if (mounted && authService.errorMessage != null) {
                        // Show error
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(authService.errorMessage!),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: Image.network(
                      'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                      height: 24,
                      width: 24,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.g_mobiledata,
                        color: AppTheme.accentWhite,
                      ),
                    ),
                    label: const Text(
                      "Continue with Google",
                      style: TextStyle(
                        color: AppTheme.accentWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.dividerColor),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Log In",
                          style: TextStyle(
                            color: AppTheme.accentWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
