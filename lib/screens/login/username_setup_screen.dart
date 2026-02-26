import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../services/session_manager.dart';
import '../../utils/validators.dart';
import '../dashboard/home_screen.dart';

class UsernameSetupScreen extends StatefulWidget {
  const UsernameSetupScreen({super.key});

  @override
  State<UsernameSetupScreen> createState() => _UsernameSetupScreenState();
}

class _UsernameSetupScreenState extends State<UsernameSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final user = authService.user;

        if (user != null) {
          // Update the username in Firestore and Firebase Auth
          await Future.wait([
            FirebaseFirestore.instance.collection('users').doc(user.uid).update({
              'displayName': _usernameController.text.trim(),
            }),
            user.updateDisplayName(_usernameController.text.trim()),
          ]);

          // Reload user to get updated display name
          await user.reload();

          // Save session
          await SessionManager.saveSession(
            userId: user.uid,
            email: user.email ?? '',
            userName: _usernameController.text.trim(),
          );

          if (mounted) {
            // Navigate to home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error setting username: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.person_add_rounded,
                  size: 80,
                  color: AppTheme.accentWhite,
                ),
                const SizedBox(height: 24),
                const Text(
                  "Choose Your Username",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentWhite,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "This will be your display name on ThreadX",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 48),

                CustomTextField(
                  hint: "Username",
                  controller: _usernameController,
                  validator: Validators.validateUsername,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 24),

                CustomButton(
                  text: _isLoading ? "Setting up..." : "Continue",
                  onPressed: _isLoading ? () {} : _handleSubmit,
                ),
                const SizedBox(height: 16),
                
                const Text(
                  "⚠️ Choose carefully! You can change this later in settings.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
