// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'The Bad Prompt';

  @override
  String get joinTheCollective => 'Join the Collective';

  @override
  String get yourName => 'Your Name';

  @override
  String get enterYourAlias => 'Enter your alias...';

  @override
  String get joinQueue => 'JOIN QUEUE';

  @override
  String get viewArchive => 'VIEW ARCHIVE';

  @override
  String get greatContribution => 'Great Contribution! Go again?';

  @override
  String get turnExpired => 'Turn Expired. Try again?';

  @override
  String get limitReached => 'Limit reached or Line full?';

  @override
  String youArePosition(int position) {
    return 'You are #$position in line';
  }

  @override
  String get holdTight => 'Hold tight...';

  @override
  String get prepareYourWord => 'Prepare your word...';

  @override
  String get turnOver => 'TURN OVER!';

  @override
  String yourTurn(int seconds) {
    return 'YOUR TURN! ${seconds}s left';
  }

  @override
  String get oneWordOnly => 'One Word Only';

  @override
  String get submit => 'SUBMIT';

  @override
  String get generatingArt => 'Generating Art...';

  @override
  String get errorGenerating => 'Error Generating Image';

  @override
  String get archiveTitle => 'ARCHIVE';

  @override
  String error(String message) {
    return 'Error: $message';
  }

  @override
  String get noArchivesYet => 'No archives yet.';

  @override
  String get createNewRoom => 'Create New Room';

  @override
  String get roomName => 'Room Name';

  @override
  String get roomNameHint => 'e.g. The Chill Zone';

  @override
  String get cancel => 'CANCEL';

  @override
  String get create => 'CREATE';

  @override
  String get createRoom => 'CREATE ROOM';

  @override
  String get chooseRoomToJoin => 'Choose a room to join';

  @override
  String get enterCodeHint => 'Enter 4-letter Code';

  @override
  String get noActiveRooms => 'No active rooms.\nCreate one!';

  @override
  String get unnamedRoom => 'Unnamed Room';

  @override
  String roomCodePrefix(String code) {
    return 'Code: $code';
  }

  @override
  String startedPrefix(String time) {
    return 'Started: $time';
  }

  @override
  String get join => 'JOIN';

  @override
  String get navHome => 'HOME';

  @override
  String get navAccount => 'ACCOUNT';

  @override
  String get navGallery => 'GALLERY';
}
