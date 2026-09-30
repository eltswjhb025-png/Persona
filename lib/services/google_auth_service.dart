import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

static Future<UserCredential?> signIn() async {
try {
print('GOOGLE: Starting sign in');

final GoogleSignInCredentials? credentials =
await _googleSignIn.signInOnline();

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

if (credentials == null) {
print('GOOGLE: No credentials received.');
return null;
}

if (credentials.idToken == null) {
print('GOOGLE: No ID token received.');
return null;
}

final OAuthCredential firebaseCredential =
GoogleAuthProvider.credential(
idToken: credentials.idToken,
accessToken: credentials.accessToken,
);

final UserCredential userCredential =
await FirebaseAuth.instance.signInWithCredential(
firebaseCredential,
);

print(
'FIREBASE: Google sign in successful '
'for ${userCredential.user?.email}',
);

return userCredential;
} catch (e) {
print('GOOGLE/FIREBASE ERROR: $e');
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
await FirebaseAuth.instance.signOut();
}

// Authenticated HTTP client for Google APIs
static Future<dynamic> get authenticatedClient async {
return await _googleSignIn.authenticatedClient;
}
}