import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

class PlayIntegrityService {
  static const platform = MethodChannel('com.jippymart.customer/play_integrity');
  static const String verifyEndpoint = 'https://jippymart.in/api/verify-integrity';

  static Future<String> getIntegrityToken() async {
    try {
      developer.log('Requesting integrity token from native platform');
      final String token = await platform.invokeMethod('getIntegrityToken');
      developer.log('Successfully received integrity token');
      return token;
    } on PlatformException catch (e) {
      developer.log('Error getting integrity token: ${e.message}', error: e);
      throw Exception('Failed to get integrity token: ${e.message}');
    } catch (e) {
      developer.log('Unexpected error getting integrity token', error: e);
      throw Exception('Unexpected error getting integrity token: $e');
    }
  }

  static Future<bool> verifyIntegrity(String token) async {
    try {
      developer.log('Verifying integrity token with backend');
      final response = await http.post(
        Uri.parse(verifyEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': token,
        }),
      );

      developer.log('Backend response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        developer.log('Backend verification response: $responseData');
        return responseData['success'] ?? false;
      }
      developer.log('Backend verification failed with status: ${response.statusCode}');
      return false;
    } catch (e) {
      developer.log('Error verifying integrity', error: e);
      return false;
    }
  }

  static Future<bool> performIntegrityCheck() async {
    try {
      developer.log('Starting integrity check');
      final token = await getIntegrityToken();
      final result = await verifyIntegrity(token);
      developer.log('Integrity check completed with result: $result');
      return result;
    } catch (e) {
      developer.log('Error performing integrity check', error: e);
      return false;
    }
  }
} 