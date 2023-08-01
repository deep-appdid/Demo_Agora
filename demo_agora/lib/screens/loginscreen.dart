import 'package:demo_agora/screens/failedalert.dart';
import 'package:demo_agora/screens/homepage.dart';
import 'package:demo_agora/screens/otpscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController phoneController = TextEditingController();

  void signInWithGoogle() async {
    // Trigger the authentication flow
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    // Obtain the auth details from the request
    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    print(userCredential.user?.displayName);

    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  Future<void> verifyPhoneNumber(
      String phoneNumber, BuildContext context) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await auth.verifyPhoneNumber(
      phoneNumber: '+91$phoneNumber',
      // Add the country code to the phone number
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieve the SMS code on Android devices
        await auth.signInWithCredential(credential);
        // You can navigate to the next screen here
        // (Optional: If you want to navigate to another screen, do it here)
      },
      verificationFailed: (FirebaseAuthException e) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const FailedAlertDialog();
          },
        );
      },
      codeSent: (String verificationId, int? resendToken) async {
        // Save the verificationId and navigate to the OTPScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              verificationId: verificationId,
              phoneNumber: phoneNumber,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Handle timeout (e.g., when the code auto-retrieval time has elapsed)
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.number,
                // Set the keyboard type to number
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                  // Limit the input to 10 characters
                ],
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.phone),
                  labelText: "Phone Number",
                  hintText: "Enter Phone Number",
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Center(
              child: FloatingActionButton.extended(
                onPressed: () {
                  signInWithGoogle();
                },
                icon: Image.asset(
                  "assets/images/google.png",
                  height: 32,
                  width: 32,
                ),
                label: const Text('Sign in with Google'),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            ElevatedButton(
                onPressed: () {
                  verifyPhoneNumber(
                    phoneController.text.trim(),
                    context,
                  );
                },
                child: const Text("Proceed")),
          ],
        ),
      ),
    );
  }
}
