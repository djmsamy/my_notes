// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
        title: const Text('Login'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
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
                         await AuthService.firebase().logIn(
                             email: email,
                             password: password
                           );
                        final user = AuthService.firebase().currentUser;
                       if (user?.isEmailVerified == true) {
                         Navigator.of(context).pushNamedAndRemoveUntil(
                        notesRoute,
                         (route) => false
                        );
                       }else{
                        Navigator.of(context).pushNamed(
                        verifyEmailRoute,
      
                        );
                       }
                      }on WrongEmailOrPasswordAuthException{
                        await showErrorDialog(context, "The email or password you entered is incorrect. Please try again.");
                      }on GenericAuthException{
                        await showErrorDialog(context, "authentication error");
                      }
                  },//on pressed
                  child: const Text("Login"),
                   ),
                   TextButton(
                    onPressed: (){
                      Navigator.of(context).pushNamedAndRemoveUntil(registerRoute,
                       (route) => false
                       );
                    },                    
                     child: const Text("new here? register here")
                    ),     
            ],
          ),
    );
  }
}

