import 'package:flutter/material.dart';
import 'mongo_service.dart'; // Importa para ler os dados da sessão no cabeçalho

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

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
                children: [
                  // Barra Superior com Botão Voltar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.chevron_left, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5733), // Laranja SOS
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'ANIMAL SOS',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 48), // Equilíbrio visual para o título central
                      ],
                    ),
                  ),

                  const Text(
                    'Meus Alertas',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  // Lista de Alertas (Simulada)
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildAlertCard('Golden Retriever', 'Perdido', '20 Abr, 14:30', Colors.orange),
                        _buildAlertCard('Gato Europeu', 'Ferido', '18 Abr, 09:15', Colors.red),
                        _buildAlertCard('Labrador', 'Outro', '15 Abr, 18:00', Colors.grey),
                      ],
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

  // Widget auxiliar para cada item da lista (Card)
  Widget _buildAlertCard(String raca, String status, String data, Color statusColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(Icons.pets, color: statusColor),
        ),
        title: Text(
          raca,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Data: $data'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
