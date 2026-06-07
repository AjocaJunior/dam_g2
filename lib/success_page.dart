import 'package:flutter/material.dart';
import 'mongo_service.dart'; // Importa para ler os dados da sessão no cabeçalho

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Procura as informações do utilizador autenticado para o cabeçalho
    final user = MongoService.utilizadorLogado;
    
    // Dados de contingência caso a sessão seja limpa ao fazer Hot Restart no Chrome
    final String nomeUsuario = user != null ? user['nome'] : 'Utilizador Teste';
    final String emailUsuario = user != null ? user['email'] : 'teste@damg2.com';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // =========================================================================
            //  O TEU CABEÇALHO ADICIONADO (BARRA CINZENTA DE PERFIL COM AVATAR E LOGOUT)
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
                        '/login', // Nome da tua rota de login
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),

            // =========================================================================
            //  TODO O TEU CONTEÚDO ORIGINAL EXATAMENTE IGUAL (SEM ALTERAR NADA DE NADA)
            // =========================================================================
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16), // Pequeno ajuste de espaçamento por causa do cabeçalho
                  const Text('ANIMAL SOS', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Center(
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        color: const Color(0xFF388E3C),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: const Center(
                        child: Text(
                          'SOS Enviado!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: ElevatedButton(
                      onPressed: () {
                        // Volta para o dashboard inicial e limpa a pilha de ecrãs
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E2E2E),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Voltar ao Início', style: TextStyle(color: Colors.white)),
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
