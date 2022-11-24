import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../main.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _Settings();
}

class _Settings extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(children: [
            Stack(
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
                    ),
                  ),
                ),
                const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                          "Settings",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30
                          ),
                      ),
                    )
                )
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("User Info", style: TextStyle(fontSize: 24)),
                    Text("Email: " + FirebaseAuth.instance.currentUser!.email!, style: const TextStyle(fontSize: 16)),
                    Text("Account Created: " + DateFormat("MMMM d, yyyy").format(FirebaseAuth.instance.currentUser!.metadata.creationTime!), style: const TextStyle(fontSize: 16)),
                    Text("User ID: " + FirebaseAuth.instance.currentUser!.uid, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut().then((value) {
                    user = null;
                    Navigator.pop(context);
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Log Out",
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 50,
                        color: Colors.black),
                  ),
                ),
              ),
            ),
      ])),
    );
  }
}
