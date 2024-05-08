import 'package:flutter/material.dart'; // Import the material package for Flutter UI components.
import 'package:http/http.dart'
    as http; // Import the http package for making HTTP requests.
import 'dart:convert'; // Import the convert package for encoding and decoding JSON.
import 'package:flutter_bloc/flutter_bloc.dart'; // Import flutter_bloc for state management.

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

enum UniversityStatus {
  initial,
  loading,
  success,
  failure
} // Define an enum for different states of University fetching.

class UniversityCubit extends Cubit<UniversityStatus> {
  // Define a Cubit class for managing University state.
  final http.Client httpClient; // HTTP client for making requests.

  UniversityCubit(this.httpClient)
      : super(UniversityStatus
            .initial); // Constructor initializing the state to initial.

  Future<List<University>> fetchUniversities(String country) async {
    // Method to fetch universities based on country.
    emit(UniversityStatus.loading); // Emit loading state.
    try {
      final response = await httpClient.get(Uri.parse(// Make HTTP GET request.
          'http://universities.hipolabs.com/search?country=$country'));
      if (response.statusCode == 200) {
        // If request is successful.
        List<dynamic> data =
            json.decode(response.body); // Decode JSON response.
        emit(UniversityStatus.success); // Emit success state.
        return data
            .map((json) => University.fromJson(json))
            .toList(); // Map JSON data to University objects.
      } else {
        // If request fails.
        emit(UniversityStatus.failure); // Emit failure state.
        return []; // Return empty list.
      }
    } catch (_) {
      emit(UniversityStatus.failure); // Emit failure state if exception occurs.
      return []; // Return empty list.
    }
  }
}

class UniversityList extends StatefulWidget {
  // Define a stateful widget for displaying list of universities.
  @override
  _UniversityListState createState() =>
      _UniversityListState(); // Create state for UniversityList.
}

class _UniversityListState extends State<UniversityList> {
  // Define state for UniversityList widget.
  late UniversityCubit universityCubit; // Cubit for managing university state.
  late String selectedCountry; // Currently selected country.
  List<University> universities = []; // List of universities.

  @override
  void initState() {
    // Method called when the stateful widget is inserted into the tree.
    super.initState();
    universityCubit =
        UniversityCubit(http.Client()); // Initialize universityCubit.
    selectedCountry = 'Indonesia'; // Default selected country.
    universityCubit.fetchUniversities(selectedCountry).then((universities) {
      // Fetch universities for the selected country.
      setState(() {
        this.universities = universities; // Update universities list.
      });
    });
  }

  @override
  void dispose() {
    // Method called when the stateful widget is removed from the tree.
    universityCubit.close(); // Close the cubit to release resources.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Method to build the UI for UniversityList.
    return BlocBuilder<UniversityCubit, UniversityStatus>(
      bloc: universityCubit,
      builder: (context, state) {
        if (state == UniversityStatus.loading) {
          // If universities are being loaded.
          return Center(
              child: CircularProgressIndicator()); // Show loading indicator.
        } else if (state == UniversityStatus.failure) {
          // If loading fails.
          return Center(
              child: Text(
                  'Error: Failed to load universities')); // Show error message.
        } else if (state == UniversityStatus.success) {
          // If loading is successful.
          return Column(
            children: [
              DropdownButton<String>(
                // Dropdown for selecting country.
                value: selectedCountry, // Current selected country.
                onChanged: (String? newValue) {
                  // Method called when country is changed.
                  setState(() {
                    selectedCountry = newValue!; // Update selected country.
                  });
                  universityCubit
                      .fetchUniversities(
                          selectedCountry) // Fetch universities for the newly selected country.
                      .then((universities) {
                    setState(() {
                      this.universities =
                          universities; // Update universities list.
                    });
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
                child: ListView.builder(
                  // ListView for displaying list of universities.
                  itemCount: universities.length,
                  itemBuilder: (context, index) {
                    University university = universities[index];
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
                ),
              ),
            ],
          );
        } else {
          // For initial state.
          return Container(); // Return empty container for initial state.
        }
      },
    );
  }
}

class MyApp extends StatelessWidget {
  // Define the main application widget.
  @override
  Widget build(BuildContext context) {
    // Build method for the main application widget.
    return BlocProvider(
      // Provide the UniversityCubit to its descendants.
      create: (context) =>
          UniversityCubit(http.Client()), // Create UniversityCubit instance.
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
          body:
              UniversityList(), // Body of the home screen, displaying UniversityList widget.
        ),
      ),
    );
  }
}
