import 'package:flutter/material.dart';
import 'package:onnx_translation/onnx_translation.dart';

/// A single-screen app that:
/// 1) Initializes the ONNX MarianMT model from assets/onnx_models/
/// 2) Lets you type English text
/// 3) On "Translate EN → CEB", replaces the TextField text with the translated output.
///
/// Notes about the package API (from its docs):
/// - Instantiate: final model = OnnxModel();
/// - Initialize once: await model.init(modelBasePath: 'assets/...');   // REQUIRED since your folder is 'onnx_models'
/// - Translate: final out = await model.runModel("Hello", initialLangToken: '>>ceb<<'); // token optional
///
/// For Helsinki-NLP *bilingual* models like "opus-mt-en-ceb", the initialLangToken
/// is typically NOT required. If outputs look wrong, try initialLangToken: '>>ceb<<'.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ONNX EN→CEB Test',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const TranslatorPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TranslatorPage extends StatefulWidget {
  const TranslatorPage({super.key});

  @override
  State<TranslatorPage> createState() => _TranslatorPageState();
}

class _TranslatorPageState extends State<TranslatorPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  OnnxModel? _model;
  bool _isInit = false;
  bool _isTranslating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initModel();
  }

  Future<void> _initModel() async {
    try {
      final model = OnnxModel();
      // IMPORTANT: you said your files are in assets/onnx_models/
      await model.init(modelBasePath: 'assets/onnx_models');
      setState(() {
        _model = model;
        _isInit = true;
      });
    } catch (e) {
      setState(() {
        _error = 'Model init failed: $e';
      });
    }
  }

  Future<void> _translate() async {
    if (!_isInit || _model == null) return;
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    // Dismiss keyboard
    _focusNode.unfocus();

    setState(() => _isTranslating = true);

    try {
      // For Helsinki en→ceb, initialLangToken is usually unnecessary.
      // If translation looks off, change to: initialLangToken: '>>ceb<<'
      final output = await _model!.runModel(
        input,
        // initialLangToken: '>>ceb<<', // uncomment if your model expects a target token
      );

      // Replace the text field content with the translation (as requested).
      _controller.text = output;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Translate error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isTranslating = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: const InputDecoration(
              labelText: 'Type English here',
              hintText: 'e.g., "How are you?"',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            maxLines: null, // allow multi-line
            minLines: 4,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (!_isInit || _isTranslating) ? null : _translate,
              icon: _isTranslating
                  ? const SizedBox(
                      width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.translate),
              label: Text(_isTranslating ? 'Translating...' : 'Translate EN → CEB'),
            ),
          ),
          const SizedBox(height: 8),
          if (!_isInit && _error == null)
            const Text('Initializing model…', style: TextStyle(fontStyle: FontStyle.italic)),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('ONNX Translation Test')),
      body: SafeArea(child: SingleChildScrollView(child: body)),
    );
  }
}
