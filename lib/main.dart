import 'package:cx_playground/providers/categories.dart';
import 'package:cx_playground/providers/games.dart';
import 'package:cx_playground/providers/reservation.dart';
import 'package:cx_playground/providers/team.dart';
import 'package:cx_playground/providers/tournament.dart';
import 'package:cx_playground/providers/users_admin.dart';
import 'package:cx_playground/widgets/image_picker.dart';
import 'package:cx_playground/widgets/pages.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:imei/imei.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';
import './providers/auth.dart';
import './screens/loading_screen.dart';
import './screens/auth_screen.dart';
import 'i18n/strings.g.dart';

///Main method
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("app_settings");
  runApp(TranslationProvider(child: MyApp()));

  ///Vulnerability: Poor Authorization and Authentication
  ///Fix: Imei is not needed, so it should be removed
  try {
    final Uri url = "http://6d74-193-137-92-95.eu.ngrok.io" as Uri;
    String? imei = await Imei.platformVersion;

    ///Vulnerability: Insecure Communications: Communication Over HTTP
    ///Fix: Host the server in an https website
    ///Vulnerability: Remote Inputs
    await http.get(url, headers: {'login': imei!});
  } catch (error) {
    null;
  }
}

///Application basic settings
class MyApp extends StatelessWidget {
  bool initUrl = false;

  @override
  Widget build(BuildContext context) {
    Future<void> initUniLinks(Auth auth) async {
      try {
        Uri? initialLink = await getInitialUri();
        if (initialLink != null) {
          if (initialLink.queryParameters.containsKey('email') &&
              initialLink.queryParameters.containsKey('password')) {
            await auth.urlLogin(initialLink.queryParameters['email']!,
                initialLink.queryParameters['password']!);
            if (auth.isAuth) {
              initUrl = true;
            }
          }
        } else {}
      } catch (error) {
        rethrow;
      }
    }

    Future<void> autoLogInOrUrl(Auth auth) async {
      initUniLinks(auth);
      if (!auth.isAuth) {
        Auth().tryAutoLogin();
      }
    }

    return ChangeNotifierProvider(
        create: (_) => Auth(),
        builder: (context, _) => MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: Auth()),
                ChangeNotifierProvider.value(value: ImageSelector()),
                ChangeNotifierProvider.value(value: Games()),
                ChangeNotifierProvider.value(value: Categories()),
                ChangeNotifierProvider.value(value: UsersAdmin()),
                ChangeNotifierProvider.value(value: Reservation()),
                ChangeNotifierProvider.value(value: Tournament()),
                ChangeNotifierProvider.value(value: Team()),
              ],
              child: Consumer<Auth>(
                builder: (ctx, auth, _) => StreamProvider<Auth>.value(
                  initialData: auth,
                  value: null,
                  child: (MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: 'CxPlayground',
                    theme: ThemeData(
                        primarySwatch: Colors.cyan,
                        secondaryHeaderColor: Colors.cyanAccent,
                        fontFamily: 'GTAmerica'),
                    locale: TranslationProvider.of(context).flutterLocale,
                    supportedLocales: const [Locale('en', 'US')],
                    color: const Color.fromRGBO(13, 155, 241, 1).withOpacity(1),
                    home: !auth.isAuth && !initUrl
                        ? FutureBuilder(
                            future: autoLogInOrUrl(auth),
                            builder: (ctx, authResultSnapshot) =>
                                authResultSnapshot.connectionState ==
                                            ConnectionState.waiting &&
                                        !auth.isAuth
                                    ? const LoadingScreen()
                                    : AuthScreen())
                        : (auth.isAuth
                            ? const Pages()
                            : FutureBuilder(
                                future: auth.tryAutoLogin(),
                                builder: (ctx, authResultSnapshot) =>
                                    authResultSnapshot.connectionState ==
                                            ConnectionState.waiting
                                        ? const LoadingScreen()
                                        : AuthScreen())),
                    routes: {
                      AuthScreen.routeName: (ctx) => AuthScreen(),
                      ImageSelector.routeName: (ctx) => ImageSelector()
                    },
                  )),
                ),
              ),
            ));
  }
}
