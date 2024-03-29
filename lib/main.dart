import 'package:club/pages/club/club.dart';
import 'package:club/pages/football/updateFootballEvent/footballModifier.dart';
import 'package:club/pages/football/tabClass/ranking/rankingEvent.dart';
import 'package:club/pages/main/signup.dart';
import 'package:club/pages/football/tabClass/match/matchEvent.dart';
import 'package:club/pages/football/tabClass/calendar/calendarEvent.dart';
import 'package:flutter/material.dart';
import 'pages/main/login.dart';
import 'pages/main/waiting.dart';
import 'pages/main/acceptance.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: Config.apiKey,
      authDomain: Config.authDomain,
      projectId: Config.projectId,
      storageBucket: Config.storageBucket,
      messagingSenderId: Config.messagingSenderId,
      appId: Config.appId,
    ),
  );

  deleteOldDocuments();

  firebaseMessaging();

  FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  _firebaseMessaging.requestPermission();
  //FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //  print('Got a message whilst in the foreground!');
  //  print('1');
  //  print('Message data: ${message.data}');
  //});

  initializeDateFormatting();

  runApp(const MyApp());
}

Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  print('Got a message whilst in the background!');
  print('0');
  print('Message data: ${message.data}');
}

void deleteOldDocuments() async {
  final firestore = FirebaseFirestore.instance;
  final today = DateTime.now();

  final oneDateCollections = [
    'club_extra',
    'club_weekend',
    'football_extra',
  ];
  for (final collection in oneDateCollections) {
    final querySnapshot = await firestore.collection(collection).get();
    for (final document in querySnapshot.docs) {
      final startDateString = document.data()['startDate'] as String;
      final startDate =
          DateTime.parse(startDateString.split('-').reversed.join('-'));
      if (startDate.isBefore(today)) {
        await document.reference.delete();
      }
    }
  }

  final twoDateCollections = [
    'club_summer',
    'club_trip',
    'football_tournament',
  ];
  for (final collection in twoDateCollections) {
    final querySnapshot = await firestore.collection(collection).get();
    for (final document in querySnapshot.docs) {
      final startDateString = document.data()['endDate'] as String;
      final startDate =
          DateTime.parse(startDateString.split('-').reversed.join('-'));
      if (startDate.isBefore(today)) {
        await document.reference.delete();
      }
    }
  }
}

void firebaseMessaging() {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  firebaseMessaging.requestPermission();
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');
  });

  FirebaseMessaging.instance.getToken().then((String? token) {
    assert(token != null);
    print('FCM Token: $token');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('it', 'IT'),
      ],
      title: 'Club App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.transparent),
        useMaterial3: true,
      ),
      home: const Login(
        title: 'Phoenix United',
      ),
      initialRoute: '/homepage',
      routes: {
        '/homepage': (context) => const HomePage(),
        '/login': (context) => const Login(title: 'Phoenix United'),
        '/signup': (context) => const SignUp(title: 'Phoenix United'),
        '/waiting': (context) => const Waiting(title: 'Phoenix United'),
        '/acceptance': (context) =>
            const AcceptancePage(title: 'Phoenix United'),
        '/football_modifier': (context) =>
            const FootballModifier(title: 'Phoenix United'),
        '/matchEvent': (context) =>
            const MatchEventPage(title: 'Phoenix United'),
        '/calendarEvent': (context) =>
            const CalendarEventPage(title: 'Phoenix United'),
        '/rankingEvent': (context) =>
            const RankingEventPage(title: 'Phoenix United'),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? email;

  Future<Map<String, dynamic>> retrieveData() async {
    CollectionReference user = FirebaseFirestore.instance.collection('user');
    QuerySnapshot querySnapshot1 =
        await user.where('email', isEqualTo: email).get();

    print("email: $email");

    Map<String, dynamic> document = {
      'name': querySnapshot1.docs.first['name'],
      'surname': querySnapshot1.docs.first['surname'],
      'email': querySnapshot1.docs.first['email'],
      'role': querySnapshot1.docs.first['role'],
      'club_class': querySnapshot1.docs.first['club_class'],
      'soccer_class': querySnapshot1.docs.first['soccer_class'],
      'status': querySnapshot1.docs.first['status'],
      'birthdate': querySnapshot1.docs.first['birthdate'],
      'id': querySnapshot1.docs.first.id,
    };

    return document;
  }

  //quando si fa il login con un nuovo utente bisogna mettere quello nella shared preferences

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email');

    Map<String, dynamic> allPrefs = prefs.getKeys().fold<Map<String, dynamic>>(
      {},
      (Map<String, dynamic> acc, String key) {
        acc[key] = prefs.get(key);
        return acc;
      },
    );

    print("SharedPreferences: $allPrefs");
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (email == null) {
      return const ClubPage(title: "Tiber Club", document: {
        'name': 'fra',
        'surname': 'marti',
        'email': 'framarti@gmail.com',
        'role': 'Boy',
        'club_class': '2° media',
        'soccer_class': 'intermediate',
        'status': 'Admin',
        'birthdate': 2024 - 01 - 16,
        'id': 'wJu0WDEgg75gYg91Ejl8'
      });
      //return const Login(title: "Asd Tiber Club");
    } else {
      print("ciaooo");
      return FutureBuilder<Map<String, dynamic>>(
          future: retrieveData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                backgroundColor: Colors.red,
                body: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset('images/logo.png'),
                        const SizedBox(height: 20.0),
                        const CircularProgressIndicator(),
                      ]),
                ),
              );
            } else if (snapshot.hasError) {
              return const Scaffold(
                body: Center(
                  child: Text("Errore durante il recupero dei dati."),
                ),
              );
            } else {
              Map<String, dynamic> document = snapshot.data ?? {};
              Future.delayed(Duration.zero, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ClubPage(title: "Tiber Club", document: document)));
              });
              return Container();
            }
          });
    }
  }
}
