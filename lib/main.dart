import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final Stream<QuerySnapshot> movies =
      FirebaseFirestore.instance.collection('movies').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Demo'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Retrieve Data from the Cloud Firestore',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              Container(
                  height: 350,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: movies,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Something went wrong.');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Loading...');
                      }
                      final data = snapshot.requireData;
                      return ListView.builder(
                          itemCount: data.size,
                          itemBuilder: (_, index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${index + 1}. ${data.docs[index]['name']}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '${data.docs[index]['description']}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey.shade600),
                                ),
                              ],
                            );
                          });
                    },
                  )
                  // ListView.builder(
                  //     itemCount: 2,
                  //     itemBuilder: (_, index) {
                  //       return Text('${index + 1}. Doctor Strange');
                  //     }),
                  ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Create Data to the Cloud Firestore',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              const MovieForm()
            ],
          ),
        ),
      ),
    );
  }
}

// Create a Form widget.
class MovieForm extends StatefulWidget {
  const MovieForm({super.key});

  @override
  MovieFormState createState() {
    return MovieFormState();
  }
}

class MovieFormState extends State<MovieForm> {
  final _formKey = GlobalKey<FormState>();

  String name = '', description = '';
  @override
  Widget build(BuildContext context) {
    final CollectionReference movies =
        FirebaseFirestore.instance.collection('movies');
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            // The validator receives the text that the user has entered.
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
            onChanged: (value) {
              name = value;
            },
            decoration: InputDecoration(
                icon: const Icon(Icons.movie),
                alignLabelWithHint: true,
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black.withOpacity(0.38), width: 2),
                    borderRadius: BorderRadius.circular(8)),
                errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(8)),
                focusedErrorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(8)),
                errorStyle: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .copyWith(fontSize: 12, color: Colors.red),
                labelText: 'Name *',
                hintText: 'Name',
                contentPadding: const EdgeInsets.all(19)),
          ),
          const SizedBox(height: 12),
          TextFormField(
            // The validator receives the text that the user has entered.
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
            onChanged: (value) {
              description = value;
            },
            enabled: true,
            decoration: InputDecoration(
                icon: const Icon(Icons.book),
                alignLabelWithHint: true,
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black.withOpacity(0.38), width: 2),
                    borderRadius: BorderRadius.circular(8)),
                errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(8)),
                focusedErrorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(8)),
                errorStyle: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .copyWith(fontSize: 12, color: Colors.red),
                labelText: 'Description *',
                hintText: 'Description',
                contentPadding: const EdgeInsets.all(19)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data...')),
                  );

                  movies
                      .add({'name': name, 'description': description})
                      .then(
                          (value) => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Movie Added!')),
                              ))
                      .catchError((error) =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Failed to add movie: $error')),
                          ));
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
