import 'dart:io';
import 'package:flow_flutter/controller/V2Controllers/test_controller.dart';
import 'package:flow_flutter/models/company_config.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:path_provider/path_provider.dart';
import 'video_data.dart';
import 'vlc_player_with_controls.dart';

class SingleTab extends StatefulWidget {
  final ListCams cams;
  final TestController controller;
  final int index;
  final String serial;

  const SingleTab(
      {@required this.cams,
      @required this.controller,
      @required this.index,
      @required this.serial});

  @override
  _SingleTabState createState() => _SingleTabState();
}

class _SingleTabState extends State<SingleTab> {
  VlcPlayerController _controller;
  final _key = GlobalKey<VlcPlayerWithControlsState>();

  bool waiting = false;

  //
  List<VideoData> listVideos;
  int selectedVideoIndex;
  ListCams listCams;

  Future<File> _loadVideoToFs() async {
    final videoData = await rootBundle.load('assets/sample.mp4');
    final videoBytes = Uint8List.view(videoData.buffer);
    var dir = (await getTemporaryDirectory()).path;
    var temp = File('$dir/temp.file');
    temp.writeAsBytesSync(videoBytes);

    return temp;
  }

  Future<String> _loadCamLocalIds(int localId, int cameraId) async {
    //Posteriormente clicar no play, executar a chamada abaixo
    var wowzaStreamUrl = await widget.controller.getWowzaStreamUrl(
      localId,
      cameraId,
    );
    //ajustar essa volta

    return wowzaStreamUrl;
  }

  Future<void> _fillVideos() async {
    listVideos = <VideoData>[];

    listVideos = widget.cams.listCams.map((e) {
      return VideoData(
          name: e.name,
          path: e.path,
          type: VideoType.network,
          cameraId: e.id,
          localId: e.locId);
    }).toList();

    printDebug(listVideos.length);
  }

  @override
  void initState() {
    super.initState();

    _fillVideos();
    var initVideo = listVideos[0];

    switch (initVideo.type) {
      case VideoType.network:
        _controller = VlcPlayerController.network(
          initVideo.path,
          hwAcc: HwAcc.FULL,
          options: VlcPlayerOptions(
            advanced: VlcAdvancedOptions([
              VlcAdvancedOptions.networkCaching(2000),
            ]),
            subtitle: VlcSubtitleOptions([
              VlcSubtitleOptions.boldStyle(true),
              VlcSubtitleOptions.fontSize(30),
              VlcSubtitleOptions.outlineColor(VlcSubtitleColor.yellow),
              VlcSubtitleOptions.outlineThickness(VlcSubtitleThickness.normal),
              // works only on externally added subtitles
              VlcSubtitleOptions.color(VlcSubtitleColor.navy),
            ]),
            http: VlcHttpOptions([
              VlcHttpOptions.httpReconnect(true),
            ]),
            rtp: VlcRtpOptions([
              VlcRtpOptions.rtpOverRtsp(true),
            ]),
          ),
        );
        break;
      case VideoType.file:
        var file = File(initVideo.path);
        _controller = VlcPlayerController.file(
          file,
        );
        break;
      case VideoType.asset:
        _controller = VlcPlayerController.asset(
          initVideo.path,
          options: VlcPlayerOptions(),
        );
        break;
      case VideoType.recorded:
        break;
    }
    _controller.addOnInitListener(() async {
      await _controller.startRendererScanning();
    });
    _controller.addOnRendererEventListener((type, id, name) {
      print('OnRendererEventListener $type $id $name');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (selectedVideoIndex == null) {
      selectedVideoIndex = 0;
    }

    return ListView(
      children: [
        Container(
          height: 215,
          child: VlcPlayerWithControls(
            key: _key,
            controller: _controller,
            onStopRecording: (recordPath) {
              setState(() {
                listVideos.add(VideoData(
                  name: 'Recorded Video',
                  path: recordPath,
                  type: VideoType.recorded,
                ));
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'The recorded video file has been added to the end of list.'),
                ),
              );
            },
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: listVideos.length,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            var video = listVideos[index];
            IconData iconData;
            switch (video.type) {
              case VideoType.network:
                iconData = Icons.cloud;
                break;
              case VideoType.file:
                iconData = Icons.insert_drive_file;
                break;
              case VideoType.asset:
                iconData = Icons.all_inbox;
                break;
              case VideoType.recorded:
                iconData = Icons.videocam;
                break;
            }
            return ListTile(
              dense: true,
              selected: selectedVideoIndex == index,
              selectedTileColor: Colors.black54,
              leading: Icon(
                iconData,
                color:
                    selectedVideoIndex == index ? Colors.white : Colors.black,
              ),
              title: Text(
                widget.cams.listCams[index].hardwareFeatureDescription != null
                    ? widget.cams.listCams[index].hardwareFeatureDescription
                    : "Câmera ${index + 1}",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color:
                      selectedVideoIndex == index ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Text(
                widget.cams.listCams[index].peripheralName != null
                    ? widget.cams.listCams[index].peripheralName
                    : "Posição da Câmera ${index + 1}",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color:
                      selectedVideoIndex == index ? Colors.white : Colors.black,
                ),
              ),
              onTap: () async {
                await _controller.stopRecording();
                switch (video.type) {
                  case VideoType.network:
                    //carregar video Wowza
                    var url =
                        await _loadCamLocalIds(video.localId, video.cameraId);
                    await _controller.setMediaFromNetwork(
                      url,
                      autoPlay: true,
                      hwAcc: HwAcc.AUTO,
                    );
                    break;
                  case VideoType.file:
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copying file to temporary storage...'),
                      ),
                    );
                    await Future.delayed(Duration(seconds: 1));
                    var tempVideo = await _loadVideoToFs();
                    await Future.delayed(Duration(seconds: 1));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Now trying to play...'),
                      ),
                    );
                    await Future.delayed(Duration(seconds: 1));
                    if (await tempVideo.exists()) {
                      await _controller.setMediaFromFile(tempVideo);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('File load error.'),
                        ),
                      );
                    }
                    break;
                  case VideoType.asset:
                    await _controller.setMediaFromAsset(video.path);
                    break;
                  case VideoType.recorded:
                    var recordedFile = File(video.path);
                    await _controller.setMediaFromFile(recordedFile);
                    break;
                }
                setState(() {
                  selectedVideoIndex = index;
                });

                bool playing = await _controller.isPlaying();
                bool error = _controller.value.hasError;
                int count = 1;
                while (error && !playing && count < 5) {
                  await Future.delayed(Duration(seconds: 5));

                  _controller.play();
                  count++;

                  printDebug("esta tocando = " + playing.toString());
                  printDebug("tem erro = " + error.toString());
                }
              },
            );
          },
        ),
        Row(
            mainAxisAlignment:
                MainAxisAlignment.center, //Center Column contents vertically,
            crossAxisAlignment: CrossAxisAlignment
                .center, //Center Column contents horizontally,
            children: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Fechar")),
              !waiting
                  ? TextButton(
                      onPressed: () => this.adjustedDVRAction(),
                      child: Text("Ajustado"))
                  : SpinKitWave(
                      color: Theme.of(context).colorScheme.secondary,
                      size: 30,
                    )
            ])
      ],
    );
  }

  void adjustedDVRAction() async {
    setState(() {
      waiting = true;
    });

    String urlList = "";
    int technicalVisitId = widget.controller.installationCloudId;
    String serial = widget.serial;
    ListCams cams = widget.cams;

    try {
      ListCams listCams = await widget.controller.requestsRepository
          .getUrlPathEvidenceDVR(technicalVisitId, serial, cams);

      if (listCams != null) {
        for (var i = 0; i < listCams.listCams.length; i++) {
          if (listCams.listCams[i].path.isNotEmpty) {
            String result = await widget.controller.saveDVREvidenceImages(
                widget.index, listCams.listCams[i], widget.serial);

            if (urlList.isEmpty)
              urlList = result;
            else
              urlList = "$urlList; $result";
          } else {
            // ???????????? e se não vier resultado
          }
        }

        widget.controller.updateSucessTestAndEvidence(
            widget.index, urlList, technicalVisitId);
      }
    } catch (e) {
      printDebug('Exceção ao buscar evidências: $e');
    } finally {
      setState(() {
        waiting = false;
      });
    }

    Navigator.pop(context);
  }

  @override
  void dispose() async {
    super.dispose();
    await _controller.stopRendererScanning();
    await _controller.dispose();
  }
}
