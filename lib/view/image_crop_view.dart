import 'package:crop_image/utils.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/image_crop_model.dart';
import '../controller/image_crop_controller.dart';

class ImageCropView extends StatefulWidget {
  final ImageCropController controller;
  final ImageCropModel model;

  const ImageCropView({
    super.key,
    required this.controller,
    required this.model,
  });

  @override
  State<ImageCropView> createState() => _ImageCropViewState();
}

class _ImageCropViewState extends State<ImageCropView> {
  @override
  void initState() {
    widget.controller.callback = () {
      setState(() {});
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('图片裁剪工具'),
        backgroundColor: Colors.blue.shade700,
      ),
      floatingActionButton: FloatingActionButton(
          child: Text("缩放"),
          onPressed: () async {
            final data = widget.model.imageData;
            if (data == null) return;
            final file = await widget.controller.resizeImage(data);
            await widget.controller.exportImage(file);
          }),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Stack(alignment: Alignment.center, children: [
      Column(
        children: [
          // 拖拽区域
          _buildDragTarget(),

          // 操作按钮
          _buildActionButtons(),

          // 保存选项
          _buildSaveOptions(),
        ],
      ),
      if (widget.model.onlyResize &&
          widget.model.imageData != null &&
          widget.model.isProcessing) ...[
        Image.memory(
          widget.model.imageData!,
          width: 200,
          height: 200,
        )
      ]
    ]);
  }

  Widget _buildDragTarget() {
    return Expanded(
        flex: 1,
        child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade400,
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropTarget(
                onDragDone: (detail) async {
                  final file = detail.files.first;
                  final filePath = file.path;
                  final isImage = GetUtils.isImage(filePath);
                  if (isImage) {
                    final formatFile = await file.toPlatformFile();
                    widget.controller.loadImageFromFile(formatFile);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("不支持的图片格式"),
                      backgroundColor: Colors.red,
                    ));
                  }
                },
                onDragEntered: (detail) {},
                onDragExited: (detail) {},
                child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Icon(Icons.cloud_upload,
                          size: 64, color: Colors.grey.shade600),
                      const SizedBox(height: 16),
                      Text('拖拽图片到这里',
                          style: TextStyle(
                              fontSize: 18, color: Colors.grey.shade700))
                    ])))));
  }

  Widget _buildActionButtons() {
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          ElevatedButton.icon(
            onPressed: () => widget.controller.pickImage(context),
            label: const Text('选择图片'),
          ),
          ElevatedButton.icon(
              onPressed: widget.controller.clearImage,
              label: const Text('清除'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ))
        ]));
  }

  Widget _buildSaveOptions() {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('保存选项',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [
            Checkbox(
                value: widget.model.saveToSameLocation,
                onChanged: (value) {
                  setState(() {
                    widget.controller.model.saveToSameLocation = value ?? false;
                    widget.controller.model.overwriteOriginal = false;
                  });
                }),
            const Text('保存到原文件相同位置'),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Checkbox(
                value: widget.model.overwriteOriginal,
                onChanged: (value) {
                  setState(() {
                    widget.controller.model.overwriteOriginal = value ?? false;
                    widget.controller.model.saveToSameLocation = false;
                  });
                }),
            const Text('覆盖保存原文件'),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Checkbox(
                value: widget.model.onlyResize,
                onChanged: (value) {
                  setState(() {
                    widget.controller.model.onlyResize = value ?? false;
                  });
                }),
            const Text('仅缩放'),
          ])
        ]));
  }
}
