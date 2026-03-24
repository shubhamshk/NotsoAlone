import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpiService {
  static Future<void> launchUPI(BuildContext context, String amount) async {
    final String upiId = '2003ratnam@oksbi';
    final String payeeName = 'Antigravity Sports';
    final Uri upiUrl = Uri(
      scheme: 'upi',
      host: 'pay',
      queryParameters: {
        'pa': upiId,
        'pn': payeeName,
        'am': amount,
        'cu': 'INR',
        'tn': 'Match Entry',
      },
    );

    try {
      if (await canLaunchUrl(upiUrl)) {
        await launchUrl(upiUrl, mode: LaunchMode.externalApplication);
        // Show success snackbar upon return
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Redirecting to UPI App...')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No UPI app found on this device.')),
          );
        }
      }
    } catch (e) {
      debugPrint('UPI Error: $e');
    }
  }
}
