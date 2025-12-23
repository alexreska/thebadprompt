import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/app_constants.dart';

abstract class GenerationRemoteDataSource {
  Future<String> generateImage(String prompt);
}

class GenerationRemoteDataSourceImpl implements GenerationRemoteDataSource {
  final http.Client client;

  GenerationRemoteDataSourceImpl({required this.client});

  @override
  Future<String> generateImage(String prompt) async {
    final url = Uri.parse(AppConstants.aiEndpoint);
    
    // ignore: avoid_print
    print('MRO: Using API Key: ${AppConstants.aiApiKey.isNotEmpty ? "${AppConstants.aiApiKey.substring(0, 5)}..." : "EMPTY OR MISSING"}');
    
    // Note: Gemini Pro Vision is primarily for inputting images. For generating images, Google usually uses Imagen.
    // But since the user saw 'gemini-3-pro-image-preview', we will try a generic prompt structure.
    // If this fails, we might need to fallback or use a different endpoint.
    // Standard Gemini generateContent body:
    /*
    {
      "contents": [{
        "parts": [{"text": "Draw a banana..."}]
      }]
    }
    */
    
    // ignore: avoid_print
    print('MRO: Generating image for prompt via Google: "$prompt"');

    try {
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [{
            'parts': [{'text': 'Generate an image of: $prompt. Style: artistic, high quality. Aspect Ratio: 1:1 square.'}]
          }]
        }),
      );

      if (response.statusCode == 200) {
        // Parse Gemini response. Note: Gemini usually returns text, not image URL directly unless it's Imagen.
        // If it's a "preview" model it might return base64 or a link.
        // We will log the response to see what we get for the beta.
        // ignore: avoid_print
        print('MRO: Google API Response: ${response.body}');
        
        // ignore: unused_local_variable
        try {
          final data = jsonDecode(response.body);
          if (data['candidates'] != null && 
              (data['candidates'] as List).isNotEmpty &&
              data['candidates'][0]['content'] != null &&
              data['candidates'][0]['content']['parts'] != null &&
              (data['candidates'][0]['content']['parts'] as List).isNotEmpty) {
             
             final part = data['candidates'][0]['content']['parts'][0];
             if (part.containsKey('inlineData')) {
               final inlineData = part['inlineData'];
               final mimeType = inlineData['mimeType'] ?? 'image/jpeg';
               final base64Data = inlineData['data'];
               
               // Construct Data URI
               return 'data:$mimeType;base64,$base64Data';
             }
          }
          
          // ignore: avoid_print
          print('MRO: Could not find inlineData in response');
          return 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/512/512';

        } catch (e) {
          // ignore: avoid_print
          print('MRO: JSON Parse Error: $e');
          // Return a placeholder or the bucket image on error
          return 'https://storage.googleapis.com/cms-storage-bucket/a9d6ce81aee44ae017ee.png';
        }
      } else {
        // ignore: avoid_print
        print('MRO: Google API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to generate image: ${response.statusCode}');
      }
    } catch(e) {
       // ignore: avoid_print
       print('MRO: Network Error: $e');
       // Fallback
       return 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/512/512';
    }
  }
}
