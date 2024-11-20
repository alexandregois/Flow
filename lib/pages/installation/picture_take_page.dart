import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dartx/dartx.dart';
import 'package:flow_flutter/controller/V2Controllers/pictures_controller.dart';
import 'package:flow_flutter/models/pictures_to_take_listing.dart';
import 'package:flow_flutter/pages/installation/pictures_to_take_page.dart';
import 'package:flow_flutter/utils/animation/showup.dart';
import 'package:flow_flutter/utils/photoCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';

class PhotoTakePage extends StatefulWidget {
  final PicturesController pictureToTakeController;
  final Picture pictureToTake;
  final PictureTaken pictureTaken;
  // final bool onlyCameraSource;
  final List<Picture> picturesToTake;
  final bool isCustom;
  final context;

  const PhotoTakePage({
    Key key,
    this.pictureToTake,
    this.pictureTaken,
    this.picturesToTake,
    this.isCustom = false,
    @required this.pictureToTakeController,
    this.context,
    // this.onlyCameraSource,
  }) : super(key: key);

  @override
  PhotoTakePageState createState() => PhotoTakePageState();
}

class PhotoTakePageState extends State<PhotoTakePage> {
  // PictureTaken pictureTaken;
  TextEditingController _observationController;

  Timer _updateObservationTimer;

  String pictureToTakeId;

  @override
  void initState() {
    // pictureTaken ??= widget.pictureTaken;
    super.initState();

    // WidgetsFlutterBinding.ensureInitialized();

    _observationController = TextEditingController(
      text: widget.pictureTaken?.observation,
    );

    final String pictureToTakeId =
        widget.pictureToTake?.id ?? widget.pictureTaken?.id;
    // ?? DateTime.now().millisecondsSinceEpoch.toString();

    if (widget.pictureTaken?.fileLocation == null &&
        widget.pictureToTake.onlyCameraSource) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // print(pictureToTakeId);
        takeNewPicture(null, pictureToTakeId, ImageSource.camera,
            widget.pictureToTake.orientation);
      });
    }
  }

  @override
  void dispose() {
    _observationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //var ctx = widget.context;
    final GlobalKey<ScaffoldState> _scaffoldkey =
    new GlobalKey<ScaffoldState>();
    var theme = Theme.of(context);

    String pictureToTakeId =
        widget.pictureToTake?.id ?? widget.pictureTaken?.id;
    final indexOfCurrentPhoto =
        widget.picturesToTake?.indexOf(widget.pictureToTake) ?? -1;

    final hasPrevious = indexOfCurrentPhoto > 0 ? true : false;

    final previousPictureToTake =
    hasPrevious ? widget.picturesToTake[indexOfCurrentPhoto - 1] : null;

    final pictureTakenForPreviousScreen = hasPrevious
        ? widget.pictureToTakeController.get().firstOrNullWhere(
            (element) => element.id == previousPictureToTake.id)
        : null;

    final hasNext = indexOfCurrentPhoto >= 0
        ? widget.picturesToTake.length > indexOfCurrentPhoto + 1
        : false;

    final nextPictureToTake =
    hasNext ? widget.picturesToTake[indexOfCurrentPhoto + 1] : null;

    final pictureTakenForNextScreen = hasNext
        ? widget.pictureToTakeController
        .get()
        .firstOrNullWhere((element) => element.id == nextPictureToTake.id)
        : null;

    return StreamBuilder<PictureTaken>(
        stream: widget.pictureToTakeController.map((event) =>
            event.firstOrNullWhere((element) => element.id == pictureToTakeId)),
        builder: (context, snapshot) {
          final pictureTaken = snapshot.data;

          return
            // WillPopScope(
            // onWillPop: widget.pictureToTakeController.sendPictures,
            Scaffold(
              key: _scaffoldkey,
              body: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // Text(
                        //   widget.pictureToTake?.name ?? 'Foto personalizada',
                        //   style: theme.textTheme.headline6,
                        //   textAlign: TextAlign.center,
                        // ),

                        if ((widget.pictureToTake?.required == true) &&
                            pictureTaken?.fileLocation == null)
                        // Padding(
                        //   padding: const EdgeInsets.all(16),
                        //   child: Text(
                        //     'Foto obrigatória',
                        //     textAlign: TextAlign.center,
                        //     style: TextStyle(color: Colors.red),
                        //   ),
                        // ),
                          Text(
                            widget.pictureToTake?.description ?? '',
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                  PhotoLoaderCard(
                    showDeleteButton: true,
                    onlyCameraSource: widget.pictureToTake.onlyCameraSource,
                    pictureTaken: pictureTaken,
                    label: widget.pictureToTake.name,
                    required: widget.pictureToTake.required,
                    pictureToTakeId: pictureToTakeId,
                    takePicture: takeNewPicture,
                    deletePicture: widget.pictureToTakeController.removePicture,
                    orientation: widget.pictureToTake.orientation,
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      enabled: pictureTaken?.fileLocation != null,
                      controller: _observationController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Comentário',
                        errorText: (pictureTaken?.observation?.isEmpty ?? true) &&
                            (widget.pictureToTake?.observationRequired ==
                                true ||
                                widget.isCustom)
                            ? 'Obrigatório'
                            : null,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (value) {
                        _setObservation(value, pictureTaken);
                      },
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        FloatingActionButton(
                          elevation: 2,
                          child: Icon(
                            Icons.arrow_back,
                            color: theme.colorScheme.onSecondary,
                          ),
                          backgroundColor: theme.colorScheme.secondary,
                          onPressed: () {
                            PicturesToTakePageState.of(context).setPictures(
                              pictureToTake: previousPictureToTake,
                              pictureTaken: pictureTakenForPreviousScreen,
                              picturesToTake: widget.picturesToTake,
                            );
                          },
                        ),
                        Spacer(),
                        if (hasNext)
                          FloatingActionButton.extended(
                            elevation: 2,
                            label: Icon(
                              Icons.arrow_forward,
                              color: theme.colorScheme.onSecondary,
                            ),
                            icon: AutoSizeText(
                              nextPictureToTake.name,
                              minFontSize: 8,
                              style:
                              TextStyle(color: theme.colorScheme.onSecondary),
                            ),
                            backgroundColor: theme.colorScheme.secondary,
                            onPressed: () {
                              PicturesToTakePageState.of(context).setPictures(
                                pictureToTake: nextPictureToTake,
                                pictureTaken: pictureTakenForNextScreen,
                                picturesToTake: widget.picturesToTake,
                              );
                            },
                          ),
                      ],
                    ),
                  )
                ],
              ),
            );
          // );
        });
  }

  Future takeNewPicture(PictureTaken pictureTaken, String pictureToTakeId, ImageSource source, String orientation) async {

    try {

      final pickedFile = await ImagePicker().pickImage(
        source: source ?? ImageSource.camera,
        imageQuality: 90,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (pickedFile != null) {

        File rotatedImage = await FlutterExifRotation.rotateImage(path: pickedFile.path);
        final size = ImageSizeGetter.getSize(FileInput(File(rotatedImage.path)));

        if (orientation == "V") {
          if(size.height < size.width) {
            showSnackBar();
            return;
          }
        } else if(size.height > size.width) {
          showSnackBar();
          return;
        }

        if (pictureTaken == null) {
          pictureTaken = PictureTaken.newPicture(
            pictureToTakeId,
            isCustom: widget.isCustom,
            fileLocation: Uri.parse(pickedFile.path),
          );
        } else {
          final oldPicture = pictureTaken.fileLocation;
          pictureTaken.fileLocation = Uri.parse(pickedFile.path);

          deletePicture(oldPicture);
        }

        pictureTaken.isRegister = false;

        setState(() {
          widget.pictureToTakeController.addPicture(pictureTaken);
        });
      }
    } catch (e) {
      _errorDialog(e.toString());
    }

  }

  void _errorDialog(String text) {
    showDialog(
      context: context,
      barrierColor: Colors.red.withOpacity(0.8),
      builder: (context) => ShowUp.tenth(
        duration: 200,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          title: Text("Erro"),
          content: Text(text),
        ),
      ),
    );
  }

  void deletePicture(Uri fileLocation) {
    File(fileLocation.toString()).delete().then((value) {
      print('Photo deleted');
    });
  }

  void _setObservation(String observation, [PictureTaken pictureTaken]) {

    pictureTaken?.observation = observation;
    _updateObservationTimer?.cancel();
    _updateObservationTimer = Timer(1.seconds, () {
      widget.pictureToTakeController.addPicture(pictureTaken);
    });
  }

  void showSnackBar() {
    final snackBar = SnackBar(
      duration: Duration(seconds: 4),
      backgroundColor: Colors.red,
      content: Padding(
        padding: const EdgeInsets.all(35),
        child: Text('A foto está na orientação incorreta, tire novamente.',
            style: TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
