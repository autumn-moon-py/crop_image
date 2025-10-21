import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class ImageCropModel {
  Uint8List? imageData;
  String? originalFilePath;
  String name = "";

  bool isProcessing = false;

  // 保存选项
  bool saveToSameLocation = false;
  bool overwriteOriginal = false;
  bool onlyResize = false;

  // 更新图片数据
  void updateImageData(PlatformFile file) {
    name = file.name;
    if (file.bytes != null) {
      imageData = file.bytes;
      originalFilePath = file.path;
    } else {
      originalFilePath = file.path;
    }
  }

  // 清除图片数据
  void clearImageData() {
    imageData = null;
    originalFilePath = null;
    name = "";
  }

  // 更新处理状态
  void setProcessing(bool processing) {
    isProcessing = processing;
    clearImageData();
  }
}
