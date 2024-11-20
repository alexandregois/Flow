import 'dart:io';

import 'package:flow_flutter/controller/V2Controllers/pictures_controller.dart';
import 'package:flow_flutter/utils/animation/animated_scale.dart'
    as animatedscale;
import 'package:flow_flutter/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'denox_chip_button.dart';

class PhotoLoaderCard extends StatefulWidget {
  final String label;
  final bool required;
  final bool showDeleteButton;
  final bool onlyCameraSource;
  final bool enabled;
  final String pictureToTakeId;
  final PictureTaken pictureTaken;
  final Function(PictureTaken, String, ImageSource, String) takePicture;
  final Function(PictureTaken) deletePicture;
  final context;
  final String orientation;

  PhotoLoaderCard(
      {this.label,
      this.showDeleteButton = true,
      this.enabled = true,
      this.pictureTaken,
      this.takePicture,
      this.deletePicture,
      this.pictureToTakeId,
      this.required,
      this.onlyCameraSource = false,
      this.context,
      this.orientation});

  @override
  _PhotoLoaderCardState createState() => _PhotoLoaderCardState();
}

class _PhotoLoaderCardState extends State<PhotoLoaderCard>
    with SingleTickerProviderStateMixin {
  // File _picture;
  // Future<bool> _sendPhotoRequest;

  bool _showingPictureOptions = false;

  @override
  void dispose() {
    // _picture?.delete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    printDebug(widget.orientation);

    String orientationText =
        widget.orientation == "V" ? "VERTICAL" : "HORIZONTAL";

    var textStyle = TextStyle(color: Colors.white);
    var pictureTaken = widget.pictureTaken;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: <Widget>[
            Center(
              child: Visibility(
                visible: pictureTaken != null,
                child: CircularProgressIndicator(),
              ),
            ),
            Positioned.fill(
              child: _getPhotoToShow(pictureTaken),
            ),
            Visibility(
              visible: widget.label != null && widget.enabled,
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: animatedscale.AnimatedScale(
                    delay: 150,
                    scale: _showingPictureOptions ? 0 : 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      child: Text(
                        widget.label ?? "Toque para alterar",
                        style: textStyle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: !widget.enabled
                      ? null
                      : () {
                          setState(() {
                            _showingPictureOptions = !_showingPictureOptions;
                          });
                        },
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        animatedscale.AnimatedScale(
                          duration: 300,
                          scale: _showingPictureOptions ? 1 : 0,
                          curve: _showingPictureOptions
                              ? Curves.easeInOut
                              : Curves.easeInBack,
                          child: Container(
                            height: 54,
                            child: Material(
                              color: Colors.transparent,
                              child: DenoxChipButton(
                                borderColor: Colors.white,
                                onTap: () async {
                                  return showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.red,
                                          title: const Text('Atenção',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 20)),
                                          content: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.07,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Text(
                                              "Essa foto deve ser tirada na $orientationText!",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          actions: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.blue.shade700,
                                                ),
                                                child: const Text("Ok"),
                                                onPressed: () async {
                                                  Navigator.pop(context);

                                                  widget.takePicture(
                                                      pictureTaken,
                                                      widget.pictureToTakeId,
                                                      ImageSource.camera,
                                                      widget.orientation);
                                                },
                                              ),
                                            ),
                                          ],
                                        );
                                      });
                                },
                                title: Text(
                                  "Câmera",
                                  style: TextStyle(color: Colors.white),
                                ),
                                icon: Icon(
                                  Icons.camera_alt,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        widget.onlyCameraSource
                            ? Container()
                            : animatedscale.AnimatedScale(
                                duration: 300,
                                delay: 50,
                                scale: _showingPictureOptions ? 1 : 0,
                                curve: _showingPictureOptions
                                    ? Curves.easeInOut
                                    : Curves.easeInBack,
                                child: Container(
                                  height: 54,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: DenoxChipButton(
                                      borderColor: Colors.white,
                                      onTap: () {
                                        widget.takePicture(
                                            pictureTaken,
                                            widget.pictureToTakeId,
                                            ImageSource.gallery,
                                            widget.orientation);
                                      },
                                      title: Text("Galeria",
                                          style:
                                              TextStyle(color: Colors.white)),
                                      icon: Icon(
                                        Icons.image,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: pictureTaken != null,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4, right: 4),
                  child: IconButton(
                    iconSize: 34,
                    onPressed: () => widget.deletePicture(pictureTaken),
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getPhotoToShow(PictureTaken picture) {
    if (picture != null) {
      return Image.file(
        File(picture.fileLocation.toString()),
        fit: BoxFit.cover,
      );
    } else {
      // var photoUrl = _photoUrl(local);

      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        _showingPictureOptions
            ? Container()
            : Text(
                "Toque para adicionar uma foto",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
        widget.required
            ? Text(
                "*Obrigatória",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontSize: 13),
              )
            : Container(),
      ]);
    }
  }

  bool showDelete(Uri local) => local != null || widget.pictureTaken != null;
}
