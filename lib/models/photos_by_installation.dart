class PhotosForInstallation {
  List<PhotoIDAndUrl> photos;
  List<PhotoIDAndUrl> signatures;

  PhotosForInstallation({
    this.photos,
    this.signatures,
  });

  PhotosForInstallation.fromJson(Map<String, dynamic> json) {
    if (json['photos'] != null) {
      photos = [];
      json['photos'].forEach((v) {
        photos.add(PhotoIDAndUrl.fromJson(v));
      });
    }

    if (json['checklistSignature'] != null) {
      signatures = [];
      json['checklistSignature'].forEach((v) {
        signatures.add(PhotoIDAndUrl.fromJson(v));
      });
    }
  }
}

class PhotoIDAndUrl {
  String id;
  // String key;
  String url;
  int cloudFileId;
  String featureId;
  

  PhotoIDAndUrl(
    this.id, [
    // this.key,
    this.url,
    this.featureId,
  ]);

  PhotoIDAndUrl.fromJson(Map<String, dynamic> json) {
    id = json['key'].toString();
    cloudFileId = json['id'];
    // key = json['key'];
    url = json['url'];
    featureId = json["featureId"];
    // isCustom = json['isCustom'] ?? false;
  }
}
