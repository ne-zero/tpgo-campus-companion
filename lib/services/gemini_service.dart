import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/campus_location.dart';

// one message in the chat conversation
class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.isFromUser,
  });

  final String text;
  final bool isFromUser;
}

// handles calls to the Gemini API for the AI Tips chatbot
class GeminiService {
  // school project api key
  // for a real production app, this should not be stored in the client code
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  // models to try in order
  static const List<String> _models = [
    'gemini-3.5-flash-lite',
    'gemini-3.6-flash',
  ];

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  // builds a short instruction using the campus locations from firestore
  String _buildSystemInstruction(List<CampusLocation> locations) {
    final buffer = StringBuffer();

    buffer.writeln(
      'You are the TP Go! campus assistant for Temasek Polytechnic students. '
      'Keep answers short, friendly and useful. '
      'Use the real campus locations provided below whenever relevant. '
      'Do not make up locations that are not in the list. '
      'If a location is closed or under renovation, clearly warn the user.'
      'Do not use markdown formatting.'
      'Do not use asterisks, hashtags, bullet markdown, or bold syntax.'
      'Return clean plain text only.',
    );

    buffer.writeln();

    buffer.writeln('Campus locations:');

    for (final location in locations) {
      buffer.writeln(
        '- ${location.name} | '
        'category: ${location.category} | '
        'status: ${location.status} | '
        'crowd: ${location.crowdLevel} | '
        'distance: ${location.distance} | '
        'description: ${location.description}',
      );
    }

    return buffer.toString();
  }

  // gets the useful error message returned by the Gemini API
  String _readApiError(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      final error = decoded['error'];

      if (error is Map<String, dynamic>) {
        final message = error['message'];

        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
      }
    } catch (_) {
      // if response is not json, use the normal response body
    }

    if (response.body.trim().isNotEmpty) {
      return response.body.trim();
    }

    return 'Unknown Gemini API error.';
  }

  // sends one request to a specific Gemini model
  Future<http.Response> _sendToModel({
    required String model,
    required List<ChatMessage> history,
    required String newMessage,
    required List<CampusLocation> locations,
  }) {
    final uri = Uri.parse(
      '$_baseUrl/$model:generateContent',
    );

    final contents = [
      ...history.map((message) {
        return {
          'role': message.isFromUser ? 'user' : 'model',
          'parts': [
            {
              'text': message.text,
            },
          ],
        };
      }),
      {
        'role': 'user',
        'parts': [
          {
            'text': newMessage,
          },
        ],
      },
    ];

    return http
        .post(
          uri,
          headers: {
            'x-goog-api-key': _apiKey,
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'systemInstruction': {
              'parts': [
                {
                  'text': _buildSystemInstruction(locations),
                },
              ],
            },
            'contents': contents,
            'generationConfig': {
              'temperature': 0.7,
              'maxOutputTokens': 500,
            },
          }),
        )
        .timeout(
          const Duration(seconds: 30),
        );
  }

  // sends the chat history and new question to Gemini
  Future<String> sendMessage({
    required List<ChatMessage> history,
    required String newMessage,
    required List<CampusLocation> locations,
  }) async {
    if (_apiKey.trim().isEmpty ||
        _apiKey == 'PASTE_YOUR_GEMINI_API_KEY_HERE') {
      throw Exception(
        'Gemini API key is missing. Supply GEMINI_API_KEY at build time using --dart-define.',
      );
    }

    if (newMessage.trim().isEmpty) {
      throw Exception(
        'Please enter a question first.',
      );
    }

    String? lastError;

    for (final model in _models) {
      try {
        final response = await _sendToModel(
          model: model,
          history: history,
          newMessage: newMessage.trim(),
          locations: locations,
        );

        // tries the next model if this model is unavailable
        if (response.statusCode == 404) {
          lastError =
              'Model $model was not available for this API key.';
          continue;
        }

        if (response.statusCode != 200) {
          throw Exception(
            'AI request failed (${response.statusCode}): '
            '${_readApiError(response)}',
          );
        }

        final data = jsonDecode(response.body);

        final candidates = data['candidates'];

        if (candidates is! List || candidates.isEmpty) {
          throw Exception(
            'The AI did not return a response. Please try again.',
          );
        }

        final firstCandidate = candidates.first;

        if (firstCandidate is! Map<String, dynamic>) {
          throw Exception(
            'The AI returned an invalid response.',
          );
        }

        final content = firstCandidate['content'];

        if (content is! Map<String, dynamic>) {
          throw Exception(
            'The AI response did not contain any content.',
          );
        }

        final parts = content['parts'];

        if (parts is! List || parts.isEmpty) {
          throw Exception(
            'The AI response was empty. Please try again.',
          );
        }

        // combines all text parts instead of reading only the first part
        final responseText = parts
            .whereType<Map>()
            .map((part) => part['text'])
            .whereType<String>()
            .join('\n')
            .trim();

        if (responseText.isNotEmpty) {
          return responseText;
        }

        throw Exception(
          'The AI response was empty. Please try again.',
        );
      } on http.ClientException catch (error) {
        throw Exception(
          'Could not connect to Gemini: ${error.message}',
        );
      } catch (error) {
        // if it is already one of our useful errors, keep it
        rethrow;
      }
    }

    throw Exception(
      lastError ??
          'No supported Gemini model was available. '
              'Please check your API key and Gemini API access.',
    );
  }
}