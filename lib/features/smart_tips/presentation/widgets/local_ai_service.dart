import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

class LocalAiService {
  static final LocalAiService _instance = LocalAiService._internal();
  factory LocalAiService() => _instance;
  LocalAiService._internal();

  bool _isModelReady = false;
  dynamic _activeChat;
  bool get isModelReady => _isModelReady;
  Future<void> initLocalAi() async {
    if (_isModelReady) return;
    try {
      await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
          .fromNetwork(
            'https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/Gemma3-1B-IT_multi-prefill-seq_q4_ekv4096.litertlm',
          )
          .install();

      final modelInstance = await FlutterGemma.getActiveModel(
        maxTokens: 512,
        preferredBackend: PreferredBackend.gpu,
      );
      _activeChat = await modelInstance.createChat();
      _isModelReady = true;
      debugPrint("Local AI model and engine session successfully initialized.");
    } catch (e) {
      debugPrint("Local AI inintialization failed: $e");
      _isModelReady = false;
    }
  }

  Future<String> summarizeArticle(String title, String content) async {
    if (!_isModelReady || _activeChat == null) {
      return "AI  Model is loading offline data...";
    }
    try {
      final prompt =
          "You are a poultry expert assistant. Summarize this African poultry news article in 2 bullet points.\nTitle: $title\nContent: $content";
      await _activeChat.addQueryChunk(Message.text(text: prompt, isUser: true));
      final response = await _activeChat.sendMessage();
      return response ?? "could not generate summary.";
    } catch (e) {
      return "Error processing summary:$e";
    }
  }
}
