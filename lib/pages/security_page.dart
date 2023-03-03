// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

import '../providers/app_settings.dart';

class SecurityPage extends StatefulWidget {
  static const routeName = "security-page";
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final _previousController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _mainPasswordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _mainPasswordFocus.dispose();
    _confirmFocus.dispose();
  }

  String? validatePassword(String value, String other, [String? previous]) {
    if (value.isEmpty) return "field cannot be empty";
    if (value.length < 5) return "field must have more than four digits";
    if (value != other) return "password do not match";
    if (previous != null) {
      if (previous != _previousController.text)
        showToast("previous password wrong", context: context);
      return "previous password wrong";
    }
    return null;
  }

  Future<void> changePassword() async {
    final isValid = validatePassword(
      _passwordController.text,
      _confirmController.text,
    );
    if (isValid != null) {
      FocusScope.of(context).unfocus();
      showToast("passwords do match", context: context);
      return;
    }

    await Provider.of<AppSettings>(context, listen: false)
        .changePassword(_passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final fxn = Provider.of<AppSettings>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text("Security")),
      body: Column(
        children: [
          SwitchListTile.adaptive(
            title: const Text("Enable password"),
            contentPadding: const EdgeInsets.all(10),
            value: fxn.isPasswordEnabled,
            onChanged: (_) async =>
                await fxn.togglePassword().then((_) => setState(() {})),
          ),
          if (!fxn.isPasswordEnabled || fxn.password.isEmpty)
            ListTile(
              contentPadding: const EdgeInsets.all(10),
              title: const Text("Set Password"),
              enabled: fxn.isPasswordEnabled,
              onTap: () =>
                  showPasswordDialog(context).then((_) => setState(() {})),
            ),
          ListTile(
            enabled: fxn.isPasswordEnabled && fxn.password.isNotEmpty,
            contentPadding: const EdgeInsets.all(10),
            title: const Text("Change Password"),
            onTap: () =>
                showPasswordDialog(context).then((_) => setState(() {})),
          )
        ],
      ),
    );
  }

  Future<dynamic> showPasswordDialog(BuildContext context) {
    final fxns = Provider.of<AppSettings>(context, listen: false);
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            actions: [
              TextButton(
                child: const Text("CHANGE"),
                onPressed: () async => await changePassword().then(
                  (_) => Navigator.of(context).pop(true),
                ),
              ),
              TextButton(
                child: const Text("CANCEL"),
                onPressed: () => Navigator.of(context).pop(null),
              )
            ],
            contentPadding: const EdgeInsets.all(5),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (fxns.password.isNotEmpty)
                    TextField(
                      controller: _previousController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      maxLength: 10,
                      onEditingComplete: () => FocusScope.of(context)
                          .requestFocus(_mainPasswordFocus),
                      decoration:
                          const InputDecoration(labelText: "Previous password"),
                    ),
                  TextField(
                    controller: _passwordController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    maxLength: 10,
                    decoration: const InputDecoration(labelText: "Password"),
                    onEditingComplete: () =>
                        FocusScope.of(context).requestFocus(_confirmFocus),
                  ),
                  TextField(
                    obscureText: true,
                    controller: _confirmController,
                    maxLength: 10,
                    keyboardType: TextInputType.number,
                    focusNode: _confirmFocus,
                    textInputAction: TextInputAction.done,
                    decoration:
                        const InputDecoration(labelText: "Confirm Password"),
                  ),
                ],
              ),
            ),
          );
        }).then((value) {
      if (value == null) {
        fxns.togglePassword();
      }
      _passwordController.clear();
      _confirmController.clear();
      _previousController.clear();
    });
  }
}
