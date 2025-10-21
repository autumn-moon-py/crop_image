import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';

extension DropItemExt on DropItem {
  Future<PlatformFile> toPlatformFile() async {
    return PlatformFile.fromMap({
      "name": name,
      "path": path,
      "bytes": await readAsBytes(),
      "size": await length(),
      "identifiew": mimeType,
    });
  }
}
