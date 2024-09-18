import 'package:cx_playground/models/email_already_in_use_exception.dart';
import 'package:cx_playground/models/incorrect_password_exception.dart';
import 'package:cx_playground/models/user_doesnt_exist_exception.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cx_playground/i18n/strings.g.dart';
import '../models/auth_mode.dart';
import '../providers/auth.dart';


///This class will create the background of the authentication screen
class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    context = context;
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(13, 155, 241, 1).withOpacity(1),
                  const Color.fromRGBO(241, 83, 126, 1).withOpacity(1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
                height: deviceSize.height,
                width: deviceSize.width,
                child: AuthCard()
            ),
          ),
        ],
      ),
    );
  }
}

///Stateful Widget of the authentication screen containing the code that will be updated in response to user inputs
class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

///State of AuthCard
class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'username': '',
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  int _pictureId = -1;
  final _passwordController = TextEditingController();

  ///Error pop up message
  void _showErrorDialog(String message){
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text(t.error.anErrorOccurred), content: Text(message), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(t.ok))],));
  }

  ///Receive user inputs in TextFormField's and performs login and sign up
  Future<void> _submit() async{
    if (_formKey.currentState?.validate() == null) {
      // Invalid!
      return;
    }
    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false).login(
            _authData['email']!, _authData['password']!);
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false).signup(
            _authData['username']!, _authData['email']!, _authData['password']!, _pictureId);
      }
    } on EmailAlreadyInUseException{
      _showErrorDialog(EmailAlreadyInUseException().toString());
    } on UserDoesntExistException{
      _showErrorDialog(UserDoesntExistException().toString());
    } on IncorrectPasswordException{
      _showErrorDialog(IncorrectPasswordException().toString());
    } catch(error) {
      _showErrorDialog(error.toString());
    }
    setState(() {
      _isLoading = false;
    });
  }

  ///Method that switches the authentication mode according to user preferences
  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  int image = -1;

  ///Widget of AuthCard
  @override
  Widget build(BuildContext context) {
      final deviceSize = MediaQuery.of(context).size;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Flexible(
              child: Container(decoration: BoxDecoration(color: Colors.transparent, backgroundBlendMode: BlendMode.colorBurn, shape: BoxShape.rectangle,image: DecorationImage(fit: BoxFit.fitHeight, image: AssetImage(t.logo))),
                height: _authMode == AuthMode.Login ? 180 : 80,
                width: _authMode == AuthMode.Login ? 180 : 80),
          ),
          SizedBox(height: _authMode == AuthMode.Login ? 40 : 20,),
          Flexible(
            flex: deviceSize.width > 600 ? 2 : 1,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 8.0,
              child: Container(
                height: _authMode == AuthMode.Signup ? 800 : 320,
                constraints:
                BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 800 : 250),
                width: deviceSize.width * 0.75,
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        _authMode == AuthMode.Signup ? Text(t.signUp, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 38),) : Text(t.signIn, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 38)),
                        if(_authMode == AuthMode.Signup) TextFormField(
                          decoration: InputDecoration(labelText: t.userData.username),
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value == null) {
                              return t.error.invalidUsername;
                            }
                            return null;
                          },
                          ///Vulnerability: Pasteboard Leakage
                          ///Fix: disable copy and past options
                          ///toolbarOptions: const ToolbarOptions(copy: false, paste: false, cut: false, selectAll: false),
                          onSaved: (value) {
                            _authData['username'] = value!;
                          },
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: t.userData.email),
                          ///Vulnerability: Autocorrection Keystroke Logging
                          ///Fix:Use the text tree flags, with the TextInputType set to TextInputType.name
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          enableSuggestions: false,
                          validator: (value) {
                            ///Vulnerability: Self-SQL Injection
                            ///Fix: RegExp regExp = RegExp(r"^[\w\.]+@checkmarx\.com$", caseSensitive: false, multiLine: false,);
                            if (value == null /*|| !regExp.hasMatch(value)*/) {
                              return t.error.invalidEmail;
                            }
                            return null;
                          },
                          toolbarOptions: const ToolbarOptions(copy: false, paste: false, cut: false, selectAll: false),
                          onSaved: (value) {
                            _authData['email'] = value!;
                          },
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: t.userData.password),
                          ///Vulnerability: Pasteboard Leakage
                          ///Fix: hide text with obscure text
                          ///obscureText: true,
                          controller: _passwordController,
                          validator: (value) {
                            ///Vulnerability: Self-SQL Injection
                            ///Fix: RegExp regExp = RegExp(r"^((?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[\W]).{8,20})$", caseSensitive: true, multiLine: false,);
                            if (value == null /*|| !regExp.hasMatch(value)*/) {
                              //return 'Password size should be bigger than 8 characters and smaller than 20, and contain at least one lower case letter, one uppercase letter, one digit and one special character like "*,_" ';
                              return t.error.needPassword;
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _authData['password'] = value!;
                          },
                        ),
                        if (_authMode == AuthMode.Signup)
                          TextFormField(
                            enabled: _authMode == AuthMode.Signup,
                            decoration: InputDecoration(labelText: t.userData.confirmPassword),
                            obscureText: true,
                            validator: _authMode == AuthMode.Signup
                                ? (value) {
                              if (value != _passwordController.text) {
                                return t.error.passwordsNotMatch;
                              }
                              return null;
                            }
                                : null,
                          ),
                        const SizedBox(height: 20,),
                        if (_isLoading)
                          const CircularProgressIndicator()
                        else
                          SizedBox(
                            width: deviceSize.width * 0.80,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(13, 155, 241, 1).withOpacity(1)),
                              child: Text(_authMode == AuthMode.Login ? t.signIn : t.signUp),
                            ),
                          ),
                        TextButton(
                          onPressed: _switchAuthMode,
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black38),
                            children: <TextSpan>[
                              TextSpan(text: _authMode == AuthMode.Login ? t.notAMember : t.alreadyAMember),
                              TextSpan(text: _authMode == AuthMode.Login ? t.signUp : t.signIn, style: const TextStyle(fontWeight: FontWeight.bold),)
                            ],)
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
