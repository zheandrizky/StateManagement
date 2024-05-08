import 'package:flutter/material.dart'; // Import the material package for Flutter UI components.
import 'package:http/http.dart'
    as http; // Import the http package for making HTTP requests.
import 'dart:convert'; // Import the convert package for encoding and decoding JSON.

class University {
  // Define a class for University.
  final String name; // University name.
  final String webPage; // Web page associated with the university.

  University(
      {required this.name,
      required this.webPage}); // Constructor for University class.

  factory University.fromJson(Map<String, dynamic> json) {
    // Factory method to create University object from JSON.
    return University(
      name: json['name'], // Initialize name from JSON.
      webPage: json['web_pages'][0], // Initialize webPage from JSON.
    );
  }
}

class UniversityBloc {
  // Define a class for managing university data.
  late final Stream<List<University>>
      universities; // Stream to emit list of universities.

  UniversityBloc(String country) {
    // Constructor.
    universities = _fetchUniversities(country)
        .asStream(); // Initialize universities stream.
  }

  Future<List<University>> _fetchUniversities(String country) async {
    // Method to fetch universities.
    final response = await http.get(// Make HTTP GET request.
        Uri.parse('http://universities.hipolabs.com/search?country=$country'));
    if (response.statusCode == 200) {
      // If request is successful.
      List<dynamic> data = json.decode(response.body); // Decode JSON response.
      return data
          .map((json) => University.fromJson(json))
          .toList(); // Map JSON data to University objects.
    } else {
      // If request fails.
      throw Exception('Failed to load universities'); // Throw an exception.
    }
  }
}

class UniversityListPage extends StatefulWidget {
  // Define a stateful widget for displaying list of universities.
  @override
  _UniversityListPageState createState() =>
      _UniversityListPageState(); // Create state for UniversityListPage.
}

class _UniversityListPageState extends State<UniversityListPage> {
  // Define state for UniversityListPage.
  late UniversityBloc bloc; // UniversityBloc instance.
  String selectedCountry = 'Indonesia'; // Default selected country.

  @override
  void initState() {
    // Method called when the widget is inserted into the tree.
    super.initState();
    bloc = UniversityBloc(selectedCountry); // Initialize UniversityBloc.
  }

  @override
  Widget build(BuildContext context) {
    // Build method for UniversityListPage widget.
    return Scaffold(
      // Scaffold widget for the UI layout.
      appBar: AppBar(
        // App bar for the UI.
        title: Text('University List'), // Title of the app bar.
      ),
      body: Column(
        // Column widget to arrange UI elements vertically.
        children: [
          DropdownButton<String>(
            // DropdownButton for selecting country.
            value: selectedCountry, // Current selected country.
            onChanged: (String? newValue) {
              // Method called when country selection changes.
              setState(() {
                // Update UI with the new state.
                selectedCountry = newValue!; // Update selected country.
                bloc = UniversityBloc(
                    selectedCountry); // Initialize UniversityBloc with new country.
              });
            },
            items: <String>[
              // Dropdown menu items.
              'Brunei Darussalam',
              'Cambodia',
              'Indonesia',
              'Laos',
              'Malaysia',
              'Myanmar',
              'Philippines',
              'Singapore',
              'Thailand',
              'Vietnam'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Expanded(
            // Expanded widget to occupy remaining space.
            child: StreamBuilder<List<University>>(
              // StreamBuilder for listening to universities stream.
              stream: bloc.universities, // Stream of universities data.
              builder: (context, snapshot) {
                // Builder method for StreamBuilder.
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // If data is still loading.
                  return Center(
                      child:
                          CircularProgressIndicator()); // Show loading indicator.
                } else if (snapshot.hasError) {
                  // If an error occurred.
                  return Center(
                      child: Text(
                          'Error: ${snapshot.error}')); // Show error message.
                } else {
                  // If data is available.
                  List<University> universities =
                      snapshot.data!; // Get list of universities from snapshot.
                  return ListView.builder(
                    // ListView for displaying list of universities.
                    itemCount: universities.length,
                    itemBuilder: (context, index) {
                      University university = universities[
                          index]; // Get university at current index.
                      return ListTile(
                        // ListTile for displaying individual university.
                        title: Text(university.name), // University name.
                        subtitle: Text(university
                            .webPage), // Web page associated with the university.
                        onTap: () {
                          // Handle onTap event
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  // Main method to run the application.
  runApp(MaterialApp(
    // Run the application with MaterialApp.
    title: 'University List', // Title of the application.
    theme: ThemeData(
      // Theme settings.
      primarySwatch: Colors.blue, // Primary color for the application.
    ),
    home: UniversityListPage(), // Set UniversityListPage as the home screen.
  ));
}
