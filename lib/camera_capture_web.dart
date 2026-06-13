// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

import 'captured_photo.dart';

int _viewId = 0;

Future<CapturedPhoto?> capturePhotoFromCamera(BuildContext context) async {
  final mediaDevices = html.window.navigator.mediaDevices;
  if (mediaDevices == null) {
    _showError(context, 'Este browser nao disponibiliza acesso a camera.');
    return null;
  }

  html.MediaStream? stream;
  try {
    stream = await mediaDevices.getUserMedia({
      'video': {
        'facingMode': 'environment',
        'width': {'ideal': 1280},
        'height': {'ideal': 720},
      },
      'audio': false,
    });
  } catch (e) {
    if (context.mounted) {
      _showError(context, 'Permissao de camera negada ou camera indisponivel.');
    }
    return null;
  }

  final video = html.VideoElement()
    ..autoplay = true
    ..muted = true
    ..srcObject = stream
    ..style.width = '100%'
    ..style.height = '100%'
    ..style.objectFit = 'cover';

  await video.play();

  final viewType = 'sos-camera-preview-${_viewId++}';
  ui_web.platformViewRegistry.registerViewFactory(viewType, (_) => video);

  if (!context.mounted) {
    _stopStream(stream);
    return null;
  }

  final result = await showDialog<CapturedPhoto>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Capturar foto'),
        content: SizedBox(
          width: 420,
          height: 320,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: HtmlElementView(viewType: viewType),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final photo = await _captureFrame(video);
              if (dialogContext.mounted) Navigator.pop(dialogContext, photo);
            },
            icon: const Icon(Icons.photo_camera),
            label: const Text('Capturar'),
          ),
        ],
      );
    },
  );

  _stopStream(stream);
  return result;
}

Future<CapturedPhoto> _captureFrame(html.VideoElement video) async {
  final width = video.videoWidth == 0 ? 1280 : video.videoWidth;
  final height = video.videoHeight == 0 ? 720 : video.videoHeight;
  final canvas = html.CanvasElement(width: width, height: height);
  final context = canvas.context2D;

  context.drawImageScaled(video, 0, 0, width, height);

  final blob = await canvas.toBlob('image/jpeg', 0.82);
  final bytes = await _readBlob(blob);

  return CapturedPhoto(
    bytes: bytes,
    mimeType: 'image/jpeg',
    name: 'foto-sos-${DateTime.now().millisecondsSinceEpoch}.jpg',
  );
}

Future<Uint8List> _readBlob(html.Blob blob) {
  final completer = Completer<Uint8List>();
  final reader = html.FileReader();

  reader.onLoad.listen((_) {
    completer.complete(reader.result as Uint8List);
  });
  reader.onError.listen((_) {
    completer.completeError(reader.error ?? 'Erro ao ler foto capturada.');
  });
  reader.readAsArrayBuffer(blob);

  return completer.future;
}

void _stopStream(html.MediaStream stream) {
  for (final track in stream.getTracks()) {
    track.stop();
  }
}

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
}
