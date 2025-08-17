import 'package:onnx_translation/onnx_translation.dart';

class Translator {
  // Models
  late final OnnxModel _tlEnModel;
  late final OnnxModel _enCebModel;
  late final OnnxModel _cebEnModel;
  late final OnnxModel _enTlModel;

  bool _isInitialized = false;

  Translator();

  /// Initialize all 4 models. Call this once before using translation functions.
  Future<void> init() async {
    if (_isInitialized) return;

    _tlEnModel = OnnxModel();
    _enCebModel = OnnxModel();
    _cebEnModel = OnnxModel();
    _enTlModel = OnnxModel();

    try {
      // Tagalog → English
      await _tlEnModel.init(modelBasePath: 'assets/onnx_models/tl_en');

      // English → Cebuano
      await _enCebModel.init(modelBasePath: 'assets/onnx_models/en_ceb');

      // Cebuano → English
      await _cebEnModel.init(modelBasePath: 'assets/onnx_models/ceb_en');

      // English → Tagalog
      await _enTlModel.init(modelBasePath: 'assets/onnx_models/en_tl');

      _isInitialized = true;
      print('All models initialized successfully!');
    } catch (e) {
      print('Error initializing models: $e');
      rethrow;
    }
  }

  /// Translate Tagalog → Cebuano
  /// Uses TL → EN → CEB
  Future<String> filToCeb(String text) async {
    if (!_isInitialized) {
      throw Exception('Models not initialized. Call init() first.');
    }

    try {
      final english = await _tlEnModel.runModel(text);
      final cebuano = await _enCebModel.runModel(english);
      return cebuano;
    } catch (e) {
      print('Error in filToCeb: $e');
      rethrow;
    }
  }

  /// Translate Cebuano → Tagalog
  /// Uses CEB → EN → TL
  Future<String> cebToFil(String text) async {
    if (!_isInitialized) {
      throw Exception('Models not initialized. Call init() first.');
    }

    try {
      final english = await _cebEnModel.runModel(text);
      final tagalog = await _enTlModel.runModel(english);
      return tagalog;
    } catch (e) {
      print('Error in cebToFil: $e');
      rethrow;
    }
  }

  /// Optional: dispose models to free memory
  Future<void> dispose() async {
    // onnx_translation doesn't have explicit dispose, but if needed:
    // _tlEnModel.dispose();
    // _enCebModel.dispose();
    // _cebEnModel.dispose();
    // _enTlModel.dispose();
    _isInitialized = false;
  }
}
