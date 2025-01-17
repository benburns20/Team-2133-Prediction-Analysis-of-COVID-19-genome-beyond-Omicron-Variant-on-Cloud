import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genome_2133/cards/skeleton.dart';
import 'package:genome_2133/tabs/faq.dart';
import 'package:genome_2133/tabs/login.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../cards/continent.dart';
import '../cards/country.dart';
import '../cards/variant.dart';
import '../main.dart';
import '../home.dart';
import 'contact.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _Settings();
}

class _Settings extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dict[theme].dialogBackgroundColor,
      body: SafeArea(
          child: Column(
            children: [
              Container(
                  color: dict[theme].secondaryHeaderColor,
                  child: Row(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.chevron_left,
                              size: MediaQuery.of(context).size.width / 30,
                              color: dict[theme].primaryColorLight,
                            ),
                          ),
                        ),
                        Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                "Settings",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 30,
                                    color: dict[theme].primaryColorLight
                                ),
                              ),
                            )
                        )
                      ]
                  )
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("User Info", style: TextStyle(fontSize: 24, color: dict[theme].primaryColor)),
                                      const Text("\n"),
                                      Text("Email: ${FirebaseAuth.instance.currentUser!.email!}", style: TextStyle(fontSize: 16, color: dict[theme].primaryColor)),
                                      const Text("\n"),
                                      Text("Account Created: ${DateFormat("MMMM d, yyyy").format(FirebaseAuth.instance.currentUser!.metadata.creationTime!)}", style: TextStyle(fontSize: 16, color: dict[theme].primaryColor)),
                                      const Text("\n"),
                                      Text("User ID: ${FirebaseAuth.instance.currentUser!.uid}", style: TextStyle(fontSize: 16, color: dict[theme].primaryColor)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Accessibility", style: TextStyle(fontSize: 24, color: dict[theme].primaryColor)),
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: ElevatedButton(
                                          onPressed: () => showDialog<String>(
                                            context: context,
                                            builder: (BuildContext context) => AlertDialog(
                                              title: Text('Color Options', style: TextStyle(color: dict[theme].primaryColor)),
                                              content: Text('Current theme: $theme', style: TextStyle(color: dict[theme].primaryColor)),
                                              actions: <Widget>[
                                                for (String caption in dict.keys)
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      theme = caption;
                                                      if (theme == "Dark Mode" && !isDesktop && !isMapDisabled) {
                                                        await DefaultAssetBundle.of(context).loadString('assets/data.json').then((string) {
                                                          mapController.setMapStyle(json.encode(json.decode(string)["Dark Mode"]));
                                                        });
                                                      }
                                                      context.findAncestorStateOfType<State<MyApp>>()!.setState(() {});
                                                      for (SkeletonCard currCard in windows) {
                                                        if (currCard.body is VariantCard) {
                                                          (currCard.body as VariantCard).controlKey.currentState!.updateState();
                                                        }else if (currCard.body is CountryCard) {
                                                          (currCard.body as CountryCard).controlKey.currentState!.updateState();
                                                        }else if (currCard.body is ContinentCard) {
                                                          (currCard.body as ContinentCard).controlKey.currentState!.updateState();
                                                        }
                                                      }
                                                      FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).update({"theme" : theme});
                                                      setState(() {});
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(caption,
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: dict[theme].primaryColor
                                                        )),
                                                  ),
                                              ],
                                            )),
                                          child: Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Text(
                                              "Change Color Scheme",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: dict[theme].primaryColor),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (!isDesktop)
                                        Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              setState((){
                                                isMapDisabled = !isMapDisabled;
                                              });
                                              FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).update({"map disabled" : isMapDisabled});
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.all(12),
                                              child: Text(
                                                isMapDisabled ? "Enable Map" : "Disable Map",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: dict[theme].primaryColor
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            setState((){
                                              context.findAncestorStateOfType<State<MyApp>>()!.setState(() {
                                                isDyslexic = !isDyslexic;
                                              });
                                              FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).update({"dyslexic" : isDyslexic});
                                            });
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Text(
                                              isDyslexic ? "Disable Dyslexic Font" : "Enable Dyslexic Font",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: dict[theme].primaryColor),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Account Management", style: TextStyle(fontSize: 24, color: dict[theme].primaryColor)),
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            await FirebaseAuth.instance.signOut().then((value) {
                                              context.findAncestorStateOfType<State<MyApp>>()!.setState(() {
                                                user = null;
                                                for (SkeletonCard currCard in windows) {
                                                  if (currCard.body is VariantCard) {
                                                    (currCard.body as VariantCard).controlKey.currentState!.updateState();
                                                  }else if (currCard.body is CountryCard) {
                                                    (currCard.body as CountryCard).controlKey.currentState!.updateState();
                                                  }else if (currCard.body is ContinentCard) {
                                                    (currCard.body as ContinentCard).controlKey.currentState!.updateState();
                                                  }
                                                }
                                              });
                                              Navigator.pop(context);
                                            });
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Text(
                                              "Log Out",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: dict[theme].primaryColor),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            await FirebaseAuth.instance.sendPasswordResetEmail(email: FirebaseAuth.instance.currentUser!.email!)
                                                .then((value) {
                                              showDialog<void>(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                  title: const Text("Password Reset Email Sent"),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: const Text('OK'),
                                                      onPressed: () => Navigator.pop(context),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            })
                                                .onError((error, stackTrace) {
                                              showDialog<void>(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                  title: Text("Error: $error"),
                                                  content: Text(stackTrace.toString()),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: const Text('OK'),
                                                      onPressed: () => Navigator.pop(context),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            });
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Text(
                                              "Reset Password",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: dict[theme].primaryColor),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            showDialog<void>(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: const Text("Are you sure?"),
                                                content: const Text("Account deletion is permanent."),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: const Text('NO'),
                                                    onPressed: () => Navigator.pop(context),
                                                  ),
                                                  TextButton(
                                                    child: const Text('YES'),
                                                    onPressed: () async {
                                                      Navigator.pop(context);

                                                      FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).delete().whenComplete(() async {
                                                        await FirebaseAuth.instance.currentUser!.delete().then((value) {
                                                          user = null;
                                                          Navigator.pop(context);
                                                          showDialog<void>(
                                                            context: context,
                                                            builder: (_) => const AlertDialog(
                                                              title: Text("Account Deleted"),
                                                            ),
                                                          );
                                                        })
                                                            .onError((error, stackTrace) {
                                                          if (error.toString() == "[firebase_auth/requires-recent-login] This operation is sensitive and requires recent authentication. Log in again before retrying this request.") {
                                                            showDialog<void>(
                                                              context: context,
                                                              builder: (_) => AlertDialog(
                                                                title: const Text("Expired Credentials"),
                                                                content: const Text("Log back in to continue account deletion."),
                                                                actions: <Widget>[
                                                                  TextButton(
                                                                    child: const Text('OK'),
                                                                    onPressed: () => Navigator.pop(context),
                                                                  ),
                                                                  TextButton(
                                                                    child: const Text('LOG OUT'),
                                                                    onPressed: () async {
                                                                      await FirebaseAuth.instance.signOut().then((value) {
                                                                        user = null;
                                                                        Navigator.pop(context);
                                                                        Navigator.pushReplacement(context, MaterialPageRoute(
                                                                            builder: (context) => const Login()));
                                                                      });
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                            return;
                                                          }
                                                          showDialog<void>(
                                                            context: context,
                                                            builder: (_) => AlertDialog(
                                                              title: Text("Error: $error"),
                                                              content: Text(stackTrace.toString()),
                                                              actions: <Widget>[
                                                                TextButton(
                                                                  child: const Text('OK'),
                                                                  onPressed: () => Navigator.pop(context),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        });
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Text(
                                              "Delete Account",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: dict[theme].primaryColor),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],

                                  ),
                                  Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Other", style: TextStyle(fontSize: 24, color: dict[theme].primaryColor)),
                                        Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              showDialog(
                                                  context: context, builder: (_) => contact(context));
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.all(12),
                                              child: Text(
                                                "Contact Us",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: dict[theme].primaryColor),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: ElevatedButton(
                                            onPressed: () => launchUrl(Uri.parse(
                                                'https://github.com/Fried-man/genome_2133#readme')),
                                            child: Padding(
                                              padding: EdgeInsets.all(12),
                                              child: Text(
                                                "Credits",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: dict[theme].primaryColor),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) => AlertDialog(
                                                  title: Text('Tools Used', style: TextStyle(color: dict[theme].primaryColor)),
                                                  content: SizedBox(
                                                    height: MediaQuery.of(context).size.height / 2,
                                                    width: MediaQuery.of(context).size.width / 4,
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                            "Packages",
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 15,
                                                                color: dict[theme].primaryColor
                                                            )
                                                        ),
                                                        for (String library in [
                                                          "another_flushbar",
                                                          "url_launcher",
                                                          "cupertino_icons",
                                                          "google_maps_flutter",
                                                          "google_maps_flutter_web",
                                                          "http",
                                                          "firebase_core",
                                                          "firebase_auth",
                                                          "auto_size_text",
                                                          "cloud_firestore",
                                                          "package_info_plus",
                                                          "google_fonts",
                                                          "provider",
                                                          "shared_preferences\n"
                                                        ])
                                                        RichText(
                                                            text: TextSpan(
                                                                text: "",
                                                                children: [
                                                                  TextSpan(
                                                                    text: "- ",
                                                                    style: TextStyle(
                                                                        color: dict[theme].primaryColor,
                                                                        fontSize: 15
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: library,
                                                                    recognizer: TapGestureRecognizer()..onTap = () {
                                                                      launchUrl(Uri.parse(
                                                                          'https://pub.dev/packages/$library'));
                                                                    },
                                                                    style: TextStyle(
                                                                        color: dict[theme].highlightColor,
                                                                        decoration: TextDecoration.underline,
                                                                        fontSize: 15
                                                                    ),
                                                                  )
                                                                ]
                                                            ),
                                                          ),
                                                        Text(
                                                          "APIs",
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 15,
                                                            color: dict[theme].primaryColor
                                                          )
                                                        ),
                                                        RichText(
                                                          text: TextSpan(
                                                              text: "",
                                                              children: [
                                                                TextSpan(
                                                                  text: "- ",
                                                                  style: TextStyle(
                                                                      color: dict[theme].primaryColor,
                                                                      fontSize: 15
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text: "REST Countries",
                                                                  recognizer: TapGestureRecognizer()..onTap = () {
                                                                    launchUrl(Uri.parse(
                                                                        'https://restcountries.com/'));
                                                                  },
                                                                  style: TextStyle(
                                                                      color: dict[theme].highlightColor,
                                                                      decoration: TextDecoration.underline,
                                                                      fontSize: 15
                                                                  ),
                                                                )
                                                              ]
                                                          ),
                                                        ),
                                                        Text(
                                                            "- In-House Azure API",
                                                          style: TextStyle(
                                                              color: dict[theme].primaryColor,
                                                              fontSize: 15
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                )
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Text(
                                                "Tools Used",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: dict[theme].primaryColor),
                                              ),
                                            ),
                                          ),
                                        )
                                        //const Text("\n\n\n"),
                                      ]
                                  )
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("FAQ", style: TextStyle(fontSize: 24, color: dict[theme].primaryColor)),
                                  FAQ(),
                                ],
                              ),
                            ],
                          )
                      )
                      ,
                    ),
                  ),
                )
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: FutureBuilder<String>(
                      future: getVersion(),
                      builder:
                          (BuildContext context, AsyncSnapshot<String> snapshot) {
                        return Text(
                          'Version: ${snapshot.hasData ? snapshot.data! : 'unknown'}',
                          style: TextStyle(
                            color: dict[theme].primaryColorLight,
                            fontSize: 16,
                          ),
                        );
                      }),
                ),
              ),
            ]
          )
      ),
    );
  }
}

class ThemeNotifier with ChangeNotifier {
  ThemeData _themeData;

  ThemeNotifier(this._themeData);

  getTheme() => _themeData; // to get current theme of the app

  setTheme(ThemeData themeData) async {
    _themeData = themeData;
    notifyListeners(); // to update the theme of the app
  }
}

Future<String> getVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return "v${packageInfo.version} (${packageInfo.buildNumber})";
}
