/// Generated file. Do not edit.
///
/// Locales: 1
/// Strings: 116
///
/// Built on 2022-11-16 at 12:22 UTC


// coverage:ignore-file
// ignore_for_file: type=lint


import 'package:flutter/widgets.dart';
import 'package:slang_flutter/slang_flutter.dart';
export 'package:slang_flutter/slang_flutter.dart';

const AppLocale _baseLocale = AppLocale.en;

/// Supported locales, see extension methods below.
///
/// Usage:
/// - LocaleSettings.setLocale(AppLocale.en) // set locale
/// - Locale locale = AppLocale.en.flutterLocale // get flutter locale from enum
/// - if (LocaleSettings.currentLocale == AppLocale.en) // locale check
enum AppLocale with BaseAppLocale<_StringsEn> {
	en(languageCode: 'en', build: _StringsEn.build);

	const AppLocale({required this.languageCode, this.scriptCode, this.countryCode, required this.build}); // ignore: unused_element

	@override final String languageCode;
	@override final String? scriptCode;
	@override final String? countryCode;
	@override final TranslationBuilder<_StringsEn> build;

	/// Gets current instance managed by [LocaleSettings].
	_StringsEn get translations => LocaleSettings.instance.translationMap[this]!;
}

/// Method A: Simple
///
/// No rebuild after locale change.
/// Translation happens during initialization of the widget (call of t).
/// Configurable via 'translate_var'.
///
/// Usage:
/// String a = t.someKey.anotherKey;
/// String b = t['someKey.anotherKey']; // Only for edge cases!
_StringsEn get t => LocaleSettings.instance.currentTranslations;

/// Method B: Advanced
///
/// All widgets using this method will trigger a rebuild when locale changes.
/// Use this if you have e.g. a settings page where the user can select the locale during runtime.
///
/// Step 1:
/// wrap your App with
/// TranslationProvider(
/// 	child: MyApp()
/// );
///
/// Step 2:
/// final t = Translations.of(context); // Get t variable.
/// String a = t.someKey.anotherKey; // Use t variable.
/// String b = t['someKey.anotherKey']; // Only for edge cases!
class Translations {
	Translations._(); // no constructor

	static _StringsEn of(BuildContext context) => InheritedLocaleData.of<AppLocale, _StringsEn>(context).translations;
}

/// The provider for method B
class TranslationProvider extends BaseTranslationProvider<AppLocale, _StringsEn> {
	TranslationProvider({required super.child}) : super(
		initLocale: LocaleSettings.instance.currentLocale,
		initTranslations: LocaleSettings.instance.currentTranslations,
	);

	static InheritedLocaleData<AppLocale, _StringsEn> of(BuildContext context) => InheritedLocaleData.of<AppLocale, _StringsEn>(context);
}

/// Method B shorthand via [BuildContext] extension method.
/// Configurable via 'translate_var'.
///
/// Usage (e.g. in a widget's build method):
/// context.t.someKey.anotherKey
extension BuildContextTranslationsExtension on BuildContext {
	_StringsEn get t => TranslationProvider.of(this).translations;
}

/// Manages all translation instances and the current locale
class LocaleSettings extends BaseFlutterLocaleSettings<AppLocale, _StringsEn> {
	LocaleSettings._() : super(
		locales: AppLocale.values,
		baseLocale: _baseLocale,
		utils: AppLocaleUtils.instance,
	);

	static final instance = LocaleSettings._();

	// static aliases (checkout base methods for documentation)
	static AppLocale get currentLocale => instance.currentLocale;
	static Stream<AppLocale> getLocaleStream() => instance.getLocaleStream();
	static AppLocale setLocale(AppLocale locale) => instance.setLocale(locale);
	static AppLocale setLocaleRaw(String rawLocale) => instance.setLocaleRaw(rawLocale);
	static AppLocale useDeviceLocale() => instance.useDeviceLocale();
	static List<Locale> get supportedLocales => instance.supportedLocales;
	static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
	static void setPluralResolver({String? language, AppLocale? locale, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver}) => instance.setPluralResolver(
		language: language,
		locale: locale,
		cardinalResolver: cardinalResolver,
		ordinalResolver: ordinalResolver,
	);
}

/// Provides utility functions without any side effects.
class AppLocaleUtils extends BaseAppLocaleUtils<AppLocale, _StringsEn> {
	AppLocaleUtils._() : super(baseLocale: _baseLocale, locales: AppLocale.values);

	static final instance = AppLocaleUtils._();

	// static aliases (checkout base methods for documentation)
	static AppLocale parse(String rawLocale) => instance.parse(rawLocale);
	static AppLocale parseLocaleParts({required String languageCode, String? scriptCode, String? countryCode}) => instance.parseLocaleParts(languageCode: languageCode, scriptCode: scriptCode, countryCode: countryCode);
	static AppLocale findDeviceLocale() => instance.findDeviceLocale();
}

// translations

// Path: <root>
class _StringsEn implements BaseTranslations {

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsEn.build({PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: _cardinalResolver = cardinalResolver,
		  _ordinalResolver = ordinalResolver;

	/// Access flat map
	dynamic operator[](String key) => _flatMap[key];

	// Internal flat map initialized lazily
	late final Map<String, dynamic> _flatMap = _buildFlatMap();

	final PluralResolver? _cardinalResolver; // ignore: unused_field
	final PluralResolver? _ordinalResolver; // ignore: unused_field

	late final _StringsEn _root = this; // ignore: unused_field

	// Translations
	String get appName => 'CxPlayground';
	String get signUp => 'SignUp';
	String get signIn => 'SignIn';
	String get clickHere => 'Click Here';
	String get notAMember => 'Not a member? ';
	String get alreadyAMember => 'Already a member? ';
	String get ok => 'Ok';
	String get logout => 'LogOut';
	late final _StringsYesNoEn yesNo = _StringsYesNoEn._(_root);
	late final _StringsErrorEn error = _StringsErrorEn._(_root);
	late final _StringsUserDataEn userData = _StringsUserDataEn._(_root);
	String get edit => 'Edit';
	String get save => 'Save';
	String get asterisks => '******';
	String get deleteAccount => 'Delete Account';
	String get areUSure => 'Are you sure?';
	String get confirmPassword => 'Confirm Password';
	String image({required Object avatar}) => 'assets/images/avatar_$avatar.png';
	String get logo => 'assets/images/logoWithoutBackground.png';
	late final _StringsDeleteEn delete = _StringsDeleteEn._(_root);
	late final _StringsUsersAdminEn usersAdmin = _StringsUsersAdminEn._(_root);
	late final _StringsExceptionsEn exceptions = _StringsExceptionsEn._(_root);
	late final _StringsPagesEn pages = _StringsPagesEn._(_root);
	late final _StringsGamesEn games = _StringsGamesEn._(_root);
	late final _StringsCategoriesEn categories = _StringsCategoriesEn._(_root);
	late final _StringsGameEn game = _StringsGameEn._(_root);
	String get favourite => 'Favourite';
	String get join => 'Join';
	late final _StringsReservationsEn reservations = _StringsReservationsEn._(_root);
	late final _StringsTournamentsEn tournaments = _StringsTournamentsEn._(_root);
}

// Path: yesNo
class _StringsYesNoEn {
	_StringsYesNoEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get yes => 'Yes';
	String get no => 'No';
}

// Path: error
class _StringsErrorEn {
	_StringsErrorEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get anErrorOccurred => 'An error occurred';
	String get fail => 'Logged in failed';
	String get invalidUsername => 'Invalid Username';
	String get invalidEmail => 'Invalid Email';
	String get needPassword => 'You need a password.';
	String get passwordsNotMatch => 'Passwords do not match!';
	String get passwordNotValid => 'Password size should be bigger than 8 characters and smaller than 20, and contain at least one lower case letter, one uppercase letter, one digit and one special character like "*,_" ';
	String get unableAuthenticate => 'Unable to authenticate you now. Please try again later';
	String get unableNow => 'Unable to perform that operation right now. Please try again later';
	String get forgotPassword => 'Forgot your password? ';
	String get usernameTooLong => 'Username should be smaller than 16 characters';
	String get maximum => 'Maximum Reached';
	String get minimum => 'Minimum Reached';
}

// Path: userData
class _StringsUserDataEn {
	_StringsUserDataEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get username => 'Username';
	String get email => 'Email';
	String get password => 'Password';
	String get confirmPassword => 'Confirm Password';
	String usernameDyn({required Object username}) => 'Username: $username';
	String emailDyn({required Object email}) => 'Email: $email';
}

// Path: delete
class _StringsDeleteEn {
	_StringsDeleteEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get delete => 'Delete User';
	String areUSure({required Object userName}) => 'Are you sure you want to delete user $userName?\nThis operation is irreversible.';
}

// Path: usersAdmin
class _StringsUsersAdminEn {
	_StringsUsersAdminEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get delete => 'Delete';
	String get turnAdmin => 'Turn Admin';
	String get removeAdmin => 'Remove';
	String get turnAdminMessage => 'User is now Admin';
	String get removeAdminMessage => 'User removed from Admin';
	String get checkYourPage => 'See User';
}

// Path: exceptions
class _StringsExceptionsEn {
	_StringsExceptionsEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get operationNotAllowed => 'Operation not allowed!';
	String get adminPrivileges => 'You don\'t have administrator privileges';
	String get userDoesntExist => 'User doesn\'t exist.';
	String get incorrectPassword => 'You password is incorrect.';
	String get emailInUse => 'Your email is already registered. Please contact an administrator.';
	String get gameDoesntExist => 'Game doesn\'t exist.';
	String get reservationDoesntExist => 'Reservation doesn\'t exist.';
	String get gameFullException => 'This reservation is full!';
	String get gameNotOpenException => 'It\'s a private game... sorry!';
	String get notTournamentOwner => 'You are not the owner of this tournament!';
	String get teamFull => 'This team is full!';
	String get tournamentFull => 'This tournament is full!';
}

// Path: pages
class _StringsPagesEn {
	_StringsPagesEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get reservations => 'Reservations';
	String get myReservations => 'My Reservations';
	String get book => 'Book';
	String get tournament => 'Tournament';
	String get user => 'User';
	String get manageUsers => 'Users';
	String get manageGames => 'Games';
}

// Path: games
class _StringsGamesEn {
	_StringsGamesEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get lock => 'Lock';
	String get unlock => 'Unlock';
	String get lockMessage => 'Game locked';
	String get unlockMessage => 'Game unlocked';
	String get deleteGame => 'Delete Game';
	String areUSure({required Object game}) => 'Are you sure you want to delete the game $game?\nThis operations is irreversible.';
}

// Path: categories
class _StringsCategoriesEn {
	_StringsCategoriesEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get deleteCategory => 'Delete Category';
	String areUSure({required Object category}) => 'Are you sure you want to delete the category $category?\nThis operations is irreversible.';
}

// Path: game
class _StringsGameEn {
	_StringsGameEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get name => 'Name';
	String get duration => 'Duration';
	String get nMax => 'Players Max';
	String get nMin => 'Players Min';
	String get description => 'Description';
	String get isAvailable => 'Available';
	String get idCategory => 'Category';
	String get createCategory => 'Create Category';
	String get categoryName => 'Category Name';
	String get deleteCategory => 'Delete Category';
	String areUSureCategory({required Object category}) => 'Are you sure you want to delete $category category?';
	late final _StringsGameErrorEn error = _StringsGameErrorEn._(_root);
}

// Path: reservations
class _StringsReservationsEn {
	_StringsReservationsEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get openGame => 'Open Game';
	String get selectDate => 'Select a Day';
	String get startTime => 'Start Time';
	String get endTime => 'End Time';
	String get changeSlot => 'Change Slot';
	String get duration => 'Duration';
	String get addPlayers => 'Select other participants';
	String dates({required Object initDate, required Object endDate}) => '$initDate - $endDate';
	String get notAnyReservation => 'It seem like no one wants to play this game in open mode...\nCreate your open reservation now!';
	String get all => 'All';
	String get myReservations => 'My Reservations';
	String get participating => 'Participating';
	String get leave => 'Leave';
	String youIn({required Object game}) => 'You are now in that $game reservation';
}

// Path: tournaments
class _StringsTournamentsEn {
	_StringsTournamentsEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get selectDate => 'Select a Day';
	String get notAnyTournament => 'It seem like there is no tournament in this game...\nCreate a tournament now!';
	String get createYourTeam => 'Press here to create your team!';
	String get notAnyTeam => 'Not any team yet';
	String get numOfTeams => 'Number of Teams';
	String get numOfPlayers => 'Number of Players';
	String get selectAPeriod => 'Select a day or more';
	String get yourTeam => 'Your Team';
	String get youNeedATeam => 'Create your team!';
	String get myTournaments => 'My Tournaments';
}

// Path: game.error
class _StringsGameErrorEn {
	_StringsGameErrorEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String get cantBeNull => 'Can\'t be null.';
	String get moreTanOne => 'The game should take more than 1 minute!';
	String get nameTooLong => 'Should be lower than 15 characters.';
	String get tooShort => 'You need at least 1 player.';
	String get tooLong => 'Max allowed 10 players.';
	String get onlyInt => 'Only integers allowed.';
	String get descTooLong => 'Should be lower than 45 characters.';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on _StringsEn {
	Map<String, dynamic> _buildFlatMap() {
		return <String, dynamic>{
			'appName': 'CxPlayground',
			'signUp': 'SignUp',
			'signIn': 'SignIn',
			'clickHere': 'Click Here',
			'notAMember': 'Not a member? ',
			'alreadyAMember': 'Already a member? ',
			'ok': 'Ok',
			'logout': 'LogOut',
			'yesNo.yes': 'Yes',
			'yesNo.no': 'No',
			'error.anErrorOccurred': 'An error occurred',
			'error.fail': 'Logged in failed',
			'error.invalidUsername': 'Invalid Username',
			'error.invalidEmail': 'Invalid Email',
			'error.needPassword': 'You need a password.',
			'error.passwordsNotMatch': 'Passwords do not match!',
			'error.passwordNotValid': 'Password size should be bigger than 8 characters and smaller than 20, and contain at least one lower case letter, one uppercase letter, one digit and one special character like "*,_" ',
			'error.unableAuthenticate': 'Unable to authenticate you now. Please try again later',
			'error.unableNow': 'Unable to perform that operation right now. Please try again later',
			'error.forgotPassword': 'Forgot your password? ',
			'error.usernameTooLong': 'Username should be smaller than 16 characters',
			'error.maximum': 'Maximum Reached',
			'error.minimum': 'Minimum Reached',
			'userData.username': 'Username',
			'userData.email': 'Email',
			'userData.password': 'Password',
			'userData.confirmPassword': 'Confirm Password',
			'userData.usernameDyn': ({required Object username}) => 'Username: $username',
			'userData.emailDyn': ({required Object email}) => 'Email: $email',
			'edit': 'Edit',
			'save': 'Save',
			'asterisks': '******',
			'deleteAccount': 'Delete Account',
			'areUSure': 'Are you sure?',
			'confirmPassword': 'Confirm Password',
			'image': ({required Object avatar}) => 'assets/images/avatar_$avatar.png',
			'logo': 'assets/images/logoWithoutBackground.png',
			'delete.delete': 'Delete User',
			'delete.areUSure': ({required Object userName}) => 'Are you sure you want to delete user $userName?\nThis operation is irreversible.',
			'usersAdmin.delete': 'Delete',
			'usersAdmin.turnAdmin': 'Turn Admin',
			'usersAdmin.removeAdmin': 'Remove',
			'usersAdmin.turnAdminMessage': 'User is now Admin',
			'usersAdmin.removeAdminMessage': 'User removed from Admin',
			'usersAdmin.checkYourPage': 'See User',
			'exceptions.operationNotAllowed': 'Operation not allowed!',
			'exceptions.adminPrivileges': 'You don\'t have administrator privileges',
			'exceptions.userDoesntExist': 'User doesn\'t exist.',
			'exceptions.incorrectPassword': 'You password is incorrect.',
			'exceptions.emailInUse': 'Your email is already registered. Please contact an administrator.',
			'exceptions.gameDoesntExist': 'Game doesn\'t exist.',
			'exceptions.reservationDoesntExist': 'Reservation doesn\'t exist.',
			'exceptions.gameFullException': 'This reservation is full!',
			'exceptions.gameNotOpenException': 'It\'s a private game... sorry!',
			'exceptions.notTournamentOwner': 'You are not the owner of this tournament!',
			'exceptions.teamFull': 'This team is full!',
			'exceptions.tournamentFull': 'This tournament is full!',
			'pages.reservations': 'Reservations',
			'pages.myReservations': 'My Reservations',
			'pages.book': 'Book',
			'pages.tournament': 'Tournament',
			'pages.user': 'User',
			'pages.manageUsers': 'Users',
			'pages.manageGames': 'Games',
			'games.lock': 'Lock',
			'games.unlock': 'Unlock',
			'games.lockMessage': 'Game locked',
			'games.unlockMessage': 'Game unlocked',
			'games.deleteGame': 'Delete Game',
			'games.areUSure': ({required Object game}) => 'Are you sure you want to delete the game $game?\nThis operations is irreversible.',
			'categories.deleteCategory': 'Delete Category',
			'categories.areUSure': ({required Object category}) => 'Are you sure you want to delete the category $category?\nThis operations is irreversible.',
			'game.name': 'Name',
			'game.duration': 'Duration',
			'game.nMax': 'Players Max',
			'game.nMin': 'Players Min',
			'game.description': 'Description',
			'game.isAvailable': 'Available',
			'game.idCategory': 'Category',
			'game.createCategory': 'Create Category',
			'game.categoryName': 'Category Name',
			'game.deleteCategory': 'Delete Category',
			'game.areUSureCategory': ({required Object category}) => 'Are you sure you want to delete $category category?',
			'game.error.cantBeNull': 'Can\'t be null.',
			'game.error.moreTanOne': 'The game should take more than 1 minute!',
			'game.error.nameTooLong': 'Should be lower than 15 characters.',
			'game.error.tooShort': 'You need at least 1 player.',
			'game.error.tooLong': 'Max allowed 10 players.',
			'game.error.onlyInt': 'Only integers allowed.',
			'game.error.descTooLong': 'Should be lower than 45 characters.',
			'favourite': 'Favourite',
			'join': 'Join',
			'reservations.openGame': 'Open Game',
			'reservations.selectDate': 'Select a Day',
			'reservations.startTime': 'Start Time',
			'reservations.endTime': 'End Time',
			'reservations.changeSlot': 'Change Slot',
			'reservations.duration': 'Duration',
			'reservations.addPlayers': 'Select other participants',
			'reservations.dates': ({required Object initDate, required Object endDate}) => '$initDate - $endDate',
			'reservations.notAnyReservation': 'It seem like no one wants to play this game in open mode...\nCreate your open reservation now!',
			'reservations.all': 'All',
			'reservations.myReservations': 'My Reservations',
			'reservations.participating': 'Participating',
			'reservations.leave': 'Leave',
			'reservations.youIn': ({required Object game}) => 'You are now in that $game reservation',
			'tournaments.selectDate': 'Select a Day',
			'tournaments.notAnyTournament': 'It seem like there is no tournament in this game...\nCreate a tournament now!',
			'tournaments.createYourTeam': 'Press here to create your team!',
			'tournaments.notAnyTeam': 'Not any team yet',
			'tournaments.numOfTeams': 'Number of Teams',
			'tournaments.numOfPlayers': 'Number of Players',
			'tournaments.selectAPeriod': 'Select a day or more',
			'tournaments.yourTeam': 'Your Team',
			'tournaments.youNeedATeam': 'Create your team!',
			'tournaments.myTournaments': 'My Tournaments',
		};
	}
}
