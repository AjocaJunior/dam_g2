import 'package:flutter/material.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
        title: Text(raca, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Estado: $status • $data'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
