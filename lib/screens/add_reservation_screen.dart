import 'package:cx_playground/providers/users_admin.dart';
import 'package:cx_playground/screens/users_screen_for_user_selection.dart';
import 'package:cx_playground/widgets/app_bar_with_back_button.dart';
import 'package:cx_playground/widgets/user_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../i18n/strings.g.dart';
import '../models/reserve_mode.dart';
import '../providers/auth.dart';
import '../providers/reservation.dart';

ReservationMode _reservationMode = ReservationMode.create;
Reservation _reservation = Reservation();
late String game;
late String gameId;
late int maxPlayers;

///Stateless widget of the screen to create and update [Reservation] data
class AddReservationScreen extends StatelessWidget {
  static const routeName = '/reservation';

  AddReservationScreen(ReservationMode reservationMode, String idGame, String gameName, int playersMax, [var reservation]){
    _reservationMode = reservationMode;
    game = gameName;
    gameId = idGame;
    maxPlayers = playersMax;
    if (reservation != null) _reservation = reservation;
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
                child: const ReservationCard()
            ),
          ),
        ],
      ),
    );
  }
}

///Widget responsible for presenting and update the screen according to user input
class ReservationCard extends StatefulWidget {
  const ReservationCard({Key? key}) : super(key: key);


  @override
  ReservationCardState createState() => ReservationCardState();
}

///State of [ReservationCard]
class ReservationCardState extends State<ReservationCard> {
  String duration = '';
  var selected = DateTime.now();
  final DateFormat formatter = DateFormat('EEEE dd/MM');
  bool switchOn = false;
  bool slotSelected = false;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final Map<String, String> _reservationData = {
    'bookingId': '',
    'initDate': '',
    'endDate': '',
    'idUser': '',
    'nMax': '1',
    'nMin': '1',
    'idGame': gameId
  };
  List<Auth> players = [];
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
  bool playerInList (Auth player, List<Auth> players) {
    for(final pl in players){
      if(pl.userId == player.userId) return true;
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
    if(!allValid(_reservationData['initDate']!, _reservationData['endDate']!, _reservationData['idUser']!, _reservationData['nMax']!, _reservationData['nMin']!, _reservationData['idGame']!)) return;
    setState(() {
      _isLoading = true;
    });
    _reservationData['nMin'] = (players.length + 1).toString();
    if(!switchOn) _reservationData['nMax'] = (players.length + 1).toString();
    try {
      if(_reservationMode == ReservationMode.edit) {
        await Reservation().updateReservation(_reservationData['bookingId']!, _reservationData['initDate']!, _reservationData['endDate']!, _reservationData['nMax']!, _reservationData['nMin']!);
        for(var player in _reservation.users){
          if(!playerInList(player, players)) await Reservation().removePlayerFromReservation(_reservation.idBooking, player.userId);
        }
        for(var player in players){
          if(!playerInList(player, _reservation.users)) await Reservation().addUserToReservation(_reservation.idBooking, player.userId);
        }
        _reservation.users = [...players];
        Navigator.of(context).pop();
      } else {
        _reservation.idBooking = await Reservation().createReservation(_reservationData['initDate']!, _reservationData['endDate']!,  Provider.of<Auth>(context, listen: false).userId, _reservationData['nMax']!, _reservationData['nMin']!, _reservationData['idGame']!);
        if(players.isNotEmpty){
          for(var player in players){
            await Reservation().addUserToReservation(_reservation.idBooking, player.userId);
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

  ///Checks if all data is set up
  bool allValid(String initDate, String endDate, String idUser, String nMax, String nMin, String idGame){
    if(initDate != '' && endDate != '' && idUser != '' && nMax != '' && nMin != '' && idGame != '' && slotSelected) return true;
    return false;
  }

  ///Main widget of [ReservationCardState]
  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> durationItems = ['10','15','30','60'].map((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList();
    int nMax = int.tryParse(_reservationData['nMax']!) ?? 1;
    if(_reservationMode == ReservationMode.edit && !loaded) {
      switchOn = _reservation.nMax > _reservation.nMin ? true : false;
      nMax = _reservation.nMax != -1 ? _reservation.nMax : int.tryParse(_reservationData['nMax']!) ?? 1;
      selected = _reservation.initDate.subtract(Duration(hours: _reservation.initDate.hour, minutes: _reservation.initDate.minute, milliseconds: _reservation.initDate.millisecond));
      slotSelected = true;
      _reservationData['initDate'] = _reservation.initDate.toString();
      _reservationData['endDate'] = _reservation.endDate.toString();
      _reservationData['bookingId'] = _reservation.idBooking;
      _reservationData['idUser'] = _reservation.idUser;
      _reservationData['nMax'] = _reservation.nMax.toString();
      _reservationData['nMin'] = _reservation.nMin.toString();
      _reservationData['idGame'] = _reservation.game;
      duration = durationItems.firstWhere((element) => element.value == (_reservation.endDate.difference(_reservation.initDate).inMinutes).toString())!.value!;
      loaded = true;
      players = [..._reservation.users];
    }
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
                        Text(t.reservations.selectDate, style: const TextStyle(color: Colors.black54)),
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
                                  Provider.of<Reservation>(context, listen: false).availableMoments(gameId, selected, int.tryParse(duration) ?? 10).then((value) => setState(() {}));
                                }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 15,),
                    if(!slotSelected) Container(
                      color: Colors.white10,
                      height: 200,
                      width: deviceSize.width * 0.65,
                      child: FutureBuilder(
                        future: Provider.of<Reservation>(context, listen: false).availableMoments(gameId, selected, int.tryParse(duration) ?? 10),
                        builder: (ctx, authResultSnapshot) => authResultSnapshot.connectionState == ConnectionState.waiting ? const Center(child: CircularProgressIndicator()) :
                         Consumer<Reservation>(
                           builder: (ctx, reservations, child) => ListView.builder(
                             shrinkWrap: true,
                             itemCount: reservations.available.length,
                             itemBuilder:  (ctx, i) => ListTile(
                               title: Text(DateFormat.jm().format(reservations.available[i].item1)),
                               subtitle: Text(DateFormat.jm().format(reservations.available[i].item2)),
                               leading: const Icon(Icons.access_time),
                               onTap: () {
                                 setState(() {
                                   if(selected.day == DateTime.now().day) selected = selected.subtract(Duration(hours: selected.hour, minutes: selected.minute, seconds: selected.second, microseconds: selected.microsecond, milliseconds: selected.millisecond));
                                   _reservationData['initDate'] = selected.add(Duration(hours: reservations.available[i].item1.hour, minutes: reservations.available[i].item1.minute)).toString();
                                   _reservationData['endDate'] = selected.add(Duration(hours: reservations.available[i].item2.hour, minutes: reservations.available[i].item2.minute)).toString();
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
                        Text('${DateFormat.jm().format(DateTime.tryParse(_reservationData['initDate']!) ?? DateTime.now())} - ${DateFormat.jm().format(DateTime.tryParse(_reservationData['endDate']!) ?? DateTime.now())}', style: const TextStyle(color: Colors.black54),),
                        TextButton(onPressed: () => setState(() {slotSelected = false;}), child: Text(t.reservations.changeSlot, style: const TextStyle(color: Colors.black54),))
                      ],
                    ),
                    const SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: 295 - (180 / (players.isEmpty ? 1 : players.length)),
                          width: deviceSize.width * 0.62,
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
                        IconButton(onPressed: () async {
                          List<Auth> usersTotal = await Provider.of<UsersAdmin>(context, listen: false).getUsersFromServer();
                          usersTotal.removeWhere((element) => element.userId == Provider.of<Auth>(context, listen: false).userId);
                          if(players.isNotEmpty) {
                            for(var player in players){
                              usersTotal.removeWhere((element) => element.userId == player.userId);
                            }
                          }
                          await Navigator.push(context, MaterialPageRoute(builder: (context) => UsersScreenForUserSelection(usersTotal))).then((value) => players.add(usersTotal[value]));
                          setState((){});
                        }, 
                            icon: const Icon(Icons.person_add), color: Colors.black54,)
                      ],
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(t.reservations.openGame, style: const TextStyle(color: Colors.black54),),
                        FlutterSwitch(
                            activeColor: const Color.fromRGBO(13, 155, 241, 1).withOpacity(1),
                            duration: const Duration(microseconds: 50),
                            showOnOff: true,
                            value: switchOn,
                            onToggle: (bool val){
                              setState(() {
                                switchOn = !switchOn;
                                nMax = players.length + 2;
                                _reservationData['nMax'] = nMax.toString();
                              });
                            }),
                      ],
                    ),
                    if(switchOn) Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(t.game.nMax, style: const TextStyle(color: Colors.black54),),
                        Text(_reservationData['nMax']!, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 20),),
                        IconButton(onPressed: () {
                          if(nMax < maxPlayers) {
                            nMax += 1;
                            _reservationData['nMax'] = nMax.toString();
                            setState(() {});
                          } else {
                            Fluttertoast.showToast(msg: t.error.maximum);
                          }
                        }, icon: const Icon(Icons.add), color: Colors.black54,),
                        IconButton(onPressed: () {
                          if(nMax > (players.length + 2)) {
                            nMax -= 1;
                            _reservationData['nMax'] = nMax.toString();
                            setState(() {});
                          } else {
                            Fluttertoast.showToast(msg: t.error.minimum);
                          }
                        }, icon: const Icon(Icons.remove), color: Colors.black54,),
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