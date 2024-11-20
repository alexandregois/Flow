import 'dart:io';
import 'package:dartx/dartx.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/models/photos_by_installation.dart';
import 'package:flow_flutter/models/pictures_to_take_listing.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/installation_step.dart';
import 'package:flow_flutter/utils/utils.dart';
import '../basic_controller.dart';

// typedef PictureProcessing = Future<PictureTaken> Function(PictureTaken);

class PicturesController extends Stream<List<PictureTaken>>
    with
        InstallationPart<List<PictureInfo>>,
        BasicController<List<PictureTaken>> {
  List<Picture> picturesToTake;
  final bool mandatoryPictures;
  final bool onlyCameraSource;
  final String id;
  final RequestsRepository requestsRepo;
  final int installationCloudId;
  final Future<List<Picture>> Function(Picture, String, int)
  addNewCustomPicture;
  final void Function(int, String, String, bool, int) setFileIdforPicture;
  int customPicturesCount;

  PicturesController(
      this.picturesToTake, {
        this.onlyCameraSource,
        this.setFileIdforPicture,
        this.addNewCustomPicture,
        this.installationCloudId,
        this.requestsRepo,
        String name,
        this.id,
        List<PictureInfo> currentPictures,
        // List<PictureInfo> currentCustomPictures,
        this.mandatoryPictures = true,
        this.customPicturesCount,
      }) : assert(picturesToTake != null) {
    if (customPicturesCount == null) customPicturesCount = 0;
    this.name = name;
    // print("currentPictures: " + currentPictures.toString());
    final pictures = currentPictures
        ?.map((e) => PictureTaken(
      observation: e.observation,
      fileLocation: e.fileLocation,
      id: e.imageId,
      isProcessing: false,
      sent: e.sent,
    ))
        ?.toList() ??
        [];
    add(pictures);
    // print("currentPictures: " + pictures.toString());
    updateReady();
  }

  Future<void> addPicture(PictureTaken picture) async {
    var picturesTaken = get();

    // picturesTaken.removeWhere((element) => element.id == picture.id);

    var alreadyTaken =
    picturesTaken.firstOrNullWhere((element) => element.id == picture.id);

    if (alreadyTaken != null) {
      alreadyTaken?.mergeWith(picture);
    } else {
      picturesTaken.add(picture..isProcessing = false);
    }

    print('FOTOS TIRADAS $picturesTaken');

    add(picturesTaken);
    updateReady();

    // bool sent = await _sendPicture(picturesTaken);
    // if (sent) updatePictureSent(true, picturesTaken);

    // if (sent) setPictureConfigPhotoAsSent();
  }

  Future<bool> sendPictures() async {
    var picturesTaken = get();
    updatePicture(picturesTaken);
    print("sendPictures: $picturesTaken");

    return true;
  }

  void updatePicture(picturesTaken) async {
    bool sent = await _sendPicture(picturesTaken);
    if (sent) updatePictureSent(true, picturesTaken);
  }

  void removePicture(PictureTaken picture) {
    var picturesTaken = get();

    final pictureTaken =
    picturesTaken.firstOrNullWhere((pic) => pic.id == picture.id);

    if (pictureTaken != null) {
      File(pictureTaken.fileLocation.toString())
          .delete()
          .then((value) => print('Photo delete from storage'));
    }

    picturesTaken.removeWhere((pic) => pic.id == picture.id);
    add(picturesTaken);
    updateReady();
    setFileIdforPicture(null, id, picture.id, false, 2);
    // updatePictureSent(true, picturesTaken);
  }

  void newCustomPicture() async {
    customPicturesCount = customPicturesCount + 1;
    String count = customPicturesCount.toString();

    List<Picture> list = await addNewCustomPicture(
        Picture.fromValues(
            isCoverPicture: false,
            id: id + count.toString(),
            name: "Foto adicional " + count,
            onlyCameraSource: false,
            description: '',
            order: (get().count() + 2 + customPicturesCount),
            required: false,
            deleted: false,
            sent: false,
            observationDesc: "Observação",
            observationRequired: false,
            orientation: 'H'),
        id,
        customPicturesCount);
    picturesToTake = list;
    updateReady();
  }

  void updateReady() {
    final isAllPicturesTaken = _hasRequiredPicturesTaken();
    final isProcessing = _isProcessingAnyPicture();
    final hasAllComments = _hasAllRequiredComments();

    if (!isAllPicturesTaken && (mandatoryPictures ?? true)) {
      readyStream.add(
        ReadyState.notReady('Faltam imagens obrigatórias'),
      );
      return;
    }

    if (isProcessing) {
      readyStream.add(
        ReadyState.notReady(
          'Aguardande o processamento de algumas imagens',
        ),
      );
      return;
    }

    if (!hasAllComments) {
      readyStream.add(
        ReadyState.notReady(
          'Faltam alguns comentários obrigatórios nas imagens',
        ),
      );
      return;
    }

    readyStream.add(ReadyState.ready());
  }

  bool _hasRequiredPicturesTaken() {
    final requiredPictures = picturesToTake.where((e) => e.required);
    return requiredPictures
        .all((requiredPic) => get().any((taken) => taken.id == requiredPic.id));
  }

  bool _isProcessingAnyPicture() =>
      get().any((element) => element.isProcessing);

  bool _hasAllRequiredComments() {
    final requiredObservation =
    picturesToTake.where((e) => e.observationRequired);

    final requiredTaken = requiredObservation.where(
          (requiredPic) => get().any((element) => element.id == requiredPic.id),
    );

    final requiredCommentsTaken =
    requiredTaken.all((requiredPic) => get().any((pictureTaken) {
      return pictureTaken.id == requiredPic.id &&
          pictureTaken.observation?.isNotEmpty == true;
    }));

    final customPicturesWithoutComments = get().where((element) =>
    element.isCustom && (element.observation?.isBlank ?? true));

    return requiredCommentsTaken && customPicturesWithoutComments.isEmpty;
  }

  List<PictureInfo> build() {
    var pictureList = get()
        .where((element) =>
    element.fileLocation != null &&
        File(element.fileLocation.toString()).existsSync())
        .map((e) => PictureInfo(
      imageId: e.id,
      fileLocation: e.fileLocation,
      observation: e.observation,
      isCustom: false,
      sent: e.sent,
    ))
        .toList();
    print("Picture list(build Pictures): " + pictureList.toString() ?? "nulo");
    return pictureList;
  }

  Future<bool> _sendPicture(List<PictureTaken> picturesTaken) async {
    final List<PhotoIDAndUrl> photosToSend = [];
    var photosSent = [];
    photosToSend.addAll(picturesTaken.map((e) {
      if (e.sent == null) e.sent = false;
      return !e.sent
          ? PhotoIDAndUrl(
        e.id.toString(),
        e.fileLocation.toString(),
        id,
      )
          : null;
    }));
    photosToSend.removeWhere((element) => element == null);
    await Future.forEach(photosToSend, (PhotoIDAndUrl toSend) async {
      try {
        final fileId = await requestsRepo.sendInstallationPicture(
          installationCloudId,
          toSend.featureId,
          toSend.id,
          File(toSend.url),
        );

        if (fileId != null) {
          print("File id: $fileId");
          photosSent.add(toSend);
          if (toSend.id.contains("CHECKLISTSIGN")) {
            setFileIdforPicture(fileId, toSend.featureId, toSend.id, true, 0);
          } else if (toSend.id.contains("FINISHSIGN")) {
            print('set finish fileid');
            setFileIdforPicture(fileId, toSend.featureId, toSend.id, true, 1);
          } else {
            print("set picture fileid ${toSend.featureId}");
            setFileIdforPicture(fileId, toSend.featureId, toSend.id, true, 2);
          }
        } else if (fileId == null) {
          return false;
        }
      } catch (e) {
        printDebug('File not found: $e');
        if (e is FileSystemException) {
          // fileNotFounds++;
        } else {
          throw e;
        }
      }
    });

    return true;
  }

//   void updateOnePicture(bool sent, PictureTaken pictureTaken){
//  if(picturesToTake.any((element) => element.id == pictureTaken.id))
//     pictureTaken.sent = sent;
//   }
  void updatePictureSent(bool sent, List<PictureTaken> picturesTaken) {
    picturesToTake.forEach((picture) {
      if (picturesTaken
          .firstOrNullWhere((element) => element.id == picture.id) !=
          null) picture.sent = sent;
    });
  }
}

class PictureTaken {
  String id;
  bool isProcessing;
  bool sent;
  Uri fileLocation;
  String observation;
  bool isCustom;
  bool isRegister = false;

  PictureTaken.newPicture(
      this.id, {
        this.isCustom = false,
        this.fileLocation,
        this.observation,
      });

  PictureTaken(
      {this.id,
        this.isProcessing,
        this.isCustom = false,
        this.fileLocation,
        this.observation,
        this.sent,
        this.isRegister});

  void mergeWith(PictureTaken picture) {
    if (picture.id != null) {
      this.id = picture.id;
    }

    if (picture.isProcessing != null) {
      this.isProcessing = picture.isProcessing;
    }
    if (picture.fileLocation != null) {
      this.fileLocation = picture.fileLocation;
    }
    if (picture.observation != null) {
      this.observation = picture.observation;
    }
  }

  @override
  String toString() =>
      'PictureTaken[id=$id, isCustom=$isCustom, fileLocation=$fileLocation]\n';
}
