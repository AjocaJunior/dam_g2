import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'camera_capture.dart';
import 'location_data.dart';
import 'location_service.dart';
import 'mongo_service.dart';
import 'success_page.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _especieController = TextEditingController(text: 'Cao');
  final _racaController = TextEditingController();
  final _corController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _imagePicker = ImagePicker();

  String estadoSelecionado = 'Perdido';
  bool _isSubmitting = false;
  Uint8List? _fotoBytes;
  String? _fotoMimeType;
  String? _fotoNome;
  SosLocationData? _localizacao;
  bool _isLocating = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _especieController.dispose();
    _racaController.dispose();
    _corController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _tirarFoto() async {
    final photo = await capturePhotoFromCamera(context);
    if (photo == null || !mounted) return;

    setState(() {
      _fotoBytes = Uint8List.fromList(photo.bytes);
      _fotoMimeType = photo.mimeType;
      _fotoNome = photo.name;
    });
  }

  Future<void> _selecionarFotoGaleria() async {
    try {
      final foto = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 76,
      );
      if (foto == null) return;

      final bytes = await foto.readAsBytes();
      if (!mounted) return;

      setState(() {
        _fotoBytes = bytes;
        _fotoMimeType = foto.mimeType ?? 'image/jpeg';
        _fotoNome = foto.name;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nao foi possivel obter a foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _captarLocalizacao() async {
    setState(() {
      _isLocating = true;
    });

    final location = await getCurrentSosLocation();

    if (!mounted) return;

    setState(() {
      _isLocating = false;
      _localizacao = location;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          location == null
              ? 'Nao foi possivel obter a localizacao.'
              : 'Localizacao GPS captada.',
        ),
        backgroundColor: location == null ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _enviarAlerta() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    SosLocationData? localizacao = _localizacao;
    if (localizacao == null) {
      localizacao = await getCurrentSosLocation();
      if (mounted) {
        setState(() {
          _localizacao = localizacao;
        });
      }
    }

    if (localizacao == null) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ative e permita o GPS para enviar o alerta com localizacao.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final sucesso = await MongoService.criarAlertaAnimal(
      estadoAnimal: estadoSelecionado,
      nomeAnimal: _nomeController.text.trim(),
      especie: _especieController.text.trim(),
      raca: _racaController.text.trim(),
      cor: _corController.text.trim(),
      descricaoAlerta: _descricaoController.text.trim(),
      fotoBase64: _fotoBytes == null ? null : base64Encode(_fotoBytes!),
      fotoMimeType: _fotoMimeType,
      fotoNome: _fotoNome,
      localizacao: localizacao.toJson(),
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (sucesso) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SuccessPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            MongoService.ultimoErro ?? 'Nao foi possivel enviar o alerta SOS.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = MongoService.utilizadorLogado;
    final String nomeUsuario = user != null ? user['nome'] : 'Utilizador Teste';
    final String emailUsuario = user != null
        ? user['email']
        : 'teste@damg2.com';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(nomeUsuario, emailUsuario),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
                child: Form(
                  key: _formKey,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTopBar(),
                        const SizedBox(height: 12),
                        const Text(
                          'ANIMAL SOS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildPhotoPicker(),
                        const SizedBox(height: 22),
                        _buildAnimalFields(),
                        const SizedBox(height: 18),
                        const Text(
                          'Selecione o estado do animal',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.redAccent),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            'Ferido',
                            'Perdido',
                            'Outro',
                          ].map((label) => _buildBtn(label)).toList(),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _descricaoController,
                          minLines: 3,
                          maxLines: 5,
                          decoration: _inputDecoration(
                            'Descricao do alerta',
                            'Ex.: visto perto da praia, assustado e sem dono por perto',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Descreva o alerta.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _enviarAlerta,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E2E2E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'ENVIAR AGORA',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String nomeUsuario, String emailUsuario) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
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
                  'Ola, $nomeUsuario!',
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
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    final gpsText = _localizacao == null
        ? 'GPS: ativar'
        : 'GPS: ${_localizacao!.latitude.toStringAsFixed(5)}, '
              '${_localizacao!.longitude.toStringAsFixed(5)}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFFF5733),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const Text('NW 258 deg', style: TextStyle(fontWeight: FontWeight.bold)),
        TextButton.icon(
          onPressed: _isLocating ? null : _captarLocalizacao,
          icon: _isLocating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  _localizacao == null
                      ? Icons.location_searching
                      : Icons.gps_fixed,
                  color: _localizacao == null ? Colors.orange : Colors.green,
                ),
          label: Text(
            gpsText,
            style: TextStyle(
              color: _localizacao == null ? Colors.orange : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoPicker() {
    final imageProvider = _fotoBytes == null ? null : MemoryImage(_fotoBytes!);

    return Column(
      children: [
        Container(
          width: 230,
          height: 230,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF2F2F2),
            border: Border.all(color: Colors.black, width: 2),
            image: imageProvider == null
                ? null
                : DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
          child: imageProvider == null
              ? const Icon(Icons.add_a_photo, size: 58, color: Colors.black45)
              : null,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: _tirarFoto,
              icon: const Icon(Icons.photo_camera),
              label: const Text('Camera'),
            ),
            OutlinedButton.icon(
              onPressed: _selecionarFotoGaleria,
              icon: const Icon(Icons.photo_library),
              label: const Text('Galeria'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimalFields() {
    return Column(
      children: [
        TextFormField(
          controller: _nomeController,
          decoration: _inputDecoration('Nome do animal', 'Ex.: Pluto'),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Informe o nome do animal ou "Desconhecido".';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _especieController,
                decoration: _inputDecoration('Especie', 'Ex.: Cao'),
                validator: _requiredField,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _racaController,
                decoration: _inputDecoration('Raca', 'Ex.: Rafeiro'),
                validator: _requiredField,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _corController,
          decoration: _inputDecoration('Cor', 'Ex.: Dourado'),
          validator: _requiredField,
        ),
      ],
    );
  }

  String? _requiredField(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obrigatorio.';
    return null;
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF2F2F2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
          setState(() {
            if (selected) estadoSelecionado = label;
          });
        },
        selectedColor: const Color(0xFF2E2E2E),
        backgroundColor: Colors.grey[200],
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      ),
    );
  }
}
