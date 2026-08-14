import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // URL limpia y sin espacios hacia tu backend en Render
  static const String baseUrl = "https://talko-backend-b054.onrender.com";

  /// Verifica si el servidor backend y las APIs están activos (/health)
  static Future<bool> checkHealth() async {
    try {
      final url = Uri.parse('$baseUrl/health');
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['ok'] == true;
      }
    } catch (_) {}
    return false;
  }

  /// Envía el mensaje del usuario al personaje (/chat)
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

  /// Continúa la historia o narrativa de rol sin mensaje previo (/continue)
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

  /// Genera varias opciones de respuesta alternativas para elegir (estilo Talkie) (/regenerate)
  static Future<List<String>> regenerate({
    required Map<String, dynamic> character,
    required List<Map<String, dynamic>> history,
    String message = "",
    int count = 3,
  }) async {
    final url = Uri.parse('$baseUrl/regenerate');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'character': character,
        'history': history,
        'message': message,
        'count': count,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> choices = data['choices'] ?? [];
      return choices.map((e) => e.toString()).toList();
    } else {
      throw Exception('Error al regenerar respuestas: ${response.body}');
    }
  }

  /// Crea la ficha de un personaje nuevo mediante IA usando una idea básica (/generate-character)
  static Future<Map<String, dynamic>> generateCharacter(String idea) async {
    final url = Uri.parse('$baseUrl/generate-character');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idea': idea}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error al crear personaje: ${response.body}');
    }
  }

  /// Extrae los recuerdos clave del chat para guardarlos en la memoria a largo plazo (/memory)
  static Future<String> summarizeMemory({
    required Map<String, dynamic> character,
    required List<Map<String, dynamic>> history,
  }) async {
    final url = Uri.parse('$baseUrl/memory');
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
      return data['memory'] ?? '';
    } else {
      throw Exception('Error al guardar memoria: ${response.body}');
    }
  }
}
