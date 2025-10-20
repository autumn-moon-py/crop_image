import 'package:flutter/material.dart';
import 'model/image_crop_model.dart';
import 'controller/image_crop_controller.dart';
import 'view/image_crop_view.dart';

class ImageCropApp extends StatefulWidget {
  const ImageCropApp({super.key});

  @override
  State<ImageCropApp> createState() => _ImageCropAppState();
}

class _ImageCropAppState extends State<ImageCropApp> {
  late final ImageCropModel _model;
  late final ImageCropController _controller;

  @override
  void initState() {
    super.initState();
    _model = ImageCropModel();
    _controller = ImageCropController(_model);
  }

  @override
  Widget build(BuildContext context) {
    return ImageCropView(
      controller: _controller,
      model: _model,
    );
  }
}
