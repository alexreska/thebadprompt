import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'The Bad Prompt'**
  String get appTitle;

  /// No description provided for @joinTheCollective.
  ///
  /// In en, this message translates to:
  /// **'Join the Collective'**
  String get joinTheCollective;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  /// No description provided for @enterYourAlias.
  ///
  /// In en, this message translates to:
  /// **'Enter your alias...'**
  String get enterYourAlias;

  /// No description provided for @joinQueue.
  ///
  /// In en, this message translates to:
  /// **'JOIN QUEUE'**
  String get joinQueue;

  /// No description provided for @viewArchive.
  ///
  /// In en, this message translates to:
  /// **'VIEW ARCHIVE'**
  String get viewArchive;

  /// No description provided for @greatContribution.
  ///
  /// In en, this message translates to:
  /// **'Great Contribution! Go again?'**
  String get greatContribution;

  /// No description provided for @turnExpired.
  ///
  /// In en, this message translates to:
  /// **'Turn Expired. Try again?'**
  String get turnExpired;

  /// No description provided for @limitReached.
  ///
  /// In en, this message translates to:
  /// **'Limit reached or Line full?'**
  String get limitReached;

  /// No description provided for @youArePosition.
  ///
  /// In en, this message translates to:
  /// **'You are #{position} in line'**
  String youArePosition(int position);

  /// No description provided for @holdTight.
  ///
  /// In en, this message translates to:
  /// **'Hold tight...'**
  String get holdTight;

  /// No description provided for @prepareYourWord.
  ///
  /// In en, this message translates to:
  /// **'Prepare your word...'**
  String get prepareYourWord;

  /// No description provided for @turnOver.
  ///
  /// In en, this message translates to:
  /// **'TURN OVER!'**
  String get turnOver;

  /// No description provided for @yourTurn.
  ///
  /// In en, this message translates to:
  /// **'YOUR TURN! {seconds}s left'**
  String yourTurn(int seconds);

  /// No description provided for @oneWordOnly.
  ///
  /// In en, this message translates to:
  /// **'One Word Only'**
  String get oneWordOnly;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT'**
  String get submit;

  /// No description provided for @generatingArt.
  ///
  /// In en, this message translates to:
  /// **'Generating Art...'**
  String get generatingArt;

  /// No description provided for @errorGenerating.
  ///
  /// In en, this message translates to:
  /// **'Error Generating Image'**
  String get errorGenerating;

  /// No description provided for @archiveTitle.
  ///
  /// In en, this message translates to:
  /// **'ARCHIVE'**
  String get archiveTitle;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String error(String message);

  /// No description provided for @noArchivesYet.
  ///
  /// In en, this message translates to:
  /// **'No archives yet.'**
  String get noArchivesYet;

  /// No description provided for @createNewRoom.
  ///
  /// In en, this message translates to:
  /// **'Create New Room'**
  String get createNewRoom;

  /// No description provided for @roomName.
  ///
  /// In en, this message translates to:
  /// **'Room Name'**
  String get roomName;

  /// No description provided for @roomNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. The Chill Zone'**
  String get roomNameHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'CREATE'**
  String get create;

  /// No description provided for @createRoom.
  ///
  /// In en, this message translates to:
  /// **'CREATE ROOM'**
  String get createRoom;

  /// No description provided for @chooseRoomToJoin.
  ///
  /// In en, this message translates to:
  /// **'Choose a room to join'**
  String get chooseRoomToJoin;

  /// No description provided for @enterCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 4-letter Code'**
  String get enterCodeHint;

  /// No description provided for @noActiveRooms.
  ///
  /// In en, this message translates to:
  /// **'No active rooms.\nCreate one!'**
  String get noActiveRooms;

  /// No description provided for @unnamedRoom.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Room'**
  String get unnamedRoom;

  /// No description provided for @roomCodePrefix.
  ///
  /// In en, this message translates to:
  /// **'Code: {code}'**
  String roomCodePrefix(String code);

  /// No description provided for @startedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Started: {time}'**
  String startedPrefix(String time);

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'JOIN'**
  String get join;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'HOME'**
  String get navHome;

  /// No description provided for @navAccount.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get navAccount;

  /// No description provided for @navGallery.
  ///
  /// In en, this message translates to:
  /// **'GALLERY'**
  String get navGallery;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
