import 'package:flow_flutter/controller/V2Controllers/pictures_controller.dart';
import 'package:flutter/widgets.dart';

class PicturePlateBloc extends ChangeNotifier {
  var picturePlateTaken;

  get() {
    return picturePlateTaken;
  }

  add(PictureTaken picturePlateTaken) {
    this.picturePlateTaken = picturePlateTaken;
    notifyListeners();
  }

  remove() {
    this.picturePlateTaken = null;
  }
}
