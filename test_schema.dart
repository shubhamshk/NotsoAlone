import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://aiqqunfuiegfwrjmjpmb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFpcXF1bmZ1aWVnZndyam1qcG1iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM2NDMyMDMsImV4cCI6MjA4OTIxOTIwM30.oL_WsWL7xArwT3_mMQkrB4WS48gv2HisixFilqGLl-M',
  );
  
  try {
    final response = await Supabase.instance.client.from('profiles').select().limit(1);
    print('PROFILES SCHEMA: \$response');
  } catch(e) {
    print('ERROR: \$e');
  }
}
