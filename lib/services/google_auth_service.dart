import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    params: GoogleSignInParams(
      clientId: dotenv.env['GOOGLE_CLIENT_ID']!,
      clientSecret: dotenv.env['GOOGLE_CLIENT_SECRET']!,
      redirectPort: 8000,
      scopes: [
        'openid',
        'profile',
        'email',

        // Google Calendar access
        'https://www.googleapis.com/auth/calendar',
      ],
    ),
  );

  static Stream<GoogleSignInCredentials?> get authenticationState =>
      _googleSignIn.authenticationState;

  static Future<void> initialize() async {
    // Nothing needs to be initialized here.
  }

  static Future<GoogleSignInCredentials?> signIn() async {
    try {
      print('GOOGLE: Starting sign in');

      final credentials = await _googleSignIn.signInOnline();

      print('GOOGLE: Sign in completed');

      print(
        'GOOGLE: ID token received = ${credentials?.idToken != null}',
      );

      print(
        'GOOGLE: Calendar access = '
            '${credentials?.scopes.contains(
          'https://www.googleapis.com/auth/calendar',
        )}',
      );

      return credentials;
    } catch (e) {
      print('GOOGLE ERROR: $e');
      return null;
    }
  }

  static Future<GoogleSignInCredentials?> silentSignIn() async {
    try {
      return await _googleSignIn.silentSignIn();
    } catch (e) {
      print('GOOGLE SILENT SIGN-IN ERROR: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  // Authenticated HTTP client for Google APIs
  static Future<dynamic> get authenticatedClient async {
    return await _googleSignIn.authenticatedClient;
  }
}