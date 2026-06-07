import 'mongo_service.dart';
import 'package:flutter/material.dart';
import 'second_page.dart';
import 'alerts_page.dart'; // Importação necessária para o histórico
import 'login_page.dart';
import 'recover_email_page.dart';
import 'recover_code_page.dart';
import 'register_page.dart';

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  await MongoService.connect();
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
    // Procura as informações do utilizador autenticado para o cabeçalho
    final user = MongoService.utilizadorLogado;
    
    // Dados de contingência caso a sessão seja limpa ao fazer Hot Restart
    final String nomeUsuario = user != null ? user['nome'] : 'Utilizador Teste';
    final String emailUsuario = user != null ? user['email'] : 'teste@damg2.com';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // =========================================================================
            //  O TEU CABEÇALHO (BARRA CINZENTA DE PERFIL COM AVATAR E LOGOUT)
            // =========================================================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5), // Tom de cinza claro
                border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFF2E2E2E),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Olá, $nomeUsuario!',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          emailUsuario,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    onPressed: () {
                      MongoService.efetuarLogout();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        LoginPage.routeName,
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),

            // =========================================================================
            //  CONTEÚDO DO DASHBOARD PRINCIPAL
            // =========================================================================
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                      'ANIMAL SOS',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // BOTÃO REDONDO PRINCIPAL - AGORA ABRIRÁ A SECOND_PAGE CORRETAMENTE!
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: ElevatedButton(
                        onPressed: () {
                          // Ação corrigida: Chama o ecrã de triagem ao clicar!
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SecondPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5252),
                          shape: const CircleBorder(),
                          elevation: 6,
                        ),
                        child: const Text(
                          'REPORTAR\nSOS',
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

                  const SizedBox(height: 64),

                  // BOTÃO INFERIOR (Meus Alertas Recentes) - AGORA VAI PARA A ALERTS_PAGE!
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: SizedBox(
                      width: 220,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Ação corrigida: Vai para o histórico de alertas reais
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AlertsPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E2E2E),
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
          ],
        ),
      ),
    );
  }
}
