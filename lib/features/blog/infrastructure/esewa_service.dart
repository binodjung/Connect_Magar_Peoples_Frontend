import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/api_constants.dart';

class EsewaService {
  static String generateSignature({
    required String amount,
    required String transactionId,
    required String merchantCode,
  }) {
    // Message format: total_amount,transaction_uuid,product_code
    // eSewa v2 signature uses HMAC-SHA256
    final message = "total_amount=$amount,transaction_uuid=$transactionId,product_code=$merchantCode";
    
    final key = utf8.encode(ApiConstants.esewaSecretKey);
    final bytes = utf8.encode(message);

    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);

    return base64.encode(digest.bytes);
  }

  static String generateTransactionUUID() {
    final now = DateTime.now();
    return DateFormat('yyyyMMdd-HHmmss').format(now);
  }
}
