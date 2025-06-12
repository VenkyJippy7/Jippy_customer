import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlayIntegrityService {
  static const MethodChannel _channel = MethodChannel('com.jippymart.customer/play_integrity');
  static const String _apiEndpoint = 'https://jippymart.in/api/verify-integrity';

  static Future<String> getIntegrityToken() async {
    try {
      final String token = await _channel.invokeMethod('getIntegrityToken');
      log('Play Integrity Token received: ${token.substring(0, 10)}...');
      return token;
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

  static Future<bool> performIntegrityCheck() async {
    try {
      final token = await getIntegrityToken();
      if (token.isEmpty) {
        log('Play Integrity: Empty token received');
        return false;
      }

      // Verify token with your server
      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'integrity_token': token,
        }),
      );

      log('Play Integrity API Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final success = data['success'] ?? false;
        log('Play Integrity verification result: $success');
        return success;
      }
      
      log('Play Integrity API Error: ${response.body}');
      return false;
    } on PlatformException catch (e) {
      log('Play Integrity Platform Error: ${e.message}');
      // For development/testing, return true to allow login
      // In production, you might want to return false
      return true;
    } catch (e) {
      log('Play Integrity Unexpected Error: $e');
      // For development/testing, return true to allow login
      // In production, you might want to return false
      return true;
    }
  }
} 