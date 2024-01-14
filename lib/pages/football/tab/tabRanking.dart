import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';

class TabRanking extends StatefulWidget {
  const TabRanking({Key? key}) : super(key: key);

  @override
  _TabRankingState createState() => _TabRankingState();
}

class _TabRankingState extends State<TabRanking> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rankings'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('football_ranking').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          List<QueryDocumentSnapshot> rankings = snapshot.data!.docs;

          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: rankings.length,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemBuilder: (context, index) {
                    Map<String, dynamic> rankingData =
                        rankings[_currentPage].data() as Map<String, dynamic>;
                    List<Map<String, dynamic>> rankingList =List<Map<String, dynamic>>.from(rankingData['ranking']);

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Team: ${rankingData['team']}',
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold)),
                        SizedBox(height: 16.0),
                        Expanded(
                          child: ListView.builder(
                            itemCount: rankingList.length,
                            itemBuilder: (context, listViewIndex) {
                              return ListTile(
                                title:
                                    Text('Name: ${rankingList[listViewIndex]['name']}'),
                                subtitle: Text(
                                    'Score: ${rankingList[listViewIndex]['score']}'),
                              );
                            },
                          ),
                        ),
                        DotsIndicator(
                          dotsCount: rankings.length,
                          position: _currentPage.toDouble(),
                          decorator: DotsDecorator(
                            size: const Size.square(9.0),
                            activeSize: const Size(18.0, 9.0),
                            color: Colors.black26,
                            activeColor: Colors.black,
                            spacing: const EdgeInsets.all(3.0),
                          ),
                          onTap: (position) {
                            _pageController.animateToPage(
                              position.toInt(),
                              duration: Duration(milliseconds: 300), // Imposta la durata dell'animazione
                              curve: Curves.easeInOut, // Imposta la curva di animazione desiderata
                            );
                            setState(() {
                              _currentPage = position.toInt();
                            });
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}