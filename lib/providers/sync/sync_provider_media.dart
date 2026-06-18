import 'dart:io';



import 'package:fladder/models/item_base_model.dart';
import 'package:fladder/models/items/chapters_model.dart';
import 'package:fladder/models/items/images_models.dart';
import 'package:fladder/models/items/media_streams_model.dart';
import 'package:fladder/models/items/trick_play_model.dart';
import 'package:fladder/models/syncing/sync_item.dart';
import 'package:fladder/providers/sync_provider.dart';

extension SyncMediaHelpers on SyncNotifier {
  Future<List<SubStreamModel>> saveExternalSubtitles(List<SubStreamModel>? subtitles, SyncedItem item) async {
    return fileManager.saveExternalSubtitles(subtitles, item);
  }

  String subtitleExtension(String codec) {
    return fileManager.subtitleExtension(codec);
  }
  Future<TrickPlayModel?> saveTrickPlayData(ItemBaseModel? item, Directory saveDirectory) async {
    return fileManager.saveTrickPlayData(item, saveDirectory, ref);
  }

  Future<ImagesData?> saveImageData(ImagesData? data, Directory saveDirectory) async {
    return fileManager.saveImageData(data, saveDirectory);
  }

  Future<List<Chapter>?> saveChapterImages(List<Chapter>? data, Directory itemPath) async {
    return fileManager.saveChapterImages(data, itemPath);
  }

  Future<ImageData?> urlDataToFileData(ImageData? data, Directory directory, String fileName) async {
    return fileManager.urlDataToFileData(data, directory, fileName);
  }
}
