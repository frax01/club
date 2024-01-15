import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:image_picker/image_picker.dart';
//import 'dart:io';
//import 'package:firebase_storage/firebase_storage.dart';

  //Future<String> uploadImage() async {
  //  try {
  //    // Ottieni un'immagine dall'utente (puoi scegliere tra galleria o fotocamera)
  //    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//
  //    if (pickedFile != null) {
  //      // Carica l'immagine su Firebase Storage
  //      Reference storageReference = FirebaseStorage.instance.ref().child('club_weekend/${DateTime.now().toIso8601String()}');
  //      UploadTask uploadTask = storageReference.putFile(File(pickedFile.path));
  //      await uploadTask.whenComplete(() => null);
//
  //      // Ottieni l'URL dell'immagine appena caricata
  //      String imageUrl = await storageReference.getDownloadURL();
  //      return imageUrl;
  //    } else {
  //      throw Exception('Nessuna immagine selezionata.');
  //    }
  //  } catch (e) {
  //    throw Exception('Errore durante il caricamento dell\'immagine: $e');
  //  }
  //}

class NewEventPage extends StatefulWidget {
  const NewEventPage({super.key, required this.title});

  final String title;

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<NewEventPage> {
  String title = '';
  String selectedOption = '';
  String imagePath = '';
  String selectedClass = '';
  String description = '';

  Future<void> createEvent() async {
    try {

      if (title == "") {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a title')));
        return;
      }
      if (selectedOption == "") {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select an option')));
        return;
      }
      if (selectedClass == "") {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a class')));
        return;
      }
      if (description == "") {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a description')));
        return;
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('football_$selectedOption').add({
        'title': title,
        'selectedOption': selectedOption,
        'imagePath': imagePath,
        'selectedClass': selectedClass,
        'description': description,
      });
      print('Evento creato con successo!');
      Navigator.pop(context);
    } catch (e) {
      print('Errore durante la creazione dell\'evento: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 130, 16, 8),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              onChanged: (value) {
                title = value;
              },
              decoration: InputDecoration(labelText: 'Titolo'),
            ),
            SizedBox(height: 16.0),
            DropdownButton<String>(
              value: selectedOption,
              onChanged: (value) {
                setState(() {
                  selectedOption = value!;
                });
              },
              items: ['', 'tournaments', 'extra']
                  .map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              hint: Text('Seleziona un\'opzione'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                //String imageUrl = await event.uploadImage();
                //// Aggiorna il percorso dell'immagine nel tuo oggetto evento
                //setState(() {
                //  event.imagePath = imageUrl;
                //});
                // Implementa la logica per caricare un'immagine
                // Puoi utilizzare il pacchetto image_picker per questo
                // https://pub.dev/packages/image_picker
                // Aggiorna il percorso dell'immagine nel tuo oggetto evento
              },
              child: Text('Carica Immagine'),
            ),
            SizedBox(height: 16.0),
            DropdownButton<String>(
              value: selectedClass,
              onChanged: (value) {
                setState(() {
                  selectedClass = value!;
                });
              },
              items: ['', '1st', '2nd', '3rd', '1st hs', '2nd hs', '3rd hs', '4th hs', '5th hs']
                  .map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              hint: Text('Seleziona un\'opzione'),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              onChanged: (value) {
                description = value;
              },
              decoration: InputDecoration(labelText: 'Testo'),
              maxLines: null,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await createEvent();
              },
              child: Text('Crea'),
            ),
          ],
        ),
      ),
    );
  }
}