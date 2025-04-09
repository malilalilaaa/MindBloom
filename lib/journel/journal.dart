import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({Key? key}) : super(key: key);

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final TextEditingController _journalController = TextEditingController();

  final List<String> _entries = [];

  void _addEntry() {
    if (_journalController.text.trim().isEmpty) return;

    setState(() {
      _entries.add(_journalController.text.trim());
      _journalController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF302B4E),
      appBar: AppBar(
        title: Text('My Journal', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF7A5DC7),
        elevation: 4,
      ),
      body: Column(
        children: [
          Lottie.asset('assets/diary.json', height: 180, fit: BoxFit.contain),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _journalController,
              style: TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'What’s on your mind?',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Color(0xFF4B3F72),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _addEntry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF7A5DC7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text("Add Entry", style: TextStyle(color: Colors.white)),
          ),
          SizedBox(height: 20),
          Expanded(
            child:
                _entries.isEmpty
                    ? Center(
                      child: Text(
                        "No entries yet 📝",
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _entries.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Color(0xFF5C5470),
                          margin: EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              _entries[index],
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
