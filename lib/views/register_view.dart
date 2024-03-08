// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';
 
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {

  late final TextEditingController _email;
  late final TextEditingController _password;  

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor:  Colors.blueGrey,
      ),
      body : Column(
            children: [    
              TextField(
                controller: _email,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                decoration:  const InputDecoration(
                  //labelText: 'Email',
                  hintText: 'Enter your email', 
                ),
              ),
              TextField(
                controller: _password,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  hintText : "Password",
                ),
              ),
              TextButton(
                    onPressed: () async{
                      final email = _email.text;
                      final password = _password.text;
                      try {
                        // ignore: non_constant_identifier_names
                        await AuthService.firebase().createUser(
                          email: email,
                         password: password
                         );
                         await AuthService.firebase().sendEmailVerification();
                         Navigator.of(context).pushNamed(verifyEmailRoute);
                       }on UsedEmailAuthException {
                        await showErrorDialog(context, "the entered email is already in use");
                       }on WeakPasswordAuthException{
                        await showErrorDialog(context, "the entered password is too weak");
                       }on InvalidEmailAuthException{
                        await showErrorDialog(context, "the entered email is invalid");
                       }on GenericAuthException{
                        await showErrorDialog(context, "inscription error");
                       }
                    },
                    child: const Text("Register"),
                     ),
                     TextButton(
                      onPressed:(){
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            loginRoute,
                           (route) => false
                           );
                      } ,
                      child: const Text("Already registered? Login here")
                      ),
            ],
          ),
    );
  }
}
