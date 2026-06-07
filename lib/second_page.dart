import 'package:flutter/material.dart';
import 'success_page.dart'; // Importação essencial para a navegação
import 'mongo_service.dart'; // Importa para ler os dados da sessão no cabeçalho

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  String estadoSelecionado = 'Perdido'; // Estado inicial da triagem

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
            //  TODO O TEU CONTEÚDO ORIGINAL 100% IGUAL E SEM ERROS
            // =========================================================================
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.chevron_left, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5733),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const Text("NW 258°", style: TextStyle(fontWeight: FontWeight.bold)),
                        const Text("GPS: OK", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const Text('ANIMAL SOS', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  // O teu container circular restaurado com o link da imagem original que não dá erro!
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1552053831-71594a27632d'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  const Text('Selecione o estado do animal', style: TextStyle(color: Colors.redAccent)),
                  const SizedBox(height: 15),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: ['Ferido', 'Perdido', 'Outro'].map((label) => _buildBtn(label)).toList(),
                  ),
                  
                  const Spacer(),
                  
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: SizedBox(
                      width: 220,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SuccessPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E2E2E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('ENVIAR AGORA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildBtn(String label) {
    bool isSelected = estadoSelecionado == label;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() { if (selected) estadoSelecionado = label; });
        },
        selectedColor: const Color(0xFF2E2E2E),
        backgroundColor: Colors.grey[200],
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      ),
    );
  }
}
