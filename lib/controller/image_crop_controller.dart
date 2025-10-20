import 'dart:io';
import 'dart:typed_data';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import '../model/image_crop_model.dart';

class ImageCropController {
  final ImageCropModel model;
  final cropC = CropController();
  void Function()? callback;

  ImageCropController(this.model);

  // 选择图片
  Future<void> pickImage(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        await loadImageFromFile(result.files.first);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择图片失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 加载图片
  Future<void> loadImageFromFile(PlatformFile file) async {
    try {
      if (file.bytes != null) {
        model.updateImageData(file);
      } else if (file.path != null) {
        File imageFile = File(file.path!);
        Uint8List data = await imageFile.readAsBytes();
        final updatedFile = PlatformFile(
          name: file.name,
          size: file.size,
          bytes: data,
          path: file.path,
        );
        model.updateImageData(updatedFile);
      }
      model.isProcessing = true;
      callback?.call();
      if (model.onlyResize) return;
      Get.to(_buildCropArea());
    } catch (e) {
      throw Exception('加载图片失败: $e');
    }
  }

  Widget _buildCropArea() {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(onPressed: () {
        cropC.crop();
      }),
      body: Crop(
        controller: cropC,
        interactive: true,
        withCircleUi: true,
        image: model.imageData!,
        onCropped: (croppedData) {
          Get.back();
          if (model.imageData == null) return;

          final context = Get.context!;
          model.setProcessing(true);
          if (CropResult is CropFailure) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('裁剪失败: ${(croppedData as CropFailure).cause}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

          final Uint8List croppedImage =
              (croppedData as CropSuccess).croppedImage;
          exportImage(croppedImage);
        },
      ),
    );
  }

  Future<Uint8List> resizeImage(
    Uint8List imageData, {
    int width = 300,
    int height = 300,
  }) async {
    try {
      // 解码图片
      final image = img.decodeImage(imageData);
      if (image == null) {
        throw Exception('无法解码图片');
      }

      final resizedImage = img.copyResize(
        image,
        width: width,
        height: height,
        interpolation: img.Interpolation.cubic,
      );

      return Uint8List.fromList(img.encodePng(resizedImage));
    } catch (e) {
      throw Exception('图片缩放失败: $e');
    }
  }

  // 导出图片
  Future<void> exportImage(Uint8List data) async {
    final context = Get.context!;

    try {
      final fileData = await resizeImage(data);

      // 确定保存路径
      String? savePath;

      if (model.saveToSameLocation && model.originalFilePath != null) {
        if (model.overwriteOriginal) {
          // 覆盖原文件
          savePath = model.originalFilePath;
        } else {
          // 相同位置，新文件名
          String dir = path.dirname(model.originalFilePath!);
          String name = path.basenameWithoutExtension(model.originalFilePath!);
          String ext = path.extension(model.originalFilePath!);
          savePath = path.join(dir, '${name}_cropped$ext');
        }
      } else {
        // 让用户选择保存位置
        String? outputPath = await FilePicker.platform.saveFile(
          dialogTitle: '保存裁剪后的图片',
          fileName: '${model.name}_crop.png',
        );
        savePath = outputPath;
      }

      // 保存文件
      if (savePath != null) {
        File outputFile = File(savePath);
        await outputFile.writeAsBytes(fileData.toList());

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('图片已保存到: $savePath'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      model.setProcessing(false);
      callback?.call();
    }
  }

  // 清除图片
  void clearImage() {
    model.clearImageData();
  }
}
