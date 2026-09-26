import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';

class GoogleAuthService {
static final GoogleSignIn _googleSignIn = GoogleSignIn(
params: const GoogleSignInParams(
clientId:
'CLIENT_ID',
clientSecret:
'CLIENT_SECRET',
redirectPort: 8000,
scopes: [
'openid',
'profile',
'email',
],
),
);

// Allows the UI to listen for Google login/logout changes.
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
}