import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtController extends GetxController {
  var token = ''.obs;
  Future<String> generateToken(String username, String password) async {
    await dotenv.load(fileName: ".env.development");

    // Define the JWT payload
    final jwt = JWT({
      'username': username,
      'password': password,
      'iat': DateTime.now().millisecondsSinceEpoch, // Issued at
      'exp': DateTime.now()
          .add(Duration(hours: 1))
          .millisecondsSinceEpoch, // Expiry
    });

    // Sign the token using a secret key
    final secretKey = dotenv.env['SUPABASE_URL']!;
    final token = jwt.sign(SecretKey(secretKey));
    this.token.value = token;
    return token;
  }
}
