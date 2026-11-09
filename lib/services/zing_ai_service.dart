import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

const String defaultZingAiEndpoint = 'https://zing-zone-ai.gyarasigujjar57.workers.dev';

class ZingAiResponse {
  final String answer, model, intent;
  final String? taskId;
  const ZingAiResponse({required this.answer, required this.model, required this.intent, this.taskId});
}

class ZingAiService {
  Future<ZingAiResponse> send({
    required List<Map<String, String>> messages,
    required String language,
    Map<String, dynamic>? profile,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    if (messages.isEmpty) throw Exception('Chat में कम-से-कम एक संदेश जरूरी है।');
    if (imageBytes != null && imageBytes.length > 5 * 1024 * 1024) throw Exception('AI image upload के लिए फोटो 5 MB से छोटी रखें।');
    final prefs = await SharedPreferences.getInstance();
    final endpoint = (prefs.getString('zing_ai_worker_url') ?? defaultZingAiEndpoint).trim();
    final uri = Uri.tryParse(endpoint);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) throw Exception('Zing AI server का HTTPS URL सही नहीं है। Settings में जाँचें।');
    final safeProfile = <String, String>{};
    for (final key in const ['displayName', 'state', 'district']) {
      final value = profile?[key];
      if (value is String && value.trim().isNotEmpty) {
        final clean = value.trim();
        safeProfile[key] = clean.substring(0, clean.length > 100 ? 100 : clean.length);
      }
    }
    final payload = <String, dynamic>{'messages': messages, 'language': language, 'profile': safeProfile};
    if (imageBytes != null) {
      final name = (imageName ?? '').toLowerCase();
      final mime = name.endsWith('.png') ? 'image/png' : name.endsWith('.webp') ? 'image/webp' : 'image/jpeg';
      payload['image'] = {'mimeType': mime, 'data': base64Encode(imageBytes)};
    }
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
    try {
      final request = await client.postUrl(uri).timeout(const Duration(seconds: 25));
      request.headers.contentType = ContentType.json;
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.write(jsonEncode(payload));
      final response = await request.close().timeout(const Duration(seconds: 65));
      final body = await response.transform(utf8.decoder).join().timeout(const Duration(seconds: 15));
      dynamic decoded;
      try { decoded = jsonDecode(body); } catch (_) { throw Exception('AI server ने सही JSON जवाब नहीं दिया।'); }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final error = decoded is Map ? decoded['error']?.toString() : null;
        if (response.statusCode == 429) throw Exception('AI server पर अभी अधिक requests हैं। थोड़ी देर बाद फिर कोशिश करें।');
        throw Exception(error ?? 'AI server HTTP ${response.statusCode}');
      }
      final answer = decoded is Map ? decoded['answer']?.toString().trim() : null;
      if (answer == null || answer.isEmpty) throw Exception('AI ने खाली जवाब दिया।');
      final intentData = decoded['intent'];
      final taskData = decoded['task'];
      return ZingAiResponse(
        answer: answer,
        model: decoded['model']?.toString() ?? 'unknown',
        intent: intentData is Map ? (intentData['kind']?.toString() ?? 'general_chat') : 'general_chat',
        taskId: taskData is Map ? taskData['id']?.toString() : null,
      );
    } on SocketException {
      throw Exception('Internet connection उपलब्ध नहीं है।');
    } on HttpException catch (e) {
      throw Exception('Network error: ${e.message}');
    } finally {
      client.close(force: true);
    }
  }
}
