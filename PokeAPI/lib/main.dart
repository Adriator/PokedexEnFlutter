import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Definir un valor booleano para saber si estamos en modo oscuro o no
  bool _isDarkMode = false;

  // Método para alternar el tema
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokédex',
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.red,
        brightness: Brightness.light, // Modo claro
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.red, // Color rojo para el modo claro
          titleTextStyle: TextStyle(color: Colors.white), // Color blanco para el texto en modo claro
        ),
        scaffoldBackgroundColor: Colors.yellow[100],
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.red,
        brightness: Brightness.dark, // Modo oscuro
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white, // Color blanco para el modo oscuro
          titleTextStyle: TextStyle(color: Colors.black), // Color negro para el texto en modo oscuro
        ),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: HomeScreen(toggleTheme: _toggleTheme), // Pasamos la función para alternar
    );
  }
}