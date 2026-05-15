import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE8FF47),
          onPrimary: Color(0xFF0A0A0A),
          surface: Color(0xFF111111),
          onSurface: Color(0xFFF5F5F5),
          surfaceContainerHighest: Color(0xFF1C1C1C),
          outline: Color(0xFF2A2A2A),
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        textTheme: GoogleFonts.dmSansTextTheme(
          const TextTheme(),
        ).copyWith(
          displayLarge: GoogleFonts.spaceMono(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF5F5F5),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
