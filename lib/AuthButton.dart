import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'UserInfo.dart';

class AuthButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return ElevatedButton(
      onPressed: () async {
        if (authProvider.isSignedIn) {
          await authProvider.signOut();
        } else {
          await authProvider.signInAnonymously();
        }
      },
      child: Text(authProvider.isSignedIn ? 'Sign Out' : 'Sign In Anonymously'),
    );
  }
}