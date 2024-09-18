import 'package:cx_playground/screens/manage_reservations_admin_screen.dart';
import 'package:cx_playground/widgets/reserve_widget_my_reservations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../i18n/strings.g.dart';
import '../models/reservations_mode.dart';
import '../providers/auth.dart';
import '../providers/reservation.dart';
import '../widgets/app_bar_with_back_button.dart';

///Alert dialog for [Reservation] deleting or leaving
showAlertDialog(BuildContext context, String bookingId, Function setState) {
  Widget cancelButton = TextButton(
    child: Text(t.yesNo.no),
    onPressed:  () {Navigator.of(context).pop();},
  );
  Widget continueButton = TextButton(
    child: Text(t.yesNo.yes),
    onPressed:  () async {
      await Reservation().deleteReservation(bookingId, Provider.of<Auth>(context, listen: false).userId);
      setState(() {}); Navigator.of(context).pop(true);
      },
  );
  AlertDialog alert = AlertDialog(
    title: Text(t.usersAdmin.delete),
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

///Class responsible to display a screen with all [Reservation]s a user can manage
class ManageReservationsScreen extends StatefulWidget {
  const ManageReservationsScreen({Key? key}) : super(key: key);

  @override
  State<ManageReservationsScreen> createState() => _ManageReservationsScreenState();
}

///State of [ManageReservationScreen]
class _ManageReservationsScreenState extends State<ManageReservationsScreen> {
  ReservationsMode reservationsMode = ReservationsMode.all;
  ///Main widget of [ManageReservationScreen]
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBarWithBackButton().build(context),
      floatingActionButton: Provider.of<Auth>(context, listen: false).isAdmin ? FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageReservationsAdminScreen()));
          setState((){});
        },
        child: const Icon(Icons.edit_calendar),
      ) : null,
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
        child: Column(
          children: [
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 20,),
                TextButton(onPressed: () {
                  setState(() {
                    reservationsMode = ReservationsMode.all;
                  });
                }, style: ButtonStyle(backgroundColor: reservationsMode == ReservationsMode.all ? MaterialStateProperty.all(const Color.fromRGBO(241, 83, 126, 1).withOpacity(1)) : MaterialStateProperty.all(Colors.white)),
                    child: Text(t.reservations.all)),
                TextButton(onPressed: () {
                  setState(() {
                    reservationsMode = ReservationsMode.myReservations;
                  });
                }, style: ButtonStyle(backgroundColor: reservationsMode == ReservationsMode.myReservations ? MaterialStateProperty.all(const Color.fromRGBO(241, 83, 126, 1).withOpacity(1)) : MaterialStateProperty.all(Colors.white)),
                    child: Text(t.reservations.myReservations)),
                TextButton(onPressed: () {
                  setState(() {
                    reservationsMode = ReservationsMode.participating;
                  });
                }, style: ButtonStyle(backgroundColor: reservationsMode == ReservationsMode.participating ? MaterialStateProperty.all(const Color.fromRGBO(241, 83, 126, 1).withOpacity(1)) : MaterialStateProperty.all(Colors.white)),
                    child: Text(t.reservations.participating)),
                const SizedBox(width: 20,)
              ],
            ),
            Center(
              child: SizedBox(
                  height: deviceSize.height - 210,
                  width: deviceSize.width - 40,
                  child: FutureBuilder(
                    future: Provider.of<Reservation>(context).getAllReservationsUser(Provider.of<Auth>(context, listen: false).userId, reservationsMode),
                    builder: (ctx, dataSnapshot) {
                      if (dataSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        if (dataSnapshot.error != null) {
                          return Center(
                            child: Text(t.error.anErrorOccurred),
                          );
                        } else {
                          return Consumer<Reservation>(
                            builder: (ctx, reservationsData, child) => ListView.builder(
                              itemCount: reservationsData.reservations.length,
                              itemBuilder: (ctx, i) => reservationsData.reservations[i].isAuthor ? Slidable(
                                actionPane: const SlidableDrawerActionPane(),
                                actionExtentRatio: 0.25,
                                actions: [
                                  IconSlideAction(
                                    caption: t.usersAdmin.delete,
                                    color: Theme.of(context).errorColor,
                                    icon: Icons.delete,
                                    onTap: () {showAlertDialog(context, reservationsData.reservations[i].idBooking, setState);},
                                  )
                                ],
                                child: ReserveWidgetMyReservations(reservationsData.reservations[i]),
                              ) :  Slidable(
                                actionPane: const SlidableDrawerActionPane(),
                                actionExtentRatio: 0.25,
                                actions: [
                                  IconSlideAction(
                                    caption: t.reservations.leave,
                                    color: Theme.of(context).errorColor,
                                    icon: Icons.cancel_rounded,
                                    onTap: () {showAlertDialog(context, reservationsData.reservations[i].idBooking, setState);},
                                  )
                                ],
                                child: ReserveWidgetMyReservations(reservationsData.reservations[i]),
                              ),
                            ),
                          );
                        }
                      }
                    },
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }
}
