// import 'dart:io';

// import 'package:dartx/dartx.dart';
// import 'package:flow_flutter/models/installation.dart';
// import 'package:flow_flutter/models/pictures_to_take_listing.dart';
// import 'package:flow_flutter/utils/installation_step.dart';
// import 'package:flutter/material.dart';
// import 'package:rxdart/rxdart.dart';

// import 'basic_controller.dart';

// // typedef PictureProcessing = Future<PictureTaken> Function(PictureTaken);

// class PicturesToTakeController extends Stream<List<PictureTaken>>
//     with
//         InstallationPart<List<PictureInfo>>,
//         BasicController<List<PictureTaken>> {
//   // final PictureProcessing pictureProcessor;
//   final List<Picture> picturesToTake;
//   final bool mandatoryPictures;

//   PicturesToTakeController(
//     this.picturesToTake, {
//     List<PictureInfo> currentPictures,
//     List<PictureInfo> currentCustomPictures,
//     // this.pictureProcessor,
//     this.mandatoryPictures = true,
//   }) : assert(picturesToTake != null) {
//     final pictures = currentPictures
//             ?.map((e) => PictureTaken(
//                   observation: e.observation,
//                   fileLocation: e.fileLocation,
//                   id: e.imageId,
//                   isProcessing: false,
//                 ))
//             ?.toList() ??
//         [];

//     final customPictures = currentCustomPictures
//             ?.map((e) => PictureTaken(
//                   observation: e.observation,
//                   fileLocation: e.fileLocation,
//                   id: e.imageId,
//                   isProcessing: false,
//                   isCustom: true,
//                 ))
//             ?.toList() ??
//         [];

//     add(pictures + customPictures);
//     updateReady();
//   }

//   void addPicture(PictureTaken picture) {
//     var picturesTaken = get();

//     // picturesTaken.removeWhere((element) => element.id == picture.id);

//     var alreadyTaken =
//         picturesTaken.firstOrNullWhere((element) => element.id == picture.id);

//     if (alreadyTaken != null) {
//       alreadyTaken?.mergeWith(picture);
//     } else {
//       
//       picturesTaken.add(picture..isProcessing = false);
//     }

//     // if (pictureProcessor == null) {
//     // picturesTaken.add(picture..isProcessing = false);
//     // } else {
//     //   picturesTaken.add(picture..isProcessing = true);
//     //
//     //   pictureProcessor(picture).then((value) {
//     //     if (isClosed) return;
//     //     picturesTaken.removeWhere((element) => element.id == picture.id);
//     //     picturesTaken.add(value..isProcessing = false);
//     //     add(picturesTaken);
//     //     updateReady();
//     //   });
//     // }

//     // print('FOTOS TIRADAS ${picturesTaken}');

//     add(picturesTaken);
//     updateReady();
//   }

//   void removePicture(PictureTaken picture) {
//     var picturesTaken = get();

//     final pictureTaken =
//         picturesTaken.firstOrNullWhere((pic) => pic.id == picture.id);

//     if (pictureTaken != null) {
//       File(pictureTaken.fileLocation.toString())
//           .delete()
//           .then((value) => print('Photo delete from storage'));
//     }

//     picturesTaken.removeWhere((pic) => pic.id == picture.id);
//     add(picturesTaken);
//     updateReady();
//   }

//   void updateReady() {
//     final isAllPicturesTaken = _hasRequiredPicturesTaken();
//     final isProcessing = _isProcessingAnyPicture();
//     final hasAllComments = _hasAllRequiredComments();

//     if (!isAllPicturesTaken && (mandatoryPictures ?? true)) {
//       readyStream.add(
//         ReadyState.notReady('Faltam imagens'),
//       );
//       return;
//     }

//     if (isProcessing) {
//       readyStream.add(
//         ReadyState.notReady(
//           'Aguardande o processamento de algumas imagens',
//         ),
//       );
//       return;
//     }

//     if (!hasAllComments) {
//       readyStream.add(
//         ReadyState.notReady(
//           'Faltam alguns comentários obrigatórios nas imagens',
//         ),
//       );
//       return;
//     }

//     readyStream.add(ReadyState.ready());
//   }

//   bool _hasRequiredPicturesTaken() {
//     final requiredPictures = picturesToTake.where((e) => e.required);
//     return requiredPictures
//         .all((requiredPic) => get().any((taken) => taken.id == requiredPic.id));
//   }

//   bool _isProcessingAnyPicture() =>
//       get().any((element) => element.isProcessing);

//   bool _hasAllRequiredComments() {
//     final requiredObservation =
//         picturesToTake.where((e) => e.observationRequired);

//     final requiredTaken = requiredObservation.where(
//       (requiredPic) => get().any((element) => element.id == requiredPic.id),
//     );

//     final requiredCommentsTaken =
//         requiredTaken.all((requiredPic) => get().any((pictureTaken) {
//               return pictureTaken.id == requiredPic.id &&
//                   pictureTaken.observation?.isNotEmpty == true;
//             }));

//     final customPicturesWithoutComments = get().where((element) =>
//         element.isCustom && (element.observation?.isBlank ?? true));

//     return requiredCommentsTaken && customPicturesWithoutComments.isEmpty;
//   }

//   List<PictureInfo> build() {
//     var pictureList = get()
//         .where((element) =>
//             element.fileLocation != null &&
//             File(element.fileLocation.toString()).existsSync())
//         .map((e) => PictureInfo(
//               imageId: e.id,
//               fileLocation: e.fileLocation,
//               observation: e.observation,
//               isCustom: false,
//             ))
//         .toList();
//     print("Picture list(build Pictures to take): "+pictureList.toString());
//     return pictureList;
//   }
// }

// class PictureTaken {
//   String id;
//   bool isProcessing;
//   Uri fileLocation;
//   String observation;
//   bool isCustom;

//   PictureTaken.newPicture(
//     this.id, {
//     this.isCustom = false,
//     this.fileLocation,
//     this.observation,
//   });

//   PictureTaken({
//     this.id,
//     this.isProcessing,
//     this.isCustom = false,
//     this.fileLocation,
//     this.observation,
//   });

//   void mergeWith(PictureTaken picture) {
//     if (picture.id != null) {
//       this.id = picture.id;
//     }

//     if (picture.isProcessing != null) {
//       this.isProcessing = picture.isProcessing;
//     }
//     if (picture.fileLocation != null) {
//       this.fileLocation = picture.fileLocation;
//     }
//     if (picture.observation != null) {
//       this.observation = picture.observation;
//     }
//   }

//   @override
//   String toString() =>
//       'PictureTaken[id=$id, isCustom=$isCustom, fileLocation=$fileLocation]\n';
// }
