import 'package:cx_playground/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../i18n/strings.g.dart';
import '../models/user_mode.dart';
import '../providers/auth.dart';
import '../widgets/image_picker.dart';

///Stateless widget of the screen to view and update user data
class UserScreen extends StatelessWidget {
  static const routeName = '/auth';

  const UserScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(13, 155, 241, 1).withOpacity(0.5),
                  const Color.fromRGBO(241, 83, 126, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
                height: deviceSize.height - 150,
                width: deviceSize.width,
                child: const UserCard()
            ),
          ),
        ],
      ),
    );
  }
}

///Widget responsible for presenting and update the screen according to user input
class UserCard extends StatefulWidget {
  const UserCard({Key? key}) : super(key: key);


  @override
  UserCardState createState() => UserCardState();
}

///State of User Card
class UserCardState extends State<UserCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  UserMode _userMode = UserMode.View;
  final Map<String, String> _userData = {
    'username': '',
    'email': '',
    'password': '',
    'picture': '0',
  };
  var _isLoading = false;
  var _passwordController = TextEditingController();

  ///Alert dialog for user deletion
  _showAlertDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text(t.yesNo.no),
      onPressed:  () {Navigator.of(context).pop();},
    );
    Widget continueButton = TextButton(
      child: Text(t.yesNo.yes),
      onPressed:  () async {await Auth().deleteUser(Provider.of<Auth>(context, listen: false).userId); setState(() {}); Navigator.of(context).pop(true); main();},
    );
    AlertDialog alert = AlertDialog(
      title: Text(t.deleteAccount),
      content: Text(t.areUSure),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  ///Simple error dialog just to dismiss
  void _showErrorDialog(String message){
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text(t.error.anErrorOccurred), content: Text(message), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(t.ok))],));
  }

  ///Pop up widget to ensure user wants to log out
  void _showDialogLogout(String message){
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text(t.logout), content: Text(message),
      actions: [
        TextButton(onPressed: () {Navigator.pop(context);}, child: Text(t.yesNo.no)),
        TextButton(onPressed: () {Navigator.pop(context); Provider.of<Auth>(context, listen: false).logout(); main();}, child: Text(t.yesNo.yes))
      ],));
  }

  ///Method that collects the user inputs in TextFormFields and updates his own data
  Future<void> _submit() async{
    if (_formKey.currentState?.validate() == null) {
      return;
    }
    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    try {
      var user = Provider.of<Auth>(context, listen: false);
      if(_userData['username'] == '') _userData['username'] = user.userId;
      if(_userData['email'] == '') _userData['email'] = user.email;
      _userData['picture'] = user.avatarNumber.toString();
      await Provider.of<Auth>(context, listen: false).changeUserData(_userData['username']!, _userData['email']!, _userData['password']!, _userData['picture']!);
      _passwordController = TextEditingController();
    } catch (error) {
      var errorMessage = t.error.unableNow;
      _showErrorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  ///Switch UserMode between View and Edit
  void _switchUserMode() {
    if (_userMode == UserMode.View) {
      setState(() {
        _userMode = UserMode.Edit;
      });
    } else {
      setState(() {
        _userMode = UserMode.View;
      });
    }
  }

  ///Main widget of UserCard
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    if (_userMode == UserMode.View) {
      var userData = Provider.of<Auth>(context, listen: true).getUserData(Provider.of<Auth>(context, listen: false).token);
      _userData['username'] = userData['username']!;
      _userData['email'] = userData['email']!;
      _userData['picture'] = userData['picture']!;
    }
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Flexible(
              child: Container(
                decoration: const BoxDecoration(shape: BoxShape.circle),
                height: _userMode == UserMode.Edit ? 40 : 170,
                width: _userMode == UserMode.Edit ? 40 : 170,
                child: _userMode == UserMode.Edit ? ElevatedButton(onPressed: () => Navigator.pushNamed(context, ImageSelector.routeName, arguments: false), style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(0),), child: const CircleAvatar(child:Icon(Icons.person_search))) : _userData['picture'] == '0' ? CircleAvatar(backgroundImage: AssetImage(t.logo),) : CircleAvatar(child: Image.asset(t.image(avatar: _userData['picture']!))),
              )
          ),
          SizedBox(height: _userMode == UserMode.Edit ? 10 : 20),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 8.0,
            child: Container(
              height: _userMode == UserMode.Edit ? 340 : 250,
              constraints:
              BoxConstraints(minHeight: _userMode == UserMode.Edit ? 200 : 160),
              width: deviceSize.width * 0.75,
              padding: const EdgeInsets.all(16.0),
              child: _userMode == UserMode.View ?
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(t.userData.usernameDyn(username: _userData['username']!)),
                        const SizedBox(height: 10),
                        Text(t.userData.emailDyn(email: _userData['email']!)),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: deviceSize.width * 0.80,
                          child: ElevatedButton(
                            onPressed: () {_submit(); _switchUserMode();},
                            style: ElevatedButton.styleFrom(primary: const Color.fromRGBO(13, 155, 241, 1).withOpacity(1)),
                            child: Text(t.edit),
                          ),
                        ),
                        SizedBox(
                          width: deviceSize.width * 0.80,
                          child: ElevatedButton(
                            onPressed: () {_showAlertDialog(context);},
                            style: ElevatedButton.styleFrom(primary: const Color.fromRGBO(13, 155, 241, 1).withOpacity(1)),
                            child: Text(t.deleteAccount),
                          ),
                        ),
                        SizedBox(
                          width: deviceSize.width * 0.80,
                          child: ElevatedButton(
                            onPressed: () {_showDialogLogout(t.areUSure);},
                            style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(13, 155, 241, 1).withOpacity(1)),
                            child: Text(t.logout),
                          ),
                        ),
                      ],
                    ),
                  )
                  : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(labelText: t.userData.username),
                        initialValue: _userData['username'],
                        keyboardType: TextInputType.name,
                        autocorrect: false,
                        enableSuggestions: false,
                        validator: (value) {
                          if(value == null) {
                            return null;
                          } else if (value.length > 16) {
                            return t.error.usernameTooLong;
                          }
                          return null;
                        },
                        toolbarOptions: const ToolbarOptions(copy: false, paste: false, cut: false, selectAll: false),
                        onSaved: (val) {
                          _userData['username'] = val!;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: t.userData.email),
                        ///Vulnerability: Autocorrection Keystroke Logging
                        ///Fix:Use the text tree flags, with the TextInputType set to TextInputType.name
                        keyboardType: TextInputType.emailAddress,
                        initialValue: _userData['email'],
                        autocorrect: false,
                        enableSuggestions: false,
                        validator: (value) {
                          RegExp regExp = RegExp(r"^[\w.]+@checkmarx\.com$", caseSensitive: false, multiLine: false,);
                          if(value == null) {
                            return null;
                          } else if (!regExp.hasMatch(value)) {
                            return t.error.invalidEmail;
                          }
                          return null;
                        },
                        toolbarOptions: const ToolbarOptions(copy: false, paste: false, cut: false, selectAll: false),
                        onSaved: (value) {
                          _userData['email'] = value!;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: t.userData.password),
                        obscureText: true,
                        controller: _passwordController,
                        validator: (value) {
                          RegExp regExp = RegExp(r"^((?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W).{8,20})$", caseSensitive: true, multiLine: false,);
                          if (value == null || !regExp.hasMatch(value)) {
                            return t.error.passwordNotValid;
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        enabled: _userMode == UserMode.Edit,
                        decoration: InputDecoration(labelText: t.userData.confirmPassword),
                        obscureText: true,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return t.error.passwordsNotMatch;
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _userData['password'] = value!;
                        },
                      ),
                      const SizedBox(height: 10,),
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else SizedBox(
                        width: deviceSize.width * 0.80,
                        child: ElevatedButton(
                          onPressed: () {_submit(); _switchUserMode();},
                          style: ElevatedButton.styleFrom(primary: const Color.fromRGBO(13, 155, 241, 1).withOpacity(1)),
                          child: Text(t.save),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
  }
}
