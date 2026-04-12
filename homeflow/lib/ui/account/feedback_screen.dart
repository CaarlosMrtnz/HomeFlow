import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 0; // Guardará el valor de 1 a 5
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitFeedback() async {
    // Validación básica
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a star rating.'),
          backgroundColor: Color(0xFFE57373),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('No active session.');

      // Inserción directa en la base de datos
      await Supabase.instance.client.from('feedback').insert({
        'user_id': userId,
        'rating': _rating,
        'description': _descriptionController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your feedback!'),
            backgroundColor: Color(0xFF71B9FD),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context); // Volvemos a la pantalla anterior
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: const Color(0xFFE57373)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5EDFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF203DA3)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Send Feedback',
          style: TextStyle(color: Color(0xFF203DA3), fontWeight: FontWeight.w800, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How is your experience with HomeFlow?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your feedback helps us improve the app.',
                style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 40),

              // Valoración
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      iconSize: 48,
                      icon: Icon(
                        index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: index < _rating ? const Color(0xFFFFD700) : const Color(0xFFBDB2FF),
                      ),
                      onPressed: () {
                        setState(() {
                          _rating = index + 1;
                        });
                      },
                    );
                  }),
                ),
              ),
              
              const SizedBox(height: 40),

              // Campo de texto
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8)),
                  ],
                ),
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 6, // Lo hace alto como una caja de comentarios
                  decoration: InputDecoration(
                    hintText: 'Tell us what you love or what could be better...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Botón submit
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF203DA3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Submit Feedback', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}