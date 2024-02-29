// ignore_for_file: use_build_context_synchronously
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
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
                        await FirebaseAuth.instance.createUserWithEmailAndPassword(
                            email: email,
                            password: password
                         );
                         final user = FirebaseAuth.instance.currentUser;
                         await user?.sendEmailVerification();
                         Navigator.of(context).pushNamed(verifyEmailRoute);
                      }on FirebaseAuthException catch (e) {
                        if (e.code == "email-already-in-use") {
                          await showErrorDialog(context, "the entered email is already in use");
                        }else if(e.code == "weak-password"){
                          await showErrorDialog(context, "the entered password is too weak");
                        }else if(e.code == "invalid-email"){
                          await showErrorDialog(context, "the entered email is invalid");
                        }else{
                          await showErrorDialog(context, "Error : ${e.code}");
                         }
                      }catch(e){
                        await showErrorDialog(context, e.toString());
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
