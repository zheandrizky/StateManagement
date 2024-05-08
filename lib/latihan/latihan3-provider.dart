import 'package:flutter/material.dart'; // Import the material package for Flutter UI components.
import 'package:http/http.dart'
    as http; // Import the http package for making HTTP requests.
import 'dart:convert'; // Import the convert package for encoding and decoding JSON.
import 'package:provider/provider.dart'; // Import provider package for state management.

void main() {
  runApp(MyApp()); // Entry point of the application.
}

class University {
  // Define a class for University.
  final String name; // University name.
  final List<String> domains; // List of domains associated with the university.
  final List<String>
      webPages; // List of web pages associated with the university.

  University({
    // Constructor for University class.
    required this.name, // Required parameter: name.
    required this.domains, // Required parameter: domains.
    required this.webPages, // Required parameter: webPages.
  });

  factory University.fromJson(Map<String, dynamic> json) {
    // Factory method to create University object from JSON.
    return University(
      name: json['name'], // Initialize name from JSON.
      domains:
          List<String>.from(json['domains']), // Initialize domains from JSON.
      webPages: List<String>.from(
          json['web_pages']), // Initialize webPages from JSON.
    );
  }
}

class UniversityProvider extends ChangeNotifier {
  // Define a ChangeNotifier class for managing university data.
  late List<University> _universities; // List of universities.
  String _selectedCountry = 'Indonesia'; // Currently selected country.

  UniversityProvider() {
    // Constructor.
    _universities = []; // Initialize universities list.
    fetchUniversities(); // Fetch universities.
  }

  List<University> get universities =>
      _universities; // Getter for universities list.
  String get selectedCountry =>
      _selectedCountry; // Getter for selected country.

  set selectedCountry(String country) {
    // Setter for selected country.
    _selectedCountry = country; // Update selected country.
    fetchUniversities(); // Fetch universities for the newly selected country.
  }

  Future<void> fetchUniversities() async {
    // Method to fetch universities.
    final response = await http.get(Uri.parse(// Make HTTP GET request.
        'http://universities.hipolabs.com/search?country=$_selectedCountry'));
    if (response.statusCode == 200) {
      // If request is successful.
      List<dynamic> data = json.decode(response.body); // Decode JSON response.
      _universities = data
          .map((json) => University.fromJson(json))
          .toList(); // Map JSON data to University objects.
      notifyListeners(); // Notify listeners about the change in data.
    } else {
      // If request fails.
      throw Exception('Failed to load universities'); // Throw an exception.
    }
  }
}

class UniversityList extends StatelessWidget {
  // Define a stateless widget for displaying list of universities.
  @override
  Widget build(BuildContext context) {
    final universityProvider = Provider.of<UniversityProvider>(
        context); // Access UniversityProvider from the context.
    final universities =
        universityProvider.universities; // Get universities list from provider.

    if (universities.isEmpty) {
      // If universities list is empty.
      return Center(
          child: CircularProgressIndicator()); // Show loading indicator.
    } else {
      // If universities list is not empty.
      return ListView.builder(
        // ListView for displaying list of universities.
        itemCount: universities.length,
        itemBuilder: (context, index) {
          University university =
              universities[index]; // Get university at current index.
          return ListTile(
            // ListTile for displaying individual university.
            title: Text(university.name), // University name.
            subtitle: Text(university.webPages
                .first), // First web page associated with the university.
            onTap: () {
              // Handle onTap event
            },
          );
        },
      );
    }
  }
}

class MyApp extends StatelessWidget {
  // Define the main application widget.
  final List<String> aseanCountries = [
    // List of ASEAN countries.
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
  ];

  @override
  Widget build(BuildContext context) {
    // Build method for the main application widget.
    return ChangeNotifierProvider(
      // Provide the UniversityProvider to its descendants.
      create: (context) =>
          UniversityProvider(), // Create UniversityProvider instance.
      child: MaterialApp(
        // Material application widget.
        title: 'University List', // Title of the app.
        theme: ThemeData(
          // Theme for the app.
          primarySwatch: Colors.blue, // Primary color for the app.
        ),
        home: Scaffold(
          // Scaffold widget for the home screen.
          appBar: AppBar(
            // App bar for the home screen.
            title: Text('University List'), // Title of the app bar.
          ),
          body: Column(
            // Column to organize UI elements vertically.
            children: [
              Consumer<UniversityProvider>(
                // Consumer widget to listen for changes in UniversityProvider.
                builder: (context, universityProvider, child) {
                  // Builder method for Consumer widget.
                  return DropdownButton<String>(
                    // DropdownButton for selecting country.
                    value: universityProvider
                        .selectedCountry, // Current selected country.
                    onChanged: (String? newValue) {
                      // Method called when country is changed.
                      if (newValue != null) {
                        universityProvider.selectedCountry =
                            newValue; // Update selected country.
                      }
                    },
                    items: aseanCountries // Dropdown menu items.
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  );
                },
              ),
              Expanded(
                // Expanded widget to occupy remaining space.
                child:
                    UniversityList(), // UniversityList widget for displaying list of universities.
              ),
            ],
          ),
        ),
      ),
    );
  }
}
