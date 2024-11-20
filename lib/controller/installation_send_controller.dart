import 'dart:async';
import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:flow_flutter/controller/basic_controller.dart';
import 'package:flow_flutter/models/exceptions.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/models/photos_by_installation.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/technichal_visit_stage.dart';
import 'package:flow_flutter/utils/utils.dart';

class InstallationSendController extends Stream<InstallationSendState>
    with BasicController<InstallationSendState> {
  final RequestsRepository requestsRepo;
  final InstallationRepository installationRepository;

  InstallationSendController(
    this.requestsRepo,
    this.installationRepository,
  ) {
    add(InstallationSendState());
  }

  void start([int installationId]) {
    if (get().sendingInstallations.isEmpty) {
      if (installationId != null) {
        installationRepository
            .getInstallation(installationId)
            .then(_handleInstallation);
      } else {
        installationRepository.getInstallations().then((installations) async {
          for (var model in installations) {
            await _handleInstallation(model);
          }
        });
      }
    }
  }

  Future _handleInstallation(Installation installation) async {
    print('Installation stage: ${installation.stage.stage}');

    if (!installation.isReadyToSend) {
      //se nao estiver enviando retire da lista para enviar
      _update((state) => state._removeForId(installation.appId));
      return;
    }

    await installationRepository.putInstallation(installation..stage.message = null);

    try {
      //Primeira vez conta as fotos e seta variavel de pendente
      await _prepareAndSendPictures(installation);

      //Envia com pendencia
      var sentInstallation = await _sendInstallation(installation);

      //Verifica pendencia
      if (installation.installationType.installationTypes.pictureUploadCompleted == false) {
        installationRepository.putInstallation(installation..stage);
        //Envia as fotos e seta ID
        await _prepareAndSendPictures(installation);

        // //Envia a instalacao sem pendencia
        // await _sendInstallation(installation);
      }

      print("sentInstallation:$sentInstallation pictureUploadCompleted:${installation.installationType.installationTypes.pictureUploadCompleted}");

      if (sentInstallation && installation.installationType.installationTypes.pictureUploadCompleted) {
        print("Deletando instalações");
        await installationRepository.deleteInstallations([installation]);
      }
    } catch (e) {
      print('Installation send error: $e');
      var installationWithErrors = await installationRepository.getInstallation(installation.appId);

      if (e is InstallationRefusedException) {
        installationWithErrors.stage.stage = TechnicalVisitStage.HAS_ERRORS;
        installationWithErrors.stage.message = e.cause;
      } else {
        if (e is SocketException) {
          installationWithErrors.stage.message =
              'Sem conexão com a internet. Por favor, verifique sua conexão e tente novamente.';
        } else {
          installationWithErrors.stage.message = e.toString();
        }
      }

      installationRepository.putInstallation(installationWithErrors);
    }

    _update((state) => state._removeForId(installation.appId));
  }

  Future<bool> _sendInstallation(Installation installation) async {

    _update((state) => state.add(SendingInstallation(installation.appId, Step.sendingInstallation)));

    String mensagem = await requestsRepo.sendInstallation(installation);

    if (mensagem == "") {
      installationRepository.putInstallation(installation);
    } else {
      throw mensagem;
      // return false;
    }
    return true;
  }

  Future<bool> _prepareAndSendPictures(Installation installation) async {
    // bool hasSignature = false;

    //Seta barra de progresso para a visualização do user
    int maxProgress = 0;
    installation.installationType.installationTypes.config?.features
        ?.forEach((feature) {
      if (feature?.checklistConfig != null) if (feature
              .checklistConfig.requireSign &&
          feature.checklistConfig?.currentCheckList?.signatureUri != null &&
          feature.checklistConfig?.currentCheckList?.cloudFileId == null) {
        maxProgress += 1;
        // hasSignature = true;
      }
      if (feature?.pictureConfig != null)
        maxProgress +=
            (feature?.pictureConfig?.currentPicturesInfo?.count((element) {
                  if (element.sent == null || element.sent == false)
                    return true;
                  else
                    return false;
                }) ??
                0);
      if (feature?.finishConfig != null) if (feature.finishConfig.requireSign &&
          feature.finishConfig?.signatureUri != null &&
          feature.finishConfig?.cloudFileId == null) {
        maxProgress += 1;
        // hasSignature = true;
      }
    });
    if (maxProgress == 0) maxProgress = 1;

    //atualiza estado da interface
    _update((state) => state.add(SendingInstallation(
          installation.appId,
          Step.uploadingPictures,
          maxProgress: maxProgress,
          currentProgress: 0,
        )));

    PhotosForInstallation photosUploadedForInstallation;
    //Buscar fotos que ja foram enviadas
    try {
      photosUploadedForInstallation =
          await requestsRepo.getPhotosForInstallation(installation.cloudId);
    } catch (e) {
      // print(e);
      printDebug('Error syncronizing photos: $e');
      if (e is SocketException) {
        throw e;
      }
      throw 'Não foi possível sincronizar o envio de fotos.';
    }

    var photosSent = [
      // ...(photosUploadedForInstallation.photos ?? []),
      // ...(photosUploadedForInstallation.signatures ?? []),
    ];

    if (photosUploadedForInstallation.photos != null &&
        photosUploadedForInstallation.photos.isNotEmpty)
      installation?.installationType?.installationTypes?.config?.features
          ?.forEach((feature) {
        if (feature.featureType.id.contains("PICTURE")) {
          //para cada foto salva veja se alguma delas tem o Id igual a de uma ja enviada
          feature.pictureConfig.items.forEach((picture) {
            var found = photosUploadedForInstallation.photos.firstWhere(
                (photoApi) => picture.id == photoApi.id, orElse: () {
              return null;
            });
            if (found != null) {
              photosSent.add(found);
              picture.cloudFileId = found.cloudFileId;
            }
            //se ja foi enviada salva o cloudFileId
          });
        }

        // if (feature.featureType.id.contains("CHECKLIST") &&
        //     feature.checklistConfig.requireSign) {

        //     }
        // if (feature.featureType.id.contains("FINISH") &&
        //     feature.finishConfig.requireSign) {}
      });
    printDebug("photosSent: ${photosSent.count()} fotos encontradas");
    //cria a lista de arquivos para enviar
    final List<PhotoIDAndUrl> photosToSend = [];
    installation?.installationType?.installationTypes?.config?.features
        ?.forEach((feature) {
      if (feature.featureType.id.contains("PICTURE"))
        photosToSend.addAll(feature.pictureConfig.currentPicturesInfo.map((e) =>
            (e.sent == null ||
                    !e.sent ||
                    feature.pictureConfig.items
                            .firstWhere((element) => element.id == e.imageId)
                            .cloudFileId ==
                        null)
                ? PhotoIDAndUrl(
                    e.imageId.toString(),
                    e.fileLocation.toString(),
                    feature.id,
                  )
                : null));
      if (feature.featureType.id.contains("CHECKLIST") &&
          feature.checklistConfig.requireSign) {
        // print(
        //     "achei uma assinatura, uri: ${feature.checklistConfig.currentCheckList.signatureUri.toString()}");
        if (feature.checklistConfig.currentCheckList.cloudFileId == null)
          photosToSend.add(PhotoIDAndUrl(
            'CHECKLISTSIGN',
            feature.checklistConfig.currentCheckList.signatureUri.toString(),
            feature.id,
          ));
      }
      if (feature.featureType.id.contains("FINISH") &&
          feature.finishConfig.requireSign) {
        print("Finish Signature Encontrado");
        if (feature.finishConfig.cloudFileId == null)
          photosToSend.add(PhotoIDAndUrl(
            'FINISHSIGN',
            feature.finishConfig.signatureUri.toString(),
            feature.id,
          ));
      }
    });

    int fileNotFounds = 0;
    var arrayFilesNotFound = [];
    photosToSend.removeWhere((element) => element == null);
    print(photosToSend.toString());

    //Passando primeira vez sem enviar foto
    if (installation
            .installationType.installationTypes.pictureUploadCompleted ==
        null) {
      //Parar aqui, pois vai enviar em um segundo momento
      installation.installationType.installationTypes.pictureUploadCompleted =
          photosToSend.length == 0 ? true : false;
      return true;
    } else {
      await Future.forEach(photosToSend, (PhotoIDAndUrl toSend) async {
        _update((state) => state.add(SendingInstallation(
              installation.appId,
              Step.uploadingPictures,
              maxProgress: maxProgress,
              currentProgress: photosSent.length,
            )));

        if (photosSent.any((element) => element.id == toSend.id)) {
          return;
        }

        try {
          final fileId = await requestsRepo.sendInstallationPicture(
            installation.cloudId,
            toSend.featureId,
            toSend.id,
            File(toSend.url),
          );

          if (fileId != null) {
            print("File id: $fileId");
            photosSent.add(toSend);
            if (toSend.id.contains("CHECKLISTSIGN"))
              installation.installationType.installationTypes.config?.features
                  ?.firstOrNullWhere(
                      (feature) => feature.id == toSend.featureId)
                  ?.checklistConfig
                  ?.currentCheckList
                  ?.cloudFileId = fileId;
            else if (toSend.id.contains("FINISHSIGN")) {
              print('set finish fileid');
              installation.installationType.installationTypes.config?.features
                  ?.firstOrNullWhere(
                      (feature) => feature.id == toSend.featureId)
                  ?.finishConfig
                  ?.cloudFileId = fileId;
            } else {
              installation.installationType.installationTypes.config?.features
                  ?.firstOrNullWhere(
                      (feature) => feature.id == toSend.featureId)
                  ?.pictureConfig
                  ?.items
                  ?.firstOrNullWhere((picture) => picture.id == toSend.id)
                  ?.cloudFileId = fileId;
            }
            //Para cada foto enviada, atualiza o repositorio local
            printDebug("SALVANDO FOTOS ");

            await installationRepository.putInstallation(installation);
            printDebug("FOTOS SALVAS");
          }
        } catch (e) {
          printDebug('File not found: $e');
          if (e is FileSystemException) {
            fileNotFounds++;
            arrayFilesNotFound.add(toSend);
          } else {
            throw e;
          }
        }
      });
      print(
          "photosSent.length: ${photosSent.length} == photosToSend.length: ${photosToSend.length}");
      if (fileNotFounds > 0) {
        String error =
            '$fileNotFounds fotos da instalação não foram encontradas no aparelho. Fotos Faltantes: ';
        arrayFilesNotFound.forEach((photoNotFound) {
          if (photoNotFound != null && photoNotFound.id != null)
            error = error +
                photoNotFound.id.toString() +
                ", "; //ALTERAR PARA UMA FUNÇÃO QUE PEGA O NOME DA FOTO PELA KEY
        });
        throw error;
      } else {
        if (photosSent.length >= photosToSend.length) {
          installation
              .installationType.installationTypes.pictureUploadCompleted = true;
          return true;
        }
      }

      return false;
    }
  }

  void _update(void Function(InstallationSendState) callback) {
    callback(get());
    add(get());
  }
}

class InstallationSendState {
  List<SendingInstallation> _sending = [];

  void add(SendingInstallation sendingInstallation) {
    _sending.removeWhere((element) =>
        element.installationId == sendingInstallation.installationId);
    _sending.add(sendingInstallation);
  }

  SendingInstallation getForId(int installationId) =>
      _sending.firstOrNullWhere((e) => e.installationId == installationId);

  void _removeForId(int installationId) {
    _sending.removeWhere((e) => e.installationId == installationId);
  }

  Iterable<SendingInstallation> get sendingInstallations => _sending;
}

class SendingInstallation {
  final int installationId;
  final int maxProgress;
  final int currentProgress;
  final Step step;

  const SendingInstallation(
    this.installationId,
    this.step, {
    this.maxProgress,
    this.currentProgress,
  });
}

enum Step {
  sendingInstallation,
  uploadingPictures,
}

extension on Installation {
  bool get isReadyToSend => this.stage.stage == TechnicalVisitStage.FINISHED;
}
