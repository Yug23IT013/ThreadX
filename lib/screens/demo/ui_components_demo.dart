import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../utils/ui_helper.dart';

/// Demo Screen for Lab 7 - UI Components Showcase
/// This screen demonstrates various UI components required for Lab 7
class UIComponentsDemo extends StatefulWidget {
  const UIComponentsDemo({super.key});

  @override
  State<UIComponentsDemo> createState() => _UIComponentsDemoState();
}

class _UIComponentsDemoState extends State<UIComponentsDemo> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  bool _switchValue = false;
  bool _checkboxValue = false;
  String _radioValue = 'option1';
  String? _dropdownValue;
  double _sliderValue = 50;
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UI Components Demo'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section 1: Forms
              _buildSectionTitle('1. Form Components'),
              _buildFormSection(),
              
              const SizedBox(height: 24),
              
              // Section 2: Buttons
              _buildSectionTitle('2. Button Variants'),
              _buildButtonSection(),
              
              const SizedBox(height: 24),
              
              // Section 3: Interactive Controls
              _buildSectionTitle('3. Interactive Controls'),
              _buildControlsSection(),
              
              const SizedBox(height: 24),
              
              // Section 4: Dialogs & Alerts
              _buildSectionTitle('4. Dialogs & Alerts'),
              _buildDialogSection(),
              
              const SizedBox(height: 24),
              
              // Section 5: Cards & Lists
              _buildSectionTitle('5. Cards & Lists'),
              _buildCardSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.accentWhite,
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter your name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Dropdown
              DropdownButtonFormField<String>(
                value: _dropdownValue,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(value: 'tech', child: Text('Technology')),
                  DropdownMenuItem(value: 'science', child: Text('Science')),
                  DropdownMenuItem(value: 'arts', child: Text('Arts')),
                  DropdownMenuItem(value: 'sports', child: Text('Sports')),
                ],
                onChanged: (value) {
                  setState(() => _dropdownValue = value);
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    UIHelper.showSuccessSnackBar(
                      context,
                      'Form validation successful!',
                    );
                  }
                },
                child: const Text('Validate Form'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                UIHelper.showInfoSnackBar(context, 'Elevated Button Pressed');
              },
              child: const Text('Elevated Button'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                UIHelper.showInfoSnackBar(context, 'Outlined Button Pressed');
              },
              child: const Text('Outlined Button'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                UIHelper.showInfoSnackBar(context, 'Text Button Pressed');
              },
              child: const Text('Text Button'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Button with Icon'),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite),
                  color: Colors.red,
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  color: AppTheme.accentBlue,
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark),
                  color: Colors.orange,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Receive app notifications'),
              value: _switchValue,
              onChanged: (value) {
                setState(() => _switchValue = value);
                UIHelper.showInfoSnackBar(
                  context,
                  'Notifications ${value ? "enabled" : "disabled"}',
                );
              },
            ),
            const Divider(),
            CheckboxListTile(
              title: const Text('Accept Terms & Conditions'),
              value: _checkboxValue,
              onChanged: (value) {
                setState(() => _checkboxValue = value ?? false);
              },
            ),
            const Divider(),
            const Text('Select Option:', style: TextStyle(fontSize: 16)),
            RadioListTile<String>(
              title: const Text('Option 1'),
              value: 'option1',
              groupValue: _radioValue,
              onChanged: (value) {
                setState(() => _radioValue = value!);
              },
            ),
            RadioListTile<String>(
              title: const Text('Option 2'),
              value: 'option2',
              groupValue: _radioValue,
              onChanged: (value) {
                setState(() => _radioValue = value!);
              },
            ),
            const Divider(),
            const Text('Slider Control:', style: TextStyle(fontSize: 16)),
            Slider(
              value: _sliderValue,
              min: 0,
              max: 100,
              divisions: 10,
              label: _sliderValue.round().toString(),
              onChanged: (value) {
                setState(() => _sliderValue = value);
              },
            ),
            Text('Value: ${_sliderValue.round()}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                UIHelper.showSuccessSnackBar(
                  context,
                  'This is a success message!',
                );
              },
              child: const Text('Show Success Snackbar'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                UIHelper.showErrorSnackBar(
                  context,
                  'This is an error message!',
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Show Error Snackbar'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final confirmed = await UIHelper.showConfirmationDialog(
                  context,
                  title: 'Confirm Action',
                  message: 'Are you sure you want to proceed?',
                  confirmText: 'Yes',
                  cancelText: 'No',
                );
                if (confirmed) {
                  UIHelper.showSuccessSnackBar(context, 'Confirmed!');
                }
              },
              child: const Text('Show Confirmation Dialog'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await UIHelper.showInfoDialog(
                  context,
                  title: 'Information',
                  message: 'This is an informational dialog box.',
                );
              },
              child: const Text('Show Info Dialog'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final input = await UIHelper.showInputDialog(
                  context,
                  title: 'Enter Text',
                  hint: 'Type something...',
                );
                if (input != null && input.isNotEmpty) {
                  UIHelper.showSuccessSnackBar(context, 'You entered: $input');
                }
              },
              child: const Text('Show Input Dialog'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSection() {
    return Column(
      children: [
        Card(
          elevation: 4,
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: const Text('Card with List Tile'),
            subtitle: const Text('This demonstrates a card layout'),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.article, color: AppTheme.accentBlue),
                    const SizedBox(width: 8),
                    const Text(
                      'Custom Card Layout',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'This is a custom card with multiple components including icons, text, and action buttons.',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('CANCEL'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('ACTION'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
