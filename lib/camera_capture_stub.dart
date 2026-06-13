import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'captured_photo.dart';

Future<CapturedPhoto?> capturePhotoFromCamera(BuildContext context) async {
  final picker = ImagePicker();
  final photo = await picker.pickImage(
    source: ImageSource.camera,
    maxWidth: 1200,
    imageQuality: 76,
  );
  if (photo == null) return null;

  return CapturedPhoto(
    bytes: await photo.readAsBytes(),
    mimeType: photo.mimeType ?? 'image/jpeg',
    name: photo.name,
  );
}
