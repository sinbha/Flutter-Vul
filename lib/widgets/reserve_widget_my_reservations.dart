import 'package:cx_playground/models/reserve_mode.dart';
import 'package:cx_playground/providers/users_admin.dart';
import 'package:cx_playground/widgets/user_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../i18n/strings.g.dart';
import '../providers/game.dart';
import '../providers/games.dart';
import '../providers/reservation.dart';
import '../screens/add_reservation_screen.dart';

///Widget used to represent a [Reservation] in the [CreateReservationScreen]
class ReserveWidgetMyReservations extends StatefulWidget {
  Reservation reservation = Reservation();

  ReserveWidgetMyReservations(this.reservation);

  @override
  State<ReserveWidgetMyReservations> createState() => _ReserveWidgetMyReservationsState();
}

///State of [ReserveWidgetMyReservations]
class _ReserveWidgetMyReservationsState extends State<ReserveWidgetMyReservations> {
  bool _expanded = false;

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
              title: Text(widget.reservation.gameName, style: const TextStyle(color: Colors.black54),),
              subtitle: Text(t.reservations.dates(initDate: DateFormat.jm().format(widget.reservation.initDate), endDate: DateFormat('hh:mm a dd-MM').format(widget.reservation.endDate))),
              trailing: Wrap(
                spacing: 12,
                children: [
                  if(widget.reservation.isAuthor) IconButton(onPressed: () async {
                        List<Game> games = await Games().getGamesFromServer();
                        Game game = games.firstWhere((element) => element.id == widget.reservation.game);
                        await widget.reservation.getPlayersReservation();
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => AddReservationScreen(ReservationMode.edit, game.id, game.name, game.nMax, widget.reservation))).then((value) => setState((){}));
                      }, icon: const Icon(Icons.edit)),
                  if(!widget.reservation.isAuthor) IconButton(icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more), onPressed: () {setState(() {_expanded = !_expanded;});},),
                ]),
            ),
            if(_expanded) FutureBuilder(
              future: Provider.of<UsersAdmin>(context, listen: false).getUsersFromServer(),
              builder: (ctx, authResultSnapshot) => authResultSnapshot.connectionState == ConnectionState.waiting ? const Center(child: CircularProgressIndicator()) :
              Consumer<UsersAdmin>(
                builder: (ctx, users, child) => UserWidget(
                  users.users.firstWhere((element) => element.userId == widget.reservation.idUser).userId,
                  users.users.firstWhere((element) => element.userId == widget.reservation.idUser).username,
                  users.users.firstWhere((element) => element.userId == widget.reservation.idUser).email,
                  users.users.firstWhere((element) => element.userId == widget.reservation.idUser).avatarNumber.toString(),
                  false,
                  true
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}
