import 'package:flutter/material.dart';
import 'second_page.dart'; // Garante que este ficheiro existe para a navegação

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Animal SOS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Título Superior
            const Padding(
              padding: EdgeInsets.only(top: 60.0),
              child: Text(
                'ANIMAL SOS',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            // Botão Circular Central (REPORTAR SOS)
            Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: ElevatedButton(
                  onPressed: () {
                    // Navega para o segundo ecrã (o do cão)
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SecondPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5733), // Cor laranja do teu Figma
                    shape: const CircleBorder(),
                    elevation: 5,
                  ),
                  child: const Text(
                    'REPORTAR SOS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Botão Inferior (Alertas Recentes)
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: TextButton(
                onPressed: () {
                  // Aqui ligarias ao ecrã de histórico futuramente
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF2E2E2E), // Cinza escuro
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Meus Alertas Recentes',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
