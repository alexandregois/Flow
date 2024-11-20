import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dartx/dartx.dart';
import 'package:flow_flutter/controller/V2Controllers/pictures_controller.dart';
import 'package:flow_flutter/models/pictures_to_take_listing.dart';
import 'package:flow_flutter/pages/installation/picture_take_page.dart';
import 'package:flow_flutter/repository/impl/picture_plate_bloc.dart';
import 'package:flow_flutter/utils/no_glow_behavior.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flow_flutter/widget/lazy_stream_builder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PicturesToTakePage extends StatefulWidget {
  final PicturesController controller;

  const PicturesToTakePage({Key key, this.controller}) : super(key: key);

  @override
  PicturesToTakePageState createState() => PicturesToTakePageState();
}

class PicturesToTakePageState extends State<PicturesToTakePage> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  PictureTaken _pictureTaken;
  Picture _pictureToTake;
  List<Picture> _picturesToTake;
  bool _isCustom = false;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: NoGlowBehavior(),
      child: WillPopScope(
        onWillPop: () async => !await _navigatorKey.currentState.maybePop(),
        child: Navigator(
          key: _navigatorKey,
          pages: [
            MaterialPage(
              key: ValueKey('_PicturesListing'),
              child: _PicturesListing(
                addNewPicture: addNewPicture,
                controller: widget.controller,
              ),
            ),
            if (_pictureTaken != null || _pictureToTake != null)
              MaterialPage(
                key: ValueKey(_pictureToTake),
                child: PhotoTakePage(
                  //context: context,
                  pictureToTakeController: widget.controller,
                  isCustom: _isCustom,
                  pictureTaken: _pictureTaken,
                  pictureToTake: _pictureToTake,
                  picturesToTake: _picturesToTake,
                  // onlyCameraSource: widget.controller.onlyCameraSource,
                ),
              ),
          ],
          onPopPage: _onPopPage,
        ),
      ),
    );
  }

  bool _onPopPage(Route route, result) {
    if (!route.didPop(result)) {
      return false;
    }

    setState(() {
      _pictureToTake = null;
      _pictureTaken = null;
      _picturesToTake = null;
      _isCustom = false;
    });

    return true;
  }

  void setPictures({
    Picture pictureToTake,
    bool customPhoto = false,
    PictureTaken pictureTaken,
    List<Picture> picturesToTake,
  }) {
    setState(() {
      _pictureToTake = pictureToTake;
      _pictureTaken = pictureTaken;
      _picturesToTake = picturesToTake;
      _isCustom = customPhoto;
    });
  }

  void addNewPicture({List<Picture> picturesToTake}) {
    printDebug(
        "Pictures to take Before: ${_picturesToTake.toString()}\nPictures to take after: ${picturesToTake.toString()}");
    setState(() {
      _picturesToTake = picturesToTake;
    });
  }

  static PicturesToTakePageState of(BuildContext context) =>
      context.findAncestorStateOfType<PicturesToTakePageState>();
}

class _PicturesListing extends StatefulWidget {
  final PicturesController controller;
  final Function({
  List<Picture> picturesToTake,
  }) addNewPicture;

  _PicturesListing({
    Key key,
    @required this.controller,
    @required this.addNewPicture,
  }) : super(key: key);

  @override
  _PicturesListingState createState() => _PicturesListingState();
}

class _PicturesListingState extends State<_PicturesListing> {
  @override
  Widget build(BuildContext context) {
    var picturesToTake = widget.controller.picturesToTake;

    var theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.add),
          label: Text("Foto Adicional"),
          backgroundColor: theme.colorScheme.secondary,
          onPressed: () {
            widget.controller.newCustomPicture();
            widget.addNewPicture(
                picturesToTake: widget.controller.picturesToTake);
            // setState(() {
            //   picturesToTake = widget.controller.picturesToTake;
            // });
          }),
      body: LazyStreamBuilder<List<PictureTaken>>(
          stream: widget.controller,
          builder: (context, snapshot) {
            var picturesTaken = snapshot.data;
            // print("picturesTaken2: " + picturesTaken.toString() + "-------");
            print("picturesToTake: " +
                widget.controller.picturesToTake.toString());

            PicturePlateBloc picturePlateBloc =
            Provider.of<PicturePlateBloc>(context);

            PictureTaken picturePlateTaken = picturePlateBloc.get();

            if (picturePlateTaken != null) {
              var pictureTaken = picturesTaken.firstOrNullWhere(
                      (pictureToTake) => pictureToTake.id == "PLATE");

              if (pictureTaken != null &&
                  pictureTaken.isRegister != null &&
                  pictureTaken.isRegister) {
                pictureTaken.fileLocation = picturePlateTaken.fileLocation;
                widget.controller.addPicture(pictureTaken);
                picturePlateBloc.remove();
              } else if (pictureTaken == null) {
                var picturePlateToTake = picturesToTake.firstOrNullWhere(
                        (pictureToTake) => pictureToTake.id == "PLATE");

                if (picturePlateToTake != null) {
                  widget.controller.addPicture(picturePlateTaken);
                  picturePlateBloc.remove();
                }
              }

            }

            // widget.controller.addPicture(picture)
            // if (widget.controller.picturesToTake.isNotEmpty) {
            return GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 16 / 12,
              padding: const EdgeInsets.all(8),
              children: [
                ...picturesToTake.map((pictureToTake) {
                  return _PictureCard(widget.controller,
                      pictureToTake: pictureToTake,
                      alreadySent: pictureToTake.sent,
                      pictureTaken: picturesTaken.firstOrNullWhere(
                            (taken) => taken.id == pictureToTake.id,
                      ));
                }),
                ...picturesTaken
                    .where((element) => element.isCustom)
                    .map((e) => _PictureCard(
                  widget.controller,
                  pictureTaken: e,
                  alreadySent: e.sent,
                  pictureToTake: Picture()..sent = true,
                )),
                SizedBox(width: 30),
              ],
            );
          }),
    );
  }
}

class _PictureCard extends StatelessWidget {
  final Picture pictureToTake;
  final PictureTaken pictureTaken;
  final PicturesController controller;
  final bool alreadySent;

  _PictureCard(
      this.controller, {
        this.pictureTaken,
        this.pictureToTake,
        this.alreadySent,
      });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final bool hasPhoto = pictureTaken?.fileLocation != null;

    final textTheme = hasPhoto
        ? Theme.of(context).primaryTextTheme
        : Theme.of(context).textTheme;

    const border = const BorderRadius.all(Radius.circular(12));

    var showMandatoryPictureHighlight = controller.mandatoryPictures &&
        !hasPhoto &&
        (pictureToTake?.required == true);

    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: border,
      ),
      color: hasPhoto ? theme.colorScheme.primary : theme.cardTheme.color,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (pictureTaken != null)
            Positioned.fill(
              child: Hero(
                tag: pictureTaken,
                child: Image.file(
                  File(pictureTaken.fileLocation.toString()),
                  fit: BoxFit.cover,
                  cacheWidth: 200,
                  alignment: Alignment.center,
                  // cacheHeight: 200,
                ),
              ),
            ),

          Positioned.fill(
            child: Material(
              shape: const RoundedRectangleBorder(borderRadius: border),
              color: Colors.transparent,
              child: InkWell(
                borderRadius: border,
                onTap: () {
                  _openPictureTakePage(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 40,
                        child: AutoSizeText(
                          pictureToTake?.name ?? 'Foto personalizada',
                          minFontSize: 10,
                          maxLines: 2,
                          style: textTheme.titleLarge.copyWith(
                            fontWeight:
                            hasPhoto ? FontWeight.bold : FontWeight.normal,
                            shadows: hasPhoto
                                ? [
                              Shadow(
                                color: Colors.black,
                                offset: const Offset(1.5, 1.5),
                              )
                            ]
                                : null,
                            color: (showMandatoryPictureHighlight)
                                ? Colors.red
                                : null,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      if (!hasPhoto)
                        AutoSizeText(
                          pictureToTake?.description ?? '',
                          maxFontSize: 12,
                          minFontSize: 8,
                          maxLines: 3,
                          style: textTheme.bodySmall.copyWith(
                            shadows: hasPhoto
                                ? [
                              Shadow(
                                color: Colors.black,
                                offset: const Offset(1, 1),
                              )
                            ]
                                : null,
                            color: (showMandatoryPictureHighlight)
                                ? Colors.red
                                : null,
                          ),
                        ),
                      if (hasPhoto &&
                          (pictureToTake?.observationRequired == true ||
                              pictureTaken?.isCustom == true) &&
                          (pictureTaken.observation?.isBlank ?? true))
                        AutoSizeText(
                          'Comentário obrigatório',
                          maxFontSize: 12,
                          minFontSize: 8,
                          maxLines: 3,
                          style: textTheme.bodySmall.copyWith(
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                offset: const Offset(1, 1),
                              )
                            ],
                            color: Colors.red,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  void _openPictureTakePage(BuildContext context) {
    PicturesToTakePageState.of(context).setPictures(
      pictureToTake: pictureToTake,
      pictureTaken: pictureTaken,
      picturesToTake: controller.picturesToTake,
      customPhoto: pictureTaken?.isCustom ?? false,
    );


  }
}
