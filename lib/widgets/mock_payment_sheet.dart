import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';

class MockPaymentSheet extends StatefulWidget {
  final String matchId;
  final String matchTitle;
  final String amount;

  const MockPaymentSheet({
    super.key,
    required this.matchId,
    required this.matchTitle,
    required this.amount,
  });

  @override
  State<MockPaymentSheet> createState() => _MockPaymentSheetState();
}

class _MockPaymentSheetState extends State<MockPaymentSheet> {
  bool isProcessing = false;
  bool isSuccess = false;

  Future<void> _processDummyPayment() async {
    setState(() {
      isProcessing = true;
    });

    // Simulate network call
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Execute the Supabase insert into match_participants
      // Using int.tryParse just in case the backend expects an integer match_id instead of string.
      await Supabase.instance.client.from('match_participants').insert({
        'match_id': int.tryParse(widget.matchId) ?? widget.matchId,
        'user_id': Supabase.instance.client.auth.currentUser!.id,
      });

      if (!mounted) return;

      setState(() {
        isProcessing = false;
        isSuccess = true;
      });

      // Let them see the success state for a moment
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      // IMPROVEMENT: Capture the messenger BEFORE popping, so we don't use
      // an unmounted or invalid context for the SnackBar.
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      
      Navigator.pop(context);
      
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Payment Successful & Joined Match!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Error joining match: $e');
      
      if (!mounted) return;
      
      setState(() {
        isProcessing = false;
        isSuccess = false;
      });

      String errorMessage = 'Could not join match: ${e.toString()}';
      
      // Specifically handle the duplicate key error (user already joined)
      if (e is PostgrestException && e.code == '23505') {
        errorMessage = 'You have already joined this match!';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Complete Payment',
            style: TextStyle(fontSize: 22, fontFamily: 'Lexend', fontWeight: FontWeight.bold, color: AppTheme.textMain),
          ),
          const SizedBox(height: 8),
          Text(widget.matchTitle, style: const TextStyle(fontSize: 16, fontFamily: 'Manrope', color: AppTheme.textVariant)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Entry Fee: ${widget.amount}',
              style: const TextStyle(
                  color: Colors.green, fontSize: 18, fontFamily: 'Lexend', fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          if (isProcessing)
            const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Connecting to secure gateway...'),
              ],
            )
          else if (isSuccess)
            const Column(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 60),
                SizedBox(height: 16),
                Text(
                  'Payment Successful!',
                  style: TextStyle(fontSize: 20, fontFamily: 'Lexend', fontWeight: FontWeight.bold, color: AppTheme.textMain),
                ),
              ],
            )
          else
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.account_balance_wallet, color: AppTheme.primary),
                    title: const Text('Pay via UPI (GPay/PhonePe)', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600, color: AppTheme.textMain)),
                    trailing: const Icon(Icons.chevron_right, color: AppTheme.outline),
                    onTap: _processDummyPayment,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.credit_card, color: Colors.orange),
                    title: const Text('Pay via Credit/Debit Card', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600, color: AppTheme.textMain)),
                    trailing: const Icon(Icons.chevron_right, color: AppTheme.outline),
                    onTap: _processDummyPayment,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
