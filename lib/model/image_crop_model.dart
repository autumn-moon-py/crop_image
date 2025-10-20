import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class ImageCropModel {
  Uint8List? imageData;
  String? originalFilePath;
  bool isProcessing = false;
  bool onlyResize = false;
  String name = "";

  // 保存选项
  bool saveToSameLocation = false;
  bool overwriteOriginal = false;

  // 更新图片数据
  void updateImageData(PlatformFile file) {
    name = file.name;
    if (file.bytes != null) {
      imageData = file.bytes;
      originalFilePath = file.path;
    } else if (file.path != null) {
      originalFilePath = file.path;
    }
  }

  // 清除图片数据
  void clearImageData() {
    imageData = null;
    originalFilePath = null;
  }

  // 更新处理状态
  void setProcessing(bool processing) {
    isProcessing = processing;
  }
}
