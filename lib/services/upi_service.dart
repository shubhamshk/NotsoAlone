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
      // Bypassing canLaunchUrl which is unreliable on Android 11+ for non-browser intents
      bool launched = false;
      try {
        launched = await launchUrl(upiUrl, mode: LaunchMode.externalNonBrowserApplication);
      } catch (e) {
        debugPrint('UPI Generic Error: $e');
      }

      if (!launched) {
        // Fallback specifically to Google Pay (Tez) protocol
        final Uri tezUrl = Uri(
          scheme: 'tez',
          host: 'upi',
          path: '/pay',
          queryParameters: upiUrl.queryParameters,
        );
        try {
          launched = await launchUrl(tezUrl, mode: LaunchMode.externalNonBrowserApplication);
        } catch (e) {
          debugPrint('Tez Fallback Error: $e');
        }
      }

      if (launched) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Redirecting to UPI App...')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch UPI application.')),
          );
        }
      }
    } catch (e) {
      debugPrint('UPI Error: $e');
    }
  }
}
