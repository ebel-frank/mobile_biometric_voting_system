import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../common/utils.dart';
import '../main.dart';
import '../models/user.model.dart';

class DataProvider with ChangeNotifier {
  DataState _state = DataState.idle;

  DataState get state => _state;

  void setState(DataState state) {
    _state = state;
    notifyListeners();
  }

  Future<String?> logIn({required String nin, required String password}) async {
    String? errorMsg;
    setState(DataState.login);
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Query the credential collection to find a matching nin and password
      QuerySnapshot credSnapshot = await firestore
          .collection("credential")
          .where("nin", isEqualTo: nin)
          .where("password", isEqualTo: password)
          .limit(1) // Since nin should be unique, we limit the result to 1
          .get();
      if (credSnapshot.docs.isNotEmpty) {
        // If a match is found, get the document ID
        DocumentSnapshot credDoc = credSnapshot.docs.first;
        String credentialId = credDoc.id;

        // Use the credential ID to get the corresponding user data
        DocumentSnapshot userDoc =
            await firestore.collection("users").doc(credentialId).get();
        final user = userDoc.data() as Map<String, dynamic>;
        DocumentSnapshot embedDoc = await firestore
            .collection("face_embeddings")
            .doc(credentialId)
            .get();
        final embedding = (embedDoc.data() as Map).map((key, value) {
          return MapEntry(int.parse(key), List<double>.from(value));
        });
        _saveUserData(user);
        saveFaceEmbedding(embedding);
      } else {
        errorMsg = "Invalid NIN or password.";
      }
    } catch (e) {
      errorMsg = e.toString();
    }

    setState(DataState.idle);
    return errorMsg;
  }

  Future<String?> register(
      {required String fullName,
      required String state,
      required String gender,
      required int dob,
      required String nin,
      required Map<int, List<double>> embeddings,
      required String imagePath,
      required String password}) async {
    String? errorMsg;
    setState(DataState.register);
    final regDate =
        DateTime.now().millisecondsSinceEpoch; // Date of registration
    final Map<String, dynamic> data = {
      "name": fullName,
      "state": state,
      "gender": gender,
      "dob": dob,
      "regDate": regDate,
      "isVerified": false,
      "hasVoted": false,
      "nin": nin
    };
    final Map<String, dynamic> credential = {
      "nin": nin,
      "password": password,
    };

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Query the credential collection to find a matching nin
      QuerySnapshot credSnapshot = await firestore
          .collection("credential")
          .where("nin", isEqualTo: nin)
          .limit(1) // Since nin should be unique, we limit the result to 1
          .get();
      if (credSnapshot.docs.isNotEmpty) {
        errorMsg = "NIN already exist. Please use your registered NIN";
      } else {
        await firestore.runTransaction((transaction) async {
          final DocumentReference credRef =
              firestore.collection("credential").doc();
          transaction.set(credRef, credential);

          data['imageUrl'] = await uploadImageToFirebaseStorage(
              await compress(imagePath),
              imagePath,
              credRef.id,
              'users_image/${credRef.id}.png');
          await _saveEmbeddingsToFirestore(credRef.id, embeddings);

          data["userId"] = credRef.id; // save userId in user data
          final DocumentReference userRef =
              firestore.collection("users").doc(credRef.id);
          transaction.set(userRef, data);

          // Update registered voters count
          incrementRegisteredVoters();
        });
        _saveUserData(data);
        saveFaceEmbedding(embeddings);
        errorMsg = null;
      }
    } catch (e) {
      // Handle errors appropriately here
      debugPrint("Error writing document: $e");
      errorMsg = e.toString();
    }
    setState(DataState.idle);
    return errorMsg;
  }

  void _saveUserData(Map<String, dynamic> user) async {
    Hive.box('cache').put('user', user);
  }

  void saveFaceEmbedding(Map<int, List<double>> embeddings) async {
    Hive.box('cache').put('face_embedding', embeddings);
  }

  User getUser() {
    return User.fromMap(Hive.box('cache').get('user'));
  }

  Map getFaceEmbeddings() {
    return Hive.box('cache').get('face_embedding');
  }

  logOut() async {
    // Clear user data
    for (final box in hiveBoxes) {
      await Hive.box(box['name'].toString()).clear();
    }
  }

  Future<void> incrementRegisteredVoters() async {
    final DatabaseReference ref =
        FirebaseDatabase.instance.ref('registeredVoters');

    // Read the current value
    DatabaseEvent dataSnapshot = await ref.once();
    int currentValue = (dataSnapshot.snapshot.value as int?) ?? 0;
    int newValue = currentValue + 1;

    // Write the new value
    await ref.set(newValue);
  }

  Future<String?> submitVote(List candidates) async {
    String? errorMsg;
    final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
    try {
      for (int i = 0; i < candidates.length; i++) {
        DatabaseReference candidateRef =
            dbRef.child('election/${candidates[i]['category']}/candidates');
        // Get the current list of candidates
        final DataSnapshot snapshot = await candidateRef.get();
        if (snapshot.exists) {
          for (var candidate in snapshot.children) {
            Map candidateData = candidate.value as Map;
            if (candidateData['name'] == candidates[i]['candidate']['party']) {
              // Update the votes value for the matching candidate
              await candidate.ref.update({'votes': candidateData['votes'] + 1});
              debugPrint('Votes updated successfully');
              break;
            }
          }
        } else {
          errorMsg = "Please check internet connection and try again";
        }
      }

      final user = getUser();
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection("users").doc(user.userId);
      // Update the "isVoted" field to true
      await userDocRef.update({
        "hasVoted": true,
      });
      user.hasVoted = true;
      _saveUserData(user.toMap());
    } catch (e) {
      errorMsg = e.toString();
    }
    return errorMsg;
  }

  _saveEmbeddingsToFirestore(
      String userId, Map<int, List<double>> embeddings) async {
    // Convert map to a serializable format
    Map<String, List<double>> dataToSave =
        embeddings.map((key, value) => MapEntry(key.toString(), value));

    await FirebaseFirestore.instance
        .collection('face_embeddings')
        .doc(userId)
        .set(dataToSave);

    debugPrint('Embeddings saved to Firestore');
  }
}

enum DataState { idle, loading, register, login }
