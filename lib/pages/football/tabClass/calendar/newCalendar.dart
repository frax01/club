import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewCalendarPage extends StatefulWidget {
  const NewCalendarPage({super.key, required this.title, required this.level});
  final String level;
  final String title;

  @override
  _NewCalendarPageState createState() => _NewCalendarPageState();
}

class _NewCalendarPageState extends State<NewCalendarPage> {
  int numberOfMatches = 0;
  List<Map<String, dynamic>> matchDetails = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dettagli Evento - ${widget.level}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  numberOfMatches = int.tryParse(value) ?? 0;
                  matchDetails =
                      List.generate(numberOfMatches, (index) => {'': ''});
                });
              },
              decoration: const InputDecoration(
                labelText: 'Numero di partite',
              ),
            ),
            const SizedBox(height: 20),
            if (numberOfMatches > 0)
              Column(
                children: [
                  for (int i = 0; i < numberOfMatches; i++)
                    _buildTeamRow(i + 1, matchDetails[i]),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _confirmChanges,
                    child: const Text('Conferma'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamRow(int teamNumber, Map<String, dynamic> teamData) {
    String teamName = teamData.keys.first;
    String teamScore = teamData.values.first;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text('$teamNumber.'),
          const SizedBox(width: 16.0),
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  teamData.remove(teamName);
                  teamName = value;
                  teamData[teamName] = teamScore;
                });
              },
              decoration: const InputDecoration(labelText: 'Nome squadra'),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  teamScore = value;
                  teamData[teamName] = teamScore;
                });
              },
              decoration:
                  const InputDecoration(labelText: 'Squadra 2', hintText: '0'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmChanges() async {
    await FirebaseFirestore.instance
        .collection('football_calendar')
        .doc(widget.level)
        .set({
      'team': widget.level,
      'matches': matchDetails,
    });

    String opponent = "${matchDetails[0].keys.first} vs " + matchDetails[0].values.first;
    //String place = matchDetails[0].keys.first=="la nostra squadra"? 'CASA' : "";
    updateMatchDetails(widget.level, opponent);

    Navigator.pop(context);

    print('Changes confirmed');
  }

  void updateMatchDetails(String team, String opponent) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firestore
          .collection('football_match')
          .where('team', isEqualTo: team)
          .get();
      String documentId = querySnapshot.docs.first.id;
      await FirebaseFirestore.instance
          .collection('football_match')
          .doc(documentId)
          .update({
        'team': team,
        'opponent': opponent,
        'time': '',
      });
    } catch (e) {
      print('Error updating user details: $e');
    }
  }
}