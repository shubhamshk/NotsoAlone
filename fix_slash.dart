import 'dart:io';

void main() {
  var file = File('lib/screens/home_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(r'\${', r'${');
  file.writeAsStringSync(content);
}
