import 'package:flutter/material.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  // Variável para controlar qual botão de estado está selecionado
  String estadoSelecionado = 'Perdido'; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Barra de topo com Sensores e Botão Voltar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botão Voltar (Laranja igual ao Figma)
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5733),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Icon(Icons.chevron_left, color: Colors.white),
                    ),
                  ),
                  // Dados dos Sensores (Simulados conforme o teu design)
                  const Text("NW 258°", style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text("GPS: OK", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const Text(
              'ANIMAL SOS',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // Círculo com a imagem do Cão (Mockup da Câmara)
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2, style: BorderStyle.solid),
                image: const DecorationImage(
                  // Nota: Substitui pelo caminho da tua imagem ou Image.network
                  image: NetworkImage('https://images.unsplash.com/photo-1552053831-71594a27632d?q=80&w=1000'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Selecione o estado do animal',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 15),

            // Linha de botões de Triagem
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTriagemBtn("Ferido"),
                const SizedBox(width: 10),
                _buildTriagemBtn("Perdido"),
                const SizedBox(width: 10),
                _buildTriagemBtn("Outro"),
              ],
            ),

            const Spacer(),

            // Botão ENVIAR AGORA
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Aqui farias a navegação para a página de Sucesso
                    print("Enviando alerta como: $estadoSelecionado");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E2E2E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('ENVIAR AGORA', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Função auxiliar para criar os botões de triagem (estilo toggle)
  Widget _buildTriagemBtn(String label) {
    bool isSelected = estadoSelecionado == label;
    return GestureDetector(
      onTap: () => setState(() => estadoSelecionado = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E2E2E) : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
