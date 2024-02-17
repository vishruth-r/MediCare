import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailsPage extends StatefulWidget {
  final String site;

  DetailsPage({required this.site});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late Map<String, dynamic> _siteData;

  @override
  void initState() {
    super.initState();
    _fetchSiteData(widget.site);
  }

  @override
  Widget build(BuildContext context) {
    final int totalDarkPatterns = _siteData['totalDarkPatterns'] ?? 0;
    final String severity = _siteData['severity'] ?? '';
    final List<Map<String, dynamic>> darkPatterns = _siteData['darkPatterns'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Dark Pattern Details - ${widget.site}'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Dark Patterns Detected:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TweenAnimationBuilder<int>(
                duration: Duration(seconds: 2),
                tween: IntTween(begin: 0, end: totalDarkPatterns),
                builder: (BuildContext context, int value, Widget? child) {
                  return Text(
                    '$value',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  );
                },
              ),
              SizedBox(height: 20),
              Text(
                'Severity: $severity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Dark Patterns:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: darkPatterns.length,
                itemBuilder: (context, index) {
                  final darkPattern = darkPatterns[index];
                  final name = darkPattern['name'];
                  final count = darkPattern['count'];
                  final description = darkPattern['description'];
                  final List<String> examples = darkPattern['examples'];

                  return DarkPatternCard(
                    name: name,
                    count: count,
                    description: description,
                    examples: examples,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to fetch data for the selected site
  void _fetchSiteData(String site) async {
    final String url = 'http://192.168.219.96:8000/inference_server/domain_results/?domain=$site';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print(response.body);
        setState(() {
          _siteData = jsonDecode(response.body);
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}

class DarkPatternCard extends StatefulWidget {
  final String name;
  final int count;
  final String description;
  final List<String> examples;

  DarkPatternCard({
    required this.name,
    required this.count,
    required this.description,
    required this.examples,
  });

  @override
  _DarkPatternCardState createState() => _DarkPatternCardState();
}

class _DarkPatternCardState extends State<DarkPatternCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _toggleExpansion,
          child: Card(
            elevation: 2.0,
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(widget.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TweenAnimationBuilder<int>(
                    duration: Duration(milliseconds: 500),
                    tween: IntTween(begin: 0, end: widget.count),
                    builder: (BuildContext context, int value, Widget? child) {
                      return Text('Count: $value');
                    },
                  ),
                  SizedBox(height: 5),
                  Text('Description: ${widget.description}'),
                ],
              ),
            ),
          ),
        ),
        SizeTransition(
          axisAlignment: 1.0,
          sizeFactor: _animation,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.examples.map((example) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  child: Text(example),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
