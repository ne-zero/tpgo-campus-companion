import 'dart:convert';

import 'package:http/http.dart' as http;

// handles all communication with the nets sandbox api
class NetsService {
  final String apiKey = 'dKUEEI5e2KygvMViesIX' ;
  final String projectId = 'f0be0b9a-4d5c-44f2-b590-e024e726a8c0';

  static const String _requestUrl =
      'https://sandbox.nets.openapipaas.com/api/v1/common/payments/nets-qr/request';

  static const String _webhookUrl =
      'https://sandbox.nets.openapipaas.com/api/v1/common/payments/nets/webhook';

  static const String _queryUrl =
      'https://sandbox.nets.openapipaas.com/api/v1/common/payments/nets-qr/query';

  // generates a nets qr code
  Future<Map<String, dynamic>> requestQR(
    double amount,
  ) async {
    final response = await http.post(
      Uri.parse(_requestUrl),
      headers: {
        'api-key': apiKey,
        'project-id': projectId,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'txn_id': 'TPGO${DateTime.now().millisecondsSinceEpoch}',
        'amt_in_dollars': amount,
        'notify_mobile': 0,
      }),
    );

    Map<String, dynamic>? data;

    try {
      final decoded = jsonDecode(
        response.body,
      );

      if (decoded is Map<String, dynamic>) {
        data = decoded;
      }
    } catch (_) {
      // handled below using raw response body
    }

    // accept any successful http status
    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        _extractErrorMessage(
          data,
          fallback:
              'NETS request failed with HTTP ${response.statusCode}. '
              '${response.body}',
        ),
      );
    }

    if (data == null) {
      throw Exception(
        'NETS returned an invalid response: ${response.body}',
      );
    }

    if (data['status'] != 'success') {
      throw Exception(
        _extractErrorMessage(
          data,
          fallback:
              'NETS could not generate the QR code.',
        ),
      );
    }

    final result = data['result'];

    if (result is! Map) {
      throw Exception(
        'NETS response did not contain result data.',
      );
    }

    final resultData = result['data'];

    if (resultData is! Map) {
      throw Exception(
        'NETS response did not contain payment data.',
      );
    }

    final paymentData =
        Map<String, dynamic>.from(
      resultData,
    );

    if (paymentData['qr_code'] == null) {
      throw Exception(
        'NETS response did not contain qr_code.',
      );
    }

    if (paymentData['txn_retrieval_ref'] ==
        null) {
      throw Exception(
        'NETS response did not contain txn_retrieval_ref.',
      );
    }

    return paymentData;
  }

  // extracts a useful message from different nets error shapes
  String _extractErrorMessage(
    Map<String, dynamic>? data, {
    required String fallback,
  }) {
    if (data == null) {
      return fallback;
    }

    final message = data['message'];

    if (message != null &&
        message.toString().trim().isNotEmpty) {
      return message.toString();
    }

    final error = data['error'];

    if (error != null &&
        error.toString().trim().isNotEmpty) {
      return error.toString();
    }

    final result = data['result'];

    if (result is Map) {
      final resultMessage =
          result['message'];

      if (resultMessage != null &&
          resultMessage
              .toString()
              .trim()
              .isNotEmpty) {
        return resultMessage.toString();
      }

      final resultData =
          result['data'];

      if (resultData is Map) {
        final nestedMessage =
            resultData['message'];

        if (nestedMessage != null &&
            nestedMessage
                .toString()
                .trim()
                .isNotEmpty) {
          return nestedMessage.toString();
        }
      }
    }

    return fallback;
  }

  // listens for nets payment updates
  Stream<String> webhookStream(
    String txnRef,
  ) async* {
    final request = http.Request(
      'GET',
      Uri.parse(
        '$_webhookUrl?txn_retrieval_ref=$txnRef',
      ),
    );

    request.headers['api-key'] =
        apiKey;

    request.headers['project-id'] =
        projectId;

    final client = http.Client();

    try {
      final response =
          await client.send(request);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          'NETS webhook failed with HTTP ${response.statusCode}.',
        );
      }

      await for (final line
          in response.stream
              .transform(utf8.decoder)
              .transform(
                const LineSplitter(),
              )) {
        if (line.trim().isNotEmpty) {
          yield line;
        }
      }
    } finally {
      client.close();
    }
  }

  // checks final payment status
  Future<Map<String, dynamic>>
      checkPayment(
    String txnRef,
  ) async {
    final response = await http.post(
      Uri.parse(_queryUrl),
      headers: {
        'api-key': apiKey,
        'project-id': projectId,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'txn_retrieval_ref': txnRef,
        'frontend_timeout_status': 1,
      }),
    );

    Map<String, dynamic>? data;

    try {
      final decoded =
          jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        data = decoded;
      }
    } catch (_) {}

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        _extractErrorMessage(
          data,
          fallback:
              'NETS payment query failed with HTTP ${response.statusCode}.',
        ),
      );
    }

    if (data == null) {
      throw Exception(
        'NETS returned an invalid payment query response.',
      );
    }

    final result = data['result'];

    if (result is! Map ||
        result['data'] is! Map) {
      throw Exception(
        'NETS payment query response was incomplete.',
      );
    }

    return Map<String, dynamic>.from(
      result['data'],
    );
  }
}