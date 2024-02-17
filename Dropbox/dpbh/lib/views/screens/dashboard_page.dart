import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services.dart';
import 'details_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  int totalCount = 0; // Initialize with a default value
  late List<String> domains = [];
  late bool isLoading = true; // Add loading indicator
  late Map<String, dynamic> data; // Add data variable

  late AnimationController _animationController;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _animationController.forward();

    // Fetch domains and total count from the server
    _fetchData();
  }

  // Function to fetch domains and total count
  void _fetchData() async {
    try {
      data = await Services.fetchDomainsAndCounts(); // Assign data
      setState(() {
        totalCount = data['counts'].values.fold(0, (prev, curr) => prev + curr['total_count']);
        domains = data['domains'];
        isLoading = false; // Turn off loading indicator
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false; // Turn off loading indicator in case of error
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dark Pattern Detector - Clocktantra'),
      ),
      body: Stack(
        children: [
          SvgPicture.asset(
            'assets/your_image.svg', // Add your SVG asset path
            fit: BoxFit.cover,
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Center(
                  child: Text(
                    'Total Dark Patterns Detected',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ),
                Center(
                  child: isLoading
                      ? CircularProgressIndicator() // Show loading indicator while fetching data
                      : TweenAnimationBuilder<int>(
                    duration: Duration(seconds: 2),
                    tween: IntTween(begin: 0, end: totalCount),
                    builder: (BuildContext context, int value, Widget? child) {
                      return Text(
                        '$value',
                        style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: value > 50 ? Colors.red : Colors.black), // Change text color based on severity
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Site-wise Data:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: isLoading
                      ? Center(child: CircularProgressIndicator()) // Show loading indicator while fetching data
                      : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: 3.0, // Adjust aspect ratio for better display
                    ),
                    itemCount: domains.length,
                    itemBuilder: (context, index) {
                      final domain = domains[index];
                      final total = data['counts'][domain]['total_count'];
                      final severityColor = total > 50 ? Colors.red : Colors.black; // Determine severity color

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsPage(site: domain),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 2.0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  domain.split('.')[1], // Show only the domain name between two dots
                                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'Dark pattern count: ',
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                    Text(
                                      total.toString(),
                                      style: TextStyle(color: severityColor), // Apply severity color
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'Severity: ',
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                    Text(
                                      total > 50 ? 'High' : 'Low',
                                      style: TextStyle(color: severityColor), // Apply severity color
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
