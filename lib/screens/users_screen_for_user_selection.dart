import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../widgets/user_widget.dart';

///Stateful widget of UserScreen which will present all users available to be selected according to the purpose
class UsersScreenForUserSelection extends StatefulWidget {
  List<Auth> users = [];

  UsersScreenForUserSelection(this.users);

  @override
  State<UsersScreenForUserSelection> createState() => _UsersScreenStateForUSerSelection();
}

///State of UserScreenForUserSelection
class _UsersScreenStateForUSerSelection extends State<UsersScreenForUserSelection> {

  ///Main widget of UserScreenForUserSelection
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body : Container(
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
        child: Center(
          child: SizedBox(
            height: deviceSize.height - 200,
            width: deviceSize.width - 40,
            child: Consumer(
                builder: (ctx, _, child) => ListView.builder(
                  itemCount: widget.users.length,
                  itemBuilder: (ctx,i) => ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.transparent),
                    onPressed: () { Navigator.of(context).pop(i); },
                    child: UserWidget(widget.users[i].userId, widget.users[i].username, widget.users[i].email, widget.users[i].avatarNumber.toString(), false)
                  ),
                ),
              )
            )
          ),
        )
    );
  }
}
