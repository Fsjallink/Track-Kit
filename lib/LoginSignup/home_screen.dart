import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackkit/Screens/addnewitem.dart';
import 'package:trackkit/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

var lists = [];

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, required this.referenceName}) : super(key: key);
  String referenceName;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final database = FirebaseDatabase(
            databaseURL:
                "https://trackkit-a5cf3-default-rtdb.asia-southeast1.firebasedatabase.app")
        .reference()
        .child('NTU')
        .child(widget.referenceName);
    return Scaffold(
      body: Column(
        children: <Widget>[
      StreamBuilder(
        stream: database.onValue,
        builder: (context, AsyncSnapshot<Event> snapshot) {
          if (snapshot.hasData &&
              !snapshot.hasError &&
              snapshot.data!.snapshot.value != null) {
            print("Error on the way");
            lists.clear();
            DataSnapshot dataValues = snapshot.data!.snapshot;
            Map<dynamic, dynamic> values = dataValues.value;
            values.forEach((key, values) {
              if (key == 'Place') return;
              lists.add(values);
            });
            return ListView.builder(
              shrinkWrap: true,
              itemCount: lists.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Item: " + lists[index]["Item"].toString()),
                      Text("Expiry Date: " +
                          lists[index]["Expiry Date"].toString()),
                      Text("Quantity: " +
                          lists[index]["Quantity"].toString()),
                    ],
                  ),
                );
              },
            );
          }
          return Container(child: const Text("Add Items"));
        },
      ),
      ElevatedButton(
        child: const Text('Add Items'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddItem(
                      referenceName: '',
                    )),
          );
        },
      ),
        ],
      ),
    );
  }
}
