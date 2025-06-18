import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlayIntegrityService {
  static const MethodChannel _channel = MethodChannel('com.jippymart.customer/play_integrity');
  static const String _projectNumber = '100103788554735647301';
  static const String _apiEndpoint = 'https://jippymart.in/api/verify-integrity';
  static const String _apiKey = 'AIzaSyCdLXK7dE_uPBxZ0tzVuL85o9-vyXkwIyk';

  static Future<Map<String, String>> getIntegrityToken() async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('getIntegrityToken', {
        'projectNumber': _projectNumber,
        'apiKey': _apiKey,
      });
      final String token = result['token'];
      final String nonce = result['nonce'];
      log('Play Integrity Token received: ${token.substring(0, 10)}...');
      return {'token': token, 'nonce': nonce};
    } on PlatformException catch (e) {
      log('Play Integrity Error: ${e.message}');
      log('Error code: ${e.code}');
      log('Error details: ${e.details}');
      rethrow;
    } catch (e) {
      log('Unexpected error in getIntegrityToken: $e');
      rethrow;
    }
  }

  static Future<bool> verifyIntegrity() async {
    try {
      // Request an integrity token
      final Map<String, String> result = await getIntegrityToken();
      final String token = result['token']!;
      final String nonce = result['nonce']!;
      log('Token length: ${token.length}');

      // Send the token to your backend for verification
      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-Key': _apiKey,
        },
        body: jsonEncode({
          'token': token,
          'nonce': nonce,
          'session_id': DateTime.now().millisecondsSinceEpoch.toString(),
        }),
      );

      log('Backend response status: ${response.statusCode}');
      log('Backend response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        log('Response data: $responseData');
        
        // Check the integrity verdict
        final verdict = responseData['tokenPayloadExternal']?['integrityVerdict'];
        log('Integrity verdict: $verdict');
        
        if (verdict == null) {
          log('No verdict found in response');
          return false;
        }
        
        return verdict == 'INTEGRITY';
      } else {
        log('Backend verification failed with status: ${response.statusCode}');
        log('Error response: ${response.body}');
        return false;
      }
    } catch (e) {
      log('Play Integrity verification failed: $e');
      return false;
    }
  }
} 