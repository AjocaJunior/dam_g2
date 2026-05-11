import 'package:flutter/material.dart';
import 'second_page.dart';
import 'alerts_page.dart'; // Importação necessária para o histórico
import 'login_page.dart';
import 'recover_email_page.dart';
import 'recover_code_page.dart';
import 'register_page.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF5733)),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      routes: {
        LoginPage.routeName: (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
        RecoverEmailPage.routeName: (context) => const RecoverEmailPage(),
        RecoverCodePage.routeName: (context) => const RecoverCodePage(),
        RegisterPage.routeName: (context) => const RegisterPage(),
      },
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
            // Título Superior conforme o Mockup
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
                    // Navegação para o ecrã de Triagem/Câmara
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SecondPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5733), // Laranja SOS
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

            // Botão Inferior (Meus Alertas Recentes)
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: SizedBox(
                width: 220,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Navegação para o novo ecrã de Histórico
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AlertsPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E2E2E), // Cinza escuro
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Meus Alertas Recentes',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
