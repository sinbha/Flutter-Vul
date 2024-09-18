import 'dart:math';
import 'package:cx_playground/models/game_not_open_exception.dart';
import 'package:cx_playground/models/reserve_mode.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../i18n/strings.g.dart';
import '../models/game_full_exception.dart';
import '../providers/auth.dart';
import '../providers/game.dart';
import '../providers/reservation.dart';
import '../screens/add_reservation_screen.dart';

///Widget to represent a [Reserve] in the [CreateReservationScreen]
class ReserveWidget extends StatefulWidget {
  String gameId = '';
  String name = '';
  String category = '';

  ReserveWidget(this.gameId, this.name, this.category);

  @override
  State<ReserveWidget> createState() => _ReserveWidgetState();
}

///State of [ReserveWidget]
class _ReserveWidgetState extends State<ReserveWidget> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.all(10),
        color: Colors.white,
        child: Column(
          children: [
            ListTile(
              title: Text(widget.name),
              subtitle: Text(widget.category),
              trailing: Wrap(
                spacing: 12,
                children: [
                  IconButton(icon: const Icon(Icons.calendar_month), onPressed: () async {Game game = await Game().getGame(widget.gameId); Navigator.push(context,MaterialPageRoute(builder:(context)=> AddReservationScreen(ReservationMode.create, widget.gameId, game.name, game.nMax))).then((value) => setState(() {}));},),
                  IconButton(icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more), onPressed: () {setState(() {_expanded = !_expanded;});},),
                  ]),
            ),
            if(_expanded) Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              height: 120,
              child: FutureBuilder(
                future: Provider.of<Reservation>(context, listen: false).getBookingsWhereUserNotIn(widget.gameId, Provider.of<Auth>(context, listen: false).userId),
                builder: (ctx, authResultSnapshot) => authResultSnapshot.connectionState == ConnectionState.waiting ? const Center(child: CircularProgressIndicator()) :
                Consumer<Reservation>(
                  builder: (ctx, reservations, child) => reservations.reservations.isNotEmpty ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: reservations.reservations.length,
                    itemBuilder:  (ctx, i) => ListTile(
                      title: Text(reservations.users.firstWhere((element) => element.userId == reservations.reservations[i].idUser).username),
                      subtitle: Text(t.reservations.dates(initDate: DateFormat.jm().format(reservations.reservations[i].initDate), endDate: DateFormat("HH:mm dd-MM").format(reservations.reservations[i].endDate)), style: const TextStyle(fontSize: 10),),
                      leading: CircleAvatar(child: Image.asset(t.image(avatar: reservations.users.firstWhere((element) => element.userId == reservations.reservations[i].idUser).userId))),
                      trailing: IconButton(icon: const Icon(Icons.edit_calendar), onPressed: () async {
                        try {
                          await Reservation().addUserToReservation(
                              reservations.reservations[i].idBooking, Provider
                              .of<Auth>(context, listen: false)
                              .userId);
                          Fluttertoast.showToast(msg: t.reservations.youIn(game: widget.name));
                          setState(() {});
                        } on GameFullException{
                          Fluttertoast.showToast(msg: GameFullException().toString());
                        } on GameNotOpenException{
                          Fluttertoast.showToast(msg: GameNotOpenException().toString());
                        } catch (error){
                          Fluttertoast.showToast(msg: error.toString());
                        }
                      },),
                    ),
                  ) : Text(t.reservations.notAnyReservation, textAlign: TextAlign.justify, style: const TextStyle(color: Colors.black54),),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
