import 'package:flutter/material.dart';
import 'functions/translator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize translator before runApp
  await translator.init();

  runApp(MyApp());
}

// Create a global instance (using your initial translator.dart)
final translator = Translator();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Translator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TranslatorPage(),
    );
  }
}

class TranslatorPage extends StatefulWidget {
  @override
  _TranslatorPageState createState() => _TranslatorPageState();
}

class _TranslatorPageState extends State<TranslatorPage> {
  String _selectedLanguage = 'Tagalog'; // default dropdown value
  final TextEditingController _controller = TextEditingController();
  String _result = '';
  bool _isLoading = false;

  Future<void> _translate() async {
    final inputText = _controller.text.trim();
    if (inputText.isEmpty) return;

    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      String output;
      if (_selectedLanguage == 'Tagalog') {
        output = await translator.filToCeb(inputText);
      } else {
        output = await translator.cebToFil(inputText);
      }

      setState(() {
        _result = output;
      });
    } catch (e) {
      setState(() {
        _result = "❌ Error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tagalog ↔ Cebuano Translator")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown
            DropdownButton<String>(
              value: _selectedLanguage,
              items: ['Tagalog', 'Cebuano']
                  .map((lang) => DropdownMenuItem(
                        value: lang,
                        child: Text(lang),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
              },
            ),
            SizedBox(height: 16),

            // Input field
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Enter text in $_selectedLanguage",
              ),
            ),
            SizedBox(height: 16),

            // Translate button
            ElevatedButton(
              onPressed: _isLoading ? null : _translate,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Translate"),
            ),
            SizedBox(height: 24),

            // Output
            Text(
              "Result:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              _result,
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
