import 'dart:async';
import 'dart:convert';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/garden_catalogue.dart';
import '../models/pet_state.dart';

class PetApiException implements Exception {
  const PetApiException(this.code, this.message, {this.status});

  final String code;
  final String message;
  final int? status;
}

class PetApi {
  PetApi({
    http.Client? client,
    this.baseUrl = const String.fromEnvironment('PETS_API_URL'),
    Future<String> Function(String)? accessToken,
  }) : _client = client ?? http.Client(),
       _accessToken = accessToken ?? _cognitoToken;

  final http.Client _client;
  final String baseUrl;
  final Future<String> Function(String) _accessToken;

  static Future<String> _cognitoToken(String owner) async {
    final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
    if (!session.isSignedIn || session.userSubResult.value != owner) {
      throw const PetApiException(
        'unauthorized',
        'Sign in to see your pets.',
        status: 401,
      );
    }
    return session.userPoolTokensResult.value.accessToken.raw;
  }

  Future<PetState> fetch(String owner) async =>
      PetState.fromJson(await _request(owner, 'GET', '/v1/me/pet'));

  Future<GardenCatalogue> fetchCatalogue(String owner) async =>
      GardenCatalogue.fromJson(
        await _request(owner, 'GET', '/v1/me/pet/catalogue'),
      );

  Future<PetState> save(
    String owner,
    String operation,
    Map<String, dynamic> body,
  ) async {
    final method = operation == 'selection' ? 'PUT' : 'POST';
    return PetState.fromJson(
      await _request(owner, method, '/v1/me/pet/$operation', body),
    );
  }

  Future<Map<String, dynamic>> _request(
    String owner,
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final base = Uri.tryParse(baseUrl);
    if (base == null ||
        base.scheme != 'https' ||
        base.host.isEmpty ||
        base.hasQuery ||
        base.hasFragment ||
        base.userInfo.isNotEmpty) {
      throw const PetApiException(
        'not_configured',
        'Pets are unavailable right now.',
      );
    }
    try {
      final token = await _accessToken(owner);
      final request = http.Request(
        method,
        Uri.parse('${baseUrl.replaceFirst(RegExp(r"/+$"), "")}$path'),
      );
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        if (body != null) 'Content-Type': 'application/json',
      });
      if (body != null) request.body = jsonEncode(body);
      final response = await _client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(const Duration(seconds: 15));
      Map<String, dynamic>? json;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) json = decoded;
      } catch (_) {}
      if (response.statusCode != 200) {
        final code = json?['code'];
        final message = json?['message'];
        throw PetApiException(
          code is String ? code : 'request_failed',
          message is String
              ? message
              : response.statusCode == 401
              ? 'Sign in to see your pets.'
              : 'Please try again.',
          status: response.statusCode,
        );
      }
      if (json == null) {
        throw const PetApiException(
          'invalid_response',
          'Pets could not be loaded. Please try again.',
        );
      }
      return json;
    } on PetApiException {
      rethrow;
    } on AuthException {
      throw const PetApiException(
        'unauthorized',
        'Sign in to see your pets.',
        status: 401,
      );
    } on TimeoutException {
      throw const PetApiException(
        'connection',
        'The request timed out. Please try again.',
      );
    } on http.ClientException {
      throw const PetApiException(
        'connection',
        'Could not connect. Please try again.',
      );
    }
  }
}
