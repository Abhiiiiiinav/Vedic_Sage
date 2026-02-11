import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/app.dart';
import 'core/database/hive_database_service.dart';
import 'core/services/user_session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Hive database
  await HiveDatabaseService().initialize();

  
  // Initialize UserSession (loads saved profile from database)
  await UserSession().initialize();

  // Set system UI overlay style for immersive experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0a0e21),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const AstroLearnApp());
}
