import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PhoneNumber? phone;
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    const initialCountryCode = 'US';
    var country =
        countries.firstWhere((element) => element.code == initialCountryCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Enter the Number',
            ),
            IntlPhoneField(
              autofocus: true,
              onSubmitted: (completePhoneNumber) {
                handleSubmit(phone);
              },
              onChanged: (value) {
                if (value.number.length >= country.minLength &&
                    value.number.length <= country.maxLength) {
                  phone = value;
                }
              },
              onCountryChanged: (country) => country = country,
              controller: controller,
              initialCountryCode: 'US',
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(borderSide: BorderSide()),
              ),
            ),
            ElevatedButton(
                onPressed: () => handleSubmit(phone),
                child: const Text("Submit"))
          ],
        ),
      ),
    );
  }

  void handleSubmit(PhoneNumber? number) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    if (controller.text.isNotEmpty) {
      print(number?.completeNumber);
      _auth.verifyPhoneNumber(
          phoneNumber: number?.completeNumber,
          verificationCompleted: _verificationCompleted,
          verificationFailed: _verificationFailed,
          codeSent: _codeSent,
          codeAutoRetrievalTimeout: _codeTimeout);
    }
  }

//once verification is completed, load the next page
  _verificationCompleted(PhoneAuthCredential authCredential) async {
    print('does this get activated');
  }

  _verificationFailed(FirebaseAuthException exception) {
    if (exception.code == 'invalid-phone-number') {
      print("Number Invalid");
    }
  }

  _codeSent(String verificationID, int? forceResendingToken) {
    print('verification id is $verificationID');
    print('forceresendingtoken is $forceResendingToken');
  }

  _codeTimeout(String timeout) {
    return null;
  }
}
