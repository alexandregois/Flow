enum VideoType {
  asset,
  file,
  network,
  recorded,
}

class VideoData {
  final String name;
  final String path;
  final VideoType type;
  final int localId;
  final int cameraId;

  VideoData({
    this.name,
    this.path,
    this.type,
    this.localId,
    this.cameraId
  });
}
