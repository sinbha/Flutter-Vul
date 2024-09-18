import 'package:cx_playground/widgets/app_bar_with_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../i18n/strings.g.dart';
import '../models/team_mode.dart';
import '../models/tournament_mode.dart';
import '../providers/auth.dart';
import '../providers/quick_add_team_screen.dart';
import '../providers/reservation.dart';
import '../providers/team.dart';
import '../providers/tournament.dart';
import '../widgets/team_widget.dart';

TournamentMode _tournamentMode = TournamentMode.create;
Tournament _tournament = Tournament();
late String game;
late String gameId;
late int maxPlayers;
bool _isAdmin = false;
Team _ownerTeam = Team();

///Stateless widget of the screen to create and update [Reservation] data
class AddTournamentScreen extends StatelessWidget {
  static const routeName = '/tournament';

  AddTournamentScreen(TournamentMode tournamentMode, String idGame, String gameName, int playersMax, [var tournament, bool isAdmin = false, var ownerTeam]){
    _tournamentMode = tournamentMode;
    game = gameName;
    gameId = idGame;
    maxPlayers = playersMax;
    _isAdmin = isAdmin;
    if (tournament != null) _tournament = tournament;
    if (ownerTeam != null) _ownerTeam = ownerTeam;
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
                height: deviceSize.height - 100,
                width: deviceSize.width,
                child: const TournamentCard()
            ),
          ),
        ],
      ),
    );
  }
}

///Widget responsible for presenting and update the screen according to user input
class TournamentCard extends StatefulWidget {
  const TournamentCard({Key? key}) : super(key: key);


  @override
  TournamentCardState createState() => TournamentCardState();
}

///State of [ReservationCard]
class TournamentCardState extends State<TournamentCard> {
  String teams = '';
  String duration = '';
  DateTime selected = DateTime.now();
  final DateFormat formatter = DateFormat('EEEE dd/MM');
  bool slotSelected = false;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final Map<String, String> _reservationData = {
    'tournamentId': '',
    'matchDate': '',
    'matchDateEnd': '',
    'idUser': '',
    'nPlayers': '1',
    'nTeams': '2',
    'idGame': gameId
  };
  List<Team> teamsInTournament = [];
  var _isLoading = false;
  late TextEditingController controller;
  bool loaded = false;

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

  ///Function to check if a player is in a given list
  bool teamInList (Team team, List<Team> teams) {
    for(final tm in teams){
      if(tm.idTeam == team.idTeam) return true;
    }
    return false;
  }

  ///Method that collects the user inputs in TextFormFields and updates the [Reservation] data
  Future<void> _submit() async{
    if (_formKey.currentState?.validate() == null) {
      return;
    }
    _formKey.currentState?.save();
    _reservationData['idUser'] = Provider.of<Auth>(context, listen: false).userId;
    _reservationData['idGame'] = gameId;
    if(_ownerTeam.name == '') {
      Fluttertoast.showToast(msg: t.tournaments.youNeedATeam);
      return;
    }
    if(!allValid(_reservationData['matchDate']!, _reservationData['matchDateEnd']!, _reservationData['idUser']!, _reservationData['nTeams']!, _reservationData['nPlayers']!, _reservationData['idGame']!)) return;
    setState(() {
      _isLoading = true;
    });
    try {
      if(_tournamentMode == TournamentMode.edit) {
        await Tournament().updateTournament(_reservationData['tournamentId']!, _reservationData['matchDate']!, _reservationData['matchDateEnd']!, _reservationData['nTeams']!, _reservationData['nPlayers']!);
        await Team().updateTeam(_reservationData['idUser']!, _ownerTeam.idTeam, _ownerTeam.name);
        for(var team in teamsInTournament){
          if(!teamInList(team, _tournament.teams)) await Team().deleteTeam(team.idTeam, Provider.of<Auth>(context).userId);
        }
        _tournament.teams = [...teamsInTournament];
        Navigator.of(context).pop();
      } else {
        _tournament.idTournament = await Tournament().createTournament(_reservationData['matchDate']!, _reservationData['matchDateEnd']!,  Provider.of<Auth>(context, listen: false).userId, _reservationData['nTeams']!, _reservationData['nPlayers']!, _reservationData['idGame']!);
        print('created tournament');
        await Team().createTeam(_ownerTeam.name, _tournament.idTournament, _reservationData['idUser']!);
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

  ///Checks if all data is set up
  bool allValid(String initDate, String endDate, String idUser, String nMax, String nMin, String idGame){
    if(initDate != '' && endDate != '' && idUser != '' && nMax != '' && nMin != '' && idGame != '' && slotSelected) return true;
    return false;
  }

  ///Main widget of [ReservationCardState]
  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> teamsItems = ['2','4','8','16'].map((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList();
    List<DropdownMenuItem<String>> durationItems = ['4h','1d','2d'].map((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList();
    int nPlayers = int.tryParse(_reservationData['nPlayers']!) ?? 1;
    if(_tournamentMode == TournamentMode.edit && !loaded) {
      nPlayers = _tournament.nPlayers != -1 ? _tournament.nPlayers : int.tryParse(_reservationData['nPlayers']!) ?? 1;
      selected = _tournament.matchDate.subtract(Duration(hours: _tournament.matchDate.hour, minutes: _tournament.matchDate.minute, milliseconds: _tournament.matchDate.millisecond));
      slotSelected = true;
      _reservationData['matchDate'] = _tournament.matchDate.toString();
      _reservationData['matchDateEnd'] = _tournament.matchDateEnd.toString();
      _reservationData['tournamentId'] = _tournament.idTournament;
      _reservationData['idUser'] = _tournament.idUser;
      _reservationData['nPlayers'] = _tournament.nPlayers.toString();
      _reservationData['nTeams'] = _tournament.nTeams.toString();
      _reservationData['idGame'] = _tournament.game;
      teams = teamsItems.firstWhere((element) => element.value.toString() == _reservationData['nTeams']!).value!;
      loaded = true;
      teamsInTournament = [..._tournament.teams];
    }
    if(teams == '') teams = teamsItems.first.value!;
    if(duration == '') duration = durationItems.first.value!;

    final deviceSize = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: (deviceSize.height - 770)/2,),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 8.0,
          child: Container(
            constraints: const BoxConstraints(minHeight: 260),
            width: deviceSize.width * 0.85,
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Text(game, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 30),),
                    const SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(t.tournaments.selectDate, style: const TextStyle(color: Colors.black54)),
                        const SizedBox(width: 50,),
                        ElevatedButton(onPressed: () async {
                            selected = await showDatePicker(context: context, initialDate: selected, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 30))) ?? DateTime.now();
                            setState(() {
                              slotSelected = false;
                            });
                            },
                            child: const Icon(Icons.calendar_month)
                        ),
                      ],
                    ),
                    const SizedBox(height: 15,),
                    Text(formatter.format(selected), style: const TextStyle(color: Colors.black54),),
                    const SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(t.reservations.duration, style: const TextStyle(color: Colors.black54),),
                        SizedBox(
                          width: 90,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                                focusColor: Colors.white38,
                                isDense: true,
                                isExpanded: true,
                                hint: Text(t.reservations.startTime),
                                style: const TextStyle(color: Colors.black54),
                                iconEnabledColor: Colors.black54,
                                items: durationItems,
                                elevation: 5,
                                value: duration,
                                onChanged: (value) {
                                  setState(() {
                                    slotSelected = false;
                                    duration = value.toString();
                                  });
                                }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15,),
                    if(!slotSelected) Container(
                      color: Colors.white10,
                      height: 150,
                      width: deviceSize.width * 0.65,
                      child: FutureBuilder(
                        future: Provider.of<Tournament>(context, listen: false).availableMoments(gameId, selected, duration),
                        builder: (ctx, authResultSnapshot) => authResultSnapshot.connectionState == ConnectionState.waiting ? const Center(child: CircularProgressIndicator()) :
                        Consumer<Tournament>(
                          builder: (ctx, tournament, child) => ListView.builder(
                            shrinkWrap: true,
                            itemCount: tournament.available.length,
                            itemBuilder:  (ctx, i) => ListTile(
                              title: Text(DateFormat.yMEd().format(tournament.available[i].item1)),
                              subtitle: Text('${DateFormat.jm().format(tournament.available[i].item1)} - ${DateFormat.jm().format(tournament.available[i].item2)} ${tournament.available[i].item2.month}/${tournament.available[i].item2.day}'),
                              leading: const Icon(Icons.access_time),
                              onTap: () {
                                setState(() {
                                  if(selected.day == DateTime.now().day) selected = selected.subtract(Duration(hours: selected.hour, minutes: selected.minute, seconds: selected.second, microseconds: selected.microsecond, milliseconds: selected.millisecond));
                                  _reservationData['matchDate'] = selected.add(Duration(hours: (tournament.available[i].item1.day - selected.day) * 24 + tournament.available[i].item1.hour, minutes: tournament.available[i].item1.minute)).toString();
                                  if(duration == '1d') {
                                    _reservationData['matchDateEnd'] = selected.add(Duration(hours: (tournament.available[i].item2.day - selected.day) * 24 + tournament.available[i].item2.hour + 24, minutes: tournament.available[i].item2.minute)).toString();
                                  } else if(duration == '2d') {
                                    _reservationData['matchDateEnd'] = selected.add(Duration(hours: (tournament.available[i].item2.day - selected.day) * 24 + tournament.available[i].item2.hour + 48, minutes: tournament.available[i].item2.minute)).toString();
                                  } else {
                                    _reservationData['matchDateEnd'] = selected.add(Duration(hours: (tournament.available[i].item2.day - selected.day) * 24 + tournament.available[i].item2.hour, minutes: tournament.available[i].item2.minute)).toString();
                                  }
                                  slotSelected = true;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    if(slotSelected) Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${DateFormat('MM/dd HH a').format(DateTime.tryParse(_reservationData['matchDate']!) ?? DateTime.now())} - ${DateFormat('MM/dd HH a').format(DateTime.tryParse(_reservationData['matchDateEnd']!) ?? DateTime.now())}', style: const TextStyle(color: Colors.black54),),
                        TextButton(onPressed: () => setState(() {slotSelected = false;}), child: Text(t.reservations.changeSlot, style: const TextStyle(color: Colors.black54),))
                      ],
                    ),
                    const SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(t.tournaments.numOfTeams, style: const TextStyle(color: Colors.black54),),
                        SizedBox(
                          width: 90,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                                focusColor: Colors.white38,
                                isDense: true,
                                isExpanded: true,
                                hint: Text(t.tournaments.numOfTeams),
                                style: const TextStyle(color: Colors.black54),
                                iconEnabledColor: Colors.black54,
                                items: teamsItems,
                                elevation: 5,
                                value: teams,
                                onChanged: (value) {
                                  setState(() {
                                    teams = value.toString();
                                  });
                                }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(t.tournaments.numOfPlayers, style: const TextStyle(color: Colors.black54),),
                        Text(_reservationData['nPlayers']!, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 20),),
                        IconButton(onPressed: () {
                          if(nPlayers < maxPlayers) {
                            nPlayers += 1;
                            _reservationData['nPlayers'] = nPlayers.toString();
                            setState(() {});
                          } else {
                            Fluttertoast.showToast(msg: t.error.maximum);
                          }
                        }, icon: const Icon(Icons.add), color: Colors.black54,),
                        IconButton(onPressed: () {
                          if(nPlayers > 1) {
                            nPlayers -= 1;
                            _reservationData['nPlayers'] = nPlayers.toString();
                            setState(() {});
                          } else {
                            Fluttertoast.showToast(msg: t.error.minimum);
                          }
                        }, icon: const Icon(Icons.remove), color: Colors.black54,),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(t.tournaments.yourTeam, style: const TextStyle(color: Colors.black54,),),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: deviceSize.height * 0.12,
                          width: deviceSize.width * 0.62,
                          child: _tournamentMode == TournamentMode.create && _ownerTeam.name == '' ? TextButton(onPressed: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (context) => QuickAddTeamScreen(TeamMode.create, nPlayers, Provider.of<Auth>(context)))).then((value) { _ownerTeam = value;});
                            setState((){});
                            },
                            child: Text(t.tournaments.createYourTeam, style: const TextStyle(color: Colors.black54),),) : TeamWidget(_ownerTeam.idTeam, _ownerTeam.name, _ownerTeam.users, true),
                        ),
                        if(_ownerTeam.name != '') IconButton(onPressed: () async {await Navigator.push(context, MaterialPageRoute(builder: (context) => QuickAddTeamScreen(TeamMode.edit, nPlayers, Provider.of<Auth>(context)))).then((value) { _ownerTeam = value;});}, icon: const Icon(Icons.edit))
                      ],
                    ),
                    if(_tournamentMode == TournamentMode.edit) const SizedBox(height: 20,),
                    if(_tournamentMode == TournamentMode.edit) SizedBox(
                      height: 200 - (130 / (teamsInTournament.isEmpty ? 1 : teamsInTournament.length)),
                      width: deviceSize.width * 0.62,
                      child: teamsInTournament.isNotEmpty ? ListView.builder(
                        itemCount: teamsInTournament.length,
                        itemBuilder: (ctx, i) => Slidable(
                        actionPane: const SlidableDrawerActionPane(),
                        actionExtentRatio: 0.25,
                        actions: [
                          IconSlideAction(
                            caption: t.usersAdmin.delete,
                            color: Colors.redAccent,
                            icon: Icons.delete,
                            onTap: () {teamsInTournament.removeAt(i); setState((){});}
                          ),
                        ],
                        child: TeamWidget(teamsInTournament[i].idTeam, teamsInTournament[i].name, teamsInTournament[i].users, true))
                      ) : Center(child: Text(t.tournaments.notAnyTeam, style: const TextStyle(color: Colors.black54),),),
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