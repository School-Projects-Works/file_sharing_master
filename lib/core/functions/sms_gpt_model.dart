import 'package:http/http.dart' as http;


class SmsGptModel{

static const String baseUrl =
      'https://sms.arkesel.com/sms/api?action=send-sms&api_key=SmtPRE5HZk11Q3lKdHNGamJFRnE&to=PhoneNumber&from=SenderID&sms=YourMessage';

 static Future<bool> sendMessage(String phoneNumber, String message) async {
    try {
      final response = await http.get(Uri.parse(baseUrl
          .replaceFirst('PhoneNumber', phoneNumber)
          .replaceFirst('SenderID', 'FileNet')
          .replaceFirst('YourMessage', message)));
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

}