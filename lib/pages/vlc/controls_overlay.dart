import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class ControlsOverlay extends StatelessWidget {
  
  ControlsOverlay({Key key, this.controller}) : super(key: key);

  DateTime _lastPlayButtonPressTime;
  DateTime _lastReplayButtonPressTime;


  final VlcPlayerController controller;

  static const double _playButtonIconSize = 80;
  static const double _replayButtonIconSize = 100;
  static const double _seekButtonIconSize = 48;

  static const Duration _seekStepForward = Duration(seconds: 10);
  static const Duration _seekStepBackward = Duration(seconds: -10);

  static const Color _iconColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 50),
      reverseDuration: Duration(milliseconds: 200),
        child: FutureBuilder(
            future: Future.delayed(Duration(seconds: 15)), // Adicione o atraso aqui
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox.shrink(); // Retorne um widget vazio enquanto espera
              } else {
                if (controller.value.isEnded || controller.value.hasError) {
                  return Center(
                    child: FittedBox(
                      child: IconButton(
                        onPressed: _replay,
                        color: _iconColor,
                        iconSize: _replayButtonIconSize,
                        icon: Icon(Icons.replay),
                      ),
                    ),
                  );
                }
              }

              if (!controller.value.isPlaying && !controller.value.isInitialized) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

          switch (controller.value.playingState) {
            case PlayingState.initialized:
            case PlayingState.stopped:
            case PlayingState.paused:
              return SizedBox.expand(
                child: Container(
                  color: Colors.black45,
                  child: FittedBox(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () => _seekRelative(_seekStepBackward),
                          color: _iconColor,
                          iconSize: _seekButtonIconSize,
                          icon: Icon(Icons.replay_10),
                        ),
                        IconButton(
                          onPressed: _play,
                          color: _iconColor,
                          iconSize: _playButtonIconSize,
                          icon: Icon(Icons.play_arrow),
                        ),
                        IconButton(
                          onPressed: () => _seekRelative(_seekStepForward),
                          color: _iconColor,
                          iconSize: _seekButtonIconSize,
                          icon: Icon(Icons.forward_10),
                        ),
                      ],
                    ),
                  ),
                ),
              );

            case PlayingState.buffering:
            case PlayingState.playing:
              return GestureDetector(onTap: _pause);

            case PlayingState.ended:
            case PlayingState.error:
              return Center(
                child: FittedBox(
                  child: IconButton(
                    onPressed: _replay,
                    color: _iconColor,
                    iconSize: _replayButtonIconSize,
                    icon: Icon(Icons.replay),
                  ),
                ),
              );
            default:
              return SizedBox.shrink();
          }
        },
      ),
    );
  }

  // Future<void> _play() {
  //   return controller.play();
  // }


  Future<void> _play() async {
    final currentTime = DateTime.now();
    if (_lastPlayButtonPressTime == null || currentTime.difference(_lastPlayButtonPressTime) >= Duration(seconds: 3)) {
      _lastPlayButtonPressTime = currentTime;
      await controller.play();
    }
  }

  // Future<void> _replay() async {
  //   await controller.stop();
  //   await controller.play();
  // }


  Future<void> _replay() async {
    final currentTime = DateTime.now();
    if (_lastReplayButtonPressTime == null || currentTime.difference(_lastReplayButtonPressTime) >= Duration(seconds: 3)) {
      _lastReplayButtonPressTime = currentTime;
      await controller.stop();
      await controller.play();
    }
  }

  Future<void> _pause() async {
    if (controller.value.isPlaying) {
      await controller.pause();
    }
  }

  /// Returns a callback which seeks the video relative to current playing time.
  Future<void> _seekRelative(Duration seekStep) async {
    if (controller.value.duration != null) {
      await controller.seekTo(controller.value.position + seekStep);
    }
  }
}
