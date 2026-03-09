import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../core/utils/logger.dart';

class PosterDownloadService {
  Future<String?> downloadPoster(String url) async {
    if (url.isEmpty || url == 'N/A') return null;

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = '${const Uuid().v4()}.jpg';
        final filePath = '${directory.path}/$fileName';

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        Logger.info('Poster downloaded to $filePath');
        return filePath;
      }
      return null;
    } catch (e, st) {
      Logger.error('Failed to download poster', e, st);
      return null;
    }
  }

  Future<String?> getLocalPosterPath(String localUrl) async {
    final file = File(localUrl);
    if (await file.exists()) {
      return localUrl;
    }
    return null;
  }
}
