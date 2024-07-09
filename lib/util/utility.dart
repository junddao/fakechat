import 'package:url_launcher/url_launcher.dart';

class Utility {
  static final Utility _singleton = Utility._internal();

  factory Utility() {
    return _singleton;
  }

  Utility._internal();

  Future<void> launcherURl(String? url) async {
    Uri uri = Uri.parse(url ?? '');
    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $uri');
    }
  }
}
