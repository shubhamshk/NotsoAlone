import 'dart:io';

void main() {
  var file = File('lib/screens/home_screen.dart');
  var content = file.readAsStringSync();
  var target = "if (orgName != null && orgName.isNotEmpty) ...[";
  var replacement = r'''const SizedBox(height: 8),
                                 Row(
                                   children: [
                                     Icon(
                                       isPaid ? Icons.payments : Icons.money_off,
                                       size: 16,
                                       color: isPaid ? Colors.green : _textVariantColor,
                                     ),
                                     const SizedBox(width: 4),
                                     Text(
                                       isPaid ? 'Entry Fee: ₹${amountStr ?? ''}' : 'Free Entry',
                                       style: TextStyle(
                                         color: isPaid ? Colors.green.shade700 : _textVariantColor,
                                         fontSize: 14,
                                         fontWeight: isPaid ? FontWeight.bold : FontWeight.normal,
                                       ),
                                     ),
                                   ],
                                 ),
                                 if (orgName != null && orgName.isNotEmpty) ...[''';
  
  content = content.replaceFirst(target, replacement);
  file.writeAsStringSync(content);
}
