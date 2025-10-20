import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'image_crop.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '图片裁剪工具',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: false),
      home: const ImageCropApp(),
    );
  }
}
