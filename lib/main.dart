import 'package:flutter/material.dart';
import 'api_service.dart';

void main() {
  runApp(const TalkoApp());
}

class TalkoApp extends StatelessWidget {
  const TalkoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Talko AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF8B5CF6),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8B5CF6),
          secondary: Color(0xFFEC4899),
        ),
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Configuración inicial del personaje
  Map<String, dynamic> character = {
    "name": "Talkie Bot",
    "description": "Una compañera virtual amigable e interactiva.",
    "personality": "Cariñosa, curiosa, expresiva y detallista.",
    "story": "Vive en una dimensión digital interactuando con humanos.",
    "memory": ""
  };

  final List<Map<String, dynamic>> history = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      history.add({"role": "user", "text": text});
      _controller.clear();
      _isLoading = true;
    });

    try {
      final responseText = await ApiService.sendMessage(
        character: character,
        history: history,
        message: text,
      );

      setState(() {
        history.add({"role": "assistant", "text": responseText});
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _continueStory() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final responseText = await ApiService.continuePlot(
        character: character,
        history: history,
      );

      if (responseText.isNotEmpty) {
        setState(() {
          history.add({"role": "assistant", "text": responseText});
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFF8B5CF6),
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  character['name'] ?? 'Personaje',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'En línea (Render)',
                  style: TextStyle(fontSize: 12, color: Colors.greenAccent),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Continuar Historia',
            onPressed: _continueStory,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                final isUser = item['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF8B5CF6) : const Color(0xFF27272A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    child: Text(
                      item['text'] ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: const Color(0xFF1E1E24),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF8B5CF6)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
