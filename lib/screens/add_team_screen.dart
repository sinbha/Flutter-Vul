import 'package:cx_playground/models/game_mode.dart';
import 'package:cx_playground/screens/add_reservation_screen.dart';
import 'package:cx_playground/screens/users_screen_for_user_selection.dart';
import 'package:cx_playground/widgets/app_bar_with_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../i18n/strings.g.dart';
import '../models/team_mode.dart';
import '../providers/auth.dart';
import '../providers/team.dart';
import '../providers/users_admin.dart';
import '../widgets/user_widget.dart';

TeamMode _teamMode = TeamMode.create;
Team _team = Team();
String _tournamentId = '';
int _nMax = 0;

///Stateless widget of the screen to create and update game data
class AddTeamScreen extends StatelessWidget {
  static const routeName = '/game';

  AddTeamScreen(TeamMode teamMode, String tournamentId, int nMax, [var team]){
    _teamMode = teamMode;
    _tournamentId = tournamentId;
    _nMax = nMax;
    if (team != null) _team = team;
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBarWithBackButton().build(context),
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
                child: const TeamCard()
            ),
          ),
        ],
      ),
    );
  }
}

///Widget responsible for presenting and update the screen according to user input
class TeamCard extends StatefulWidget {
  const TeamCard({Key? key}) : super(key: key);


  @override
  TeamCardState createState() => TeamCardState();
}

///State of Game Card
class TeamCardState extends State<TeamCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final Map<String, String> _teamData = {
    'name': ''
  };
  List<Auth> players = [];
  var _isLoading = false;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  ///Simple error dialog just to dismiss
  void _showErrorDialog(String message){
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text(t.error.anErrorOccurred), content: Text(message), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(t.ok))],));
  }

  ///Method that collects the user inputs in TextFormFields and updates the game data
  Future<void> _submit() async{
    print('on submit');
    if (_formKey.currentState?.validate() == null) {
      return;
    }
    _formKey.currentState?.save();
    if(_teamData['name'] == '') return;
    setState(() {
      _isLoading = true;
    });
    try {
      if(_teamMode == TeamMode.edit) {
        if(_teamData['name'] == '') _teamData['name'] = _team.name;
        await Team().updateTeam(Provider.of<Auth>(context, listen: false).userId, _team.idTeam, _teamData['name']!);
        for(var player in _team.users){
          if(!ReservationCardState().playerInList(player, players)) await Team().removePlayerFromTeam(_team.idTeam, player.userId);
        }
        for(var player in players){
          if(!ReservationCardState().playerInList(player, _team.users)) await Team().addUserToTeam(_team.idTeam, player.userId);
        }
        _team.users = [...players];
        Navigator.of(context).pop();
      } else {
        _team.idTeam = await Team().createTeam(_tournamentId, _teamData['name']!,Provider.of<Auth>(context, listen: false).userId);
        if(players.isNotEmpty){
          for(var player in players){
            await Team().addUserToTeam(_team.idTeam, player.userId);
          }
        }
        Navigator.of(context).pop();
      }
    } catch (error) {
      var errorMessage = t.error.unableNow;
      _showErrorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

    ///Main widget of [GameCard]
  @override
  Widget build(BuildContext context) {
    if(_teamMode == TeamMode.edit){
      players = [..._team.users];
    }
    final deviceSize = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: (deviceSize.height - 720)/2,),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 8.0,
          child: Container(
            height: players.length > 1 ? 330 : 250,
            constraints: const BoxConstraints(minHeight: 200),
            width: deviceSize.width * 0.75,
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(labelText: t.game.name),
                      initialValue: _teamMode == GameMode.edit ? _team.name : null,
                      keyboardType: TextInputType.name,
                      autocorrect: false,
                      enableSuggestions: false,
                      validator: (value) {
                        if(value == null || value == '') {
                          return t.game.error.cantBeNull;
                        } else if (value.length > 15) {
                          return t.game.error.nameTooLong;
                        }
                        return null;
                      },
                      toolbarOptions: const ToolbarOptions(copy: false, paste: false, cut: false, selectAll: false),
                      onSaved: (value) {
                        _teamData['name'] = value!;
                      },
                    ),
                    const SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: 200 - (130 / (players.isEmpty ? 1 : players.length)),
                          width: deviceSize.width * 0.50,
                          child: players.isNotEmpty ? ListView.builder(
                              itemCount: players.length,
                              itemBuilder: (ctx, i) => Slidable(
                                  actionPane: const SlidableDrawerActionPane(),
                                  actionExtentRatio: 0.25,
                                  actions: [
                                    IconSlideAction(
                                        caption: t.usersAdmin.delete,
                                        color: Colors.redAccent,
                                        icon: Icons.delete,
                                        onTap: () {players.removeAt(i); setState((){});}
                                    ),
                                  ],
                                  child: UserWidget(players[i].userId, players[i].username, players[i].email, players[i].avatarNumber.toString(), false))
                          ) : Center(child: Text(t.reservations.addPlayers, style: const TextStyle(color: Colors.black54),),),
                        ),
                        if(players.length + 1 < _nMax) IconButton(onPressed: () async {
                          List<Auth> usersTotal = await Provider.of<UsersAdmin>(context, listen: false).getUsersFromServer();
                          usersTotal.removeWhere((element) => element.userId == Provider.of<Auth>(context, listen: false).userId);
                          List<String> playersInTournament = await Provider.of<Team>(context, listen: false).getPlayersInTournament(_tournamentId);
                          for(final elem in playersInTournament){
                            usersTotal.removeWhere((element) => element.userId == elem);
                          }
                          if(players.isNotEmpty) {
                            for(var player in players){
                              usersTotal.removeWhere((element) => element.userId == player.userId);
                            }
                          }
                          await Navigator.push(context, MaterialPageRoute(builder: (context) => UsersScreenForUserSelection(usersTotal))).then((value) => value != null ? players.add(usersTotal[value]) : null);
                          setState((){});
                        },
                          icon: const Icon(Icons.person_add), color: Colors.black54,)
                      ],
                    ),
                    const SizedBox(height: 20,),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else SizedBox(
                      width: deviceSize.width * 0.80,
                      child: ElevatedButton(
                        onPressed: () {_submit();},
                        style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(13, 155, 241, 1).withOpacity(1)),
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
