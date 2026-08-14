import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Tu servidor en vivo en Render
  static const String baseUrl = "https://talko-backend-b054.onrender.com";

  /// Envía el mensaje del usuario al endpoint /chat de FastAPI
  static Future<String> sendMessage({
    required Map<String, dynamic> character,
    required List<Map<String, dynamic>> history,
    required String message,
  }) async {
    final url = Uri.parse('$baseUrl/chat');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'character': character,
        'history': history,
        'message': message,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['text'] ?? '';
    } else {
      throw Exception('Error en el servidor: ${response.body}');
    }
  }

  /// Continúa la historia automáticamente desde /continue
  static Future<String> continuePlot({
    required Map<String, dynamic> character,
    required List<Map<String, dynamic>> history,
  }) async {
    final url = Uri.parse('$baseUrl/continue');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'character': character,
        'history': history,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['text'] ?? '';
    } else {
      throw Exception('Error al continuar: ${response.body}');
    }
  }
}
