// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackkit/Screens/addkitscreen.dart';
import 'package:trackkit/Screens/detailpage.dart';
import 'package:trackkit/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeScreenUI extends StatefulWidget {
  const HomeScreenUI({Key? key}) : super(key: key);

  @override
  _HomeScreenUIState createState() => _HomeScreenUIState();
}

class _HomeScreenUIState extends State<HomeScreenUI> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  final database = FirebaseDatabase(
      databaseURL:
      "https://trackkit-a5cf3-default-rtdb.asia-southeast1.firebasedatabase.app")
      .reference()
      .child("NTU");

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
    return Scaffold(
      backgroundColor: const Color(0xFF21BFBD),
      body: Column(
        children: <Widget>[

          const SizedBox(height: 25.0),
          Padding(
            padding: const EdgeInsets.only(left: 40.0),
            child: Row(
              children: const <Widget>[
                Text('TracK',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0)),
                SizedBox(),
                Text('Kit',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontSize: 25.0))
              ],
            ),
          ),
          const SizedBox(height: 40.0),
          Container(
            height: MediaQuery.of(context).size.height - 185.0,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(75.0)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 45.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 300.0,
                child: StreamBuilder(
                  stream: database.onValue,
                  builder: (context, AsyncSnapshot<Event> snapshot) {
                    var lists = [];
                    if (snapshot.hasData &&
                        !snapshot.hasError &&
                        snapshot.data!.snapshot.value != null) {
                      print("Error on the way");
                      lists.clear();
                      DataSnapshot dataValues = snapshot.data!.snapshot;
                      Map<dynamic, dynamic> values = dataValues.value;
                      values.forEach((key, values) {
                        values["referenceName"] = key;
                        lists.add(values);
                      });
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: lists.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _buildItem(
                              'assets/Icon.png',
                              lists[index]["Place"].toString(),
                              lists[index]["referenceName"]);
                        },
                      );
                    }
                    return const Text("Add Kits");
                  },
                ),

              ),
            ),

          ),
          ElevatedButton(
            child: const Text('Add Items'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddKit()),
              );
            },
          ),
        ],


      ),
    );
  }

  Widget _buildItem(
      String imgPath,
      String labName,
      String referenceName,
      ) {
    return Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
        child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => detailsPage(
                      heroTag: imgPath,
                      foodName: labName,
                      referenceName: referenceName,
                    )),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(children: [
                  Hero(
                      tag: imgPath,
                      child: Image(
                          image: AssetImage(imgPath),
                          fit: BoxFit.cover,
                          height: 90.0,
                          width: 90.0)),
                  const SizedBox(width: 10.0),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(labName,
                            style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold)),
                      ]),

                ]),
              ],

            )));
  }
}