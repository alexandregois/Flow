import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flow_flutter/models/company_config.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/repository/impl/http_requests.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/widget/flow_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:provider/provider.dart';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

const flowUtil = true; //shortcut for extensions import

const EMAIL_REGEX =
    "^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*\$";

const appBarBottomShape = const RoundedRectangleBorder(
  borderRadius: BorderRadius.only(
    bottomLeft: Radius.circular(16),
    bottomRight: Radius.circular(16),
  ),
);

Widget gradientAppBar({Color color1, Color color2}) {
  color1 ??= Colors.blue[600];
  color2 ??= Colors.blue[900];
  return Container(
    decoration: BoxDecoration(
      borderRadius: appBarBottomShape.borderRadius,
      gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[color1, color2]),
    ),
  );
}

String removeDiacritics(String str) {
  var withDia =
      'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
  var withoutDia =
      'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';

  for (int i = 0; i < withDia.length; i++) {
    str = str.replaceAll(withDia[i], withoutDia[i]);
  }

  return str;
}

Future<CompanyConfig> performCompanyConfig(BuildContext context) async {
  return context
      .provide<RequestsRepository>()
      .getCompanyConfig()
      .then((listing) async {
    if (listing != null) {
      await context
          .provide<CompanyConfigRepository>()
          .putCompanyConfig(listing);
      return listing;
    } else {
      return null;
    }
  });
}

// List<CameraDescription> kCameras;

const _platformChannel = MethodChannel("utils");

void sendTokenToPlatform(String accessToken) {
  final isTestEnvironment =
      DenoxRequests.urlBase.contains("my-test.denox.com.br");

  try {
    _platformChannel.invokeMethod("login", [accessToken, isTestEnvironment]);
  } catch (e) {
    print(e);
  }
}

void performLogout({
  @required AppDataRepository appData,
  @required DevicesRepository devicesRepo,
  @required ChecklistRepository checklistRepo,
  @required VehiclesRepository vehiclesRepo,
  @required PictureToTakeRepository picturesRepo,
}) {
  appData?.setAccessToken(null);
  appData?.setRefreshToken(null);
  appData?.setEnvironment(null);

  devicesRepo?.deleteBrands();
  devicesRepo?.deleteModels();
  devicesRepo?.deleteGroups();
  devicesRepo?.setLastDateRequest(null);
  devicesRepo?.setLastVersionRequest(null);

  checklistRepo?.deleteChecklistItems();
  checklistRepo?.setLastDateRequest(null);
  checklistRepo?.setLastVersionRequest(null);

  vehiclesRepo?.deleteModels();
  vehiclesRepo?.deleteBrands();
  vehiclesRepo?.setLastDateRequest(null);
  vehiclesRepo?.setLastVersionRequest(null);

  picturesRepo?.deletePictures();
  picturesRepo?.setLastDateRequest(null);
  picturesRepo?.setLastVersionRequest(null);

  // try {
  //   _platformChannel.invokeMethod("logout");
  // } catch (e) {
  //   print(e);
  // }
}

Future<void> sendErrorEmail(String errorMessage) async {
    String userName = 'alexandre@corebuild.com.br';
    String passWord = 'Manu@@2201';

    //final smtpServer = gmail(username, password);
    final smtpServer = SmtpServer(
      'corebuild.com.br',   // O servidor SMTP, por exemplo, 'smtp.gmail.com'
      port: 465,          // A porta do servidor, por exemplo, 465 para SSL ou 587 para TLS
      ssl: true,          // Defina como true se estiver usando SSL, caso contrário, use false
      username: userName, // O seu email de login no servidor SMTP
      password: passWord,             // A senha do seu email
    );
    final message = Message()
      ..from = Address(userName, 'Alexandre Oliveira')
      ..recipients.add('alexandreoliveira@maxtrack.com.br')
      ..subject = 'Error Report : ${DateTime.now()}'
      ..text = 'An error occurred: $errorMessage';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent. \n' + e.toString());
    }
  }


void deletePicturesFromInstallation(Installation installation) {
  if (installation == null) return;
  installation?.installationType?.installationTypes?.config?.features
      ?.forEach((element) {
    if (element?.pictureConfig != null) {
      var picturesInfo = element?.pictureConfig?.currentPicturesInfo ?? [];
      // var customPicturesInfo = installation?.picturesInfo ?? [];

      picturesInfo?.forEach((element) {
        final fileLocation = element.fileLocation?.toString();
        if (fileLocation != null) {
          File(fileLocation).delete().then((_) {
            print('Deleted picture for ${element.imageId}');
          });
        }
      });
    }

    if (element?.finishConfig != null) {
      var signatureUri = element?.finishConfig?.signatureUri?.toString();

      if (signatureUri != null) {
        File(signatureUri).delete().then((_) {
          print('Deleted picture for finish signature');
        });
      }
    }

    if (element?.checklistConfig != null) {
      var signatureUri =
          element?.checklistConfig?.currentCheckList?.signatureUri?.toString();

      if (signatureUri != null) {
        File(signatureUri).delete().then((_) {
          print('Deleted picture for checklist signature');
        });
      }
    }
  });
}

//se for uma checklist passa o id da feature, se for uma foto o id da foto.
// void deletePictureFromInstallation(Installation installation, String imageId) {
//   if (installation == null) return;
//   installation?.installationType?.installationTypes?.config?.features
//       ?.forEach((element) {
//     if (element?.pictureConfig != null) {
//       var picturesInfo = element?.pictureConfig?.currentPicturesInfo ?? [];
//       // var customPicturesInfo = installation?.picturesInfo ?? [];

//       var pictureToDelete =
//           picturesInfo?.firstWhere((element) => element.imageId == imageId);
//       if (pictureToDelete != null) {
//         final fileLocation = pictureToDelete.fileLocation?.toString();
//         if (fileLocation != null) {
//           File(fileLocation).delete().then((_) {
//             print('Deleted picture for ${pictureToDelete.imageId}');
//           });
//         }
//       }
//     }
//     if (element?.checklistConfig != null && element.id == imageId) {

//       var signatureUri =
//           element?.checklistConfig?.currentCheckList?.signatureUri?.toString();

//       if (signatureUri != null) {
//         File(signatureUri).delete().then((_) {
//           print('Deleted picture for signature');
//         });
//       }
//     }
//   });
// }

Future<List<int>> processPhoto(File file) async {
//  var rawPhoto = file.readAsBytesSync();
//  var jpg = ImageProcessing.decodeJpg(rawPhoto);
//  jpg = ImageProcessing.copyResize(jpg, 720);
//  return ImageProcessing.encodeJpg(jpg, quality: 90);

  var result = await FlutterImageCompress.compressWithFile(
    file.absolute.path,
    minWidth: 720,
    quality: 80,
  );
  return result;
}

extension MapExtension on Map {
  void printAsJsonPretty() {
    JsonEncoder.withIndent(' ').convert(this).split('\n').forEach(print);
  }
}

extension BuildContextExtensions<T> on BuildContext {
  T provide<T>() => Provider.of<T>(this, listen: false);

  FlowNavigatorState get flowNavigator => FlowNavigatorState.of(this);
}

extension IntExtensions on int {
  DateTime get toDateTime => DateTime.fromMillisecondsSinceEpoch(this);
}

Color getColor(String color) {
  return HexColor.fromHex(color);
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

const List<Shadow> kDefaultShadow = [const Shadow(offset: Offset(0.5, 0.5))];

bool chaveNfeValida(String chnfe) {
  if (chnfe.length != 44) {
    return false;
  }

  final _dv = int.tryParse(chnfe[43]);
  if (_dv == null) {
    return false;
  }

  return _dv == dvChaveNFe(chnfe.substring(0, 43));
}

int dvChaveNFe(String chnfe) {
  if (chnfe.length != 43) {
    return -1;
  }
  int _mult = 4;
  int _soma = 0;
  for (var i = 0; i < chnfe.length; i++) {
    int _digito = int.tryParse(chnfe[i]);
    if (_digito == null) {
      return -2;
    }
    _soma += _digito * _mult;
    _mult--;
    if (_mult < 2) {
      _mult = 9;
    }
  }
  final _resto = _soma % 11;
  var _dv = 11 - _resto;
  if (_dv > 9) {
    _dv = 0;
  }

  return _dv;
}

TargetPlatform currentPlatform(BuildContext context) =>
    Theme.of(context).platform;

bool isDebug() {
  bool isDebug = false;
  assert(() {
    isDebug = true;
    return true;
  }());

  return isDebug;
}

///Prints only if while on DEBUG environment.
void printDebug(Object object) {
  if (isDebug()) {
    print(object);
  }
}

int randomInt([int max]) => Random.secure().nextInt(max ?? (1 << 32));
bool randomBoolean() => Random.secure().nextBool();
double getRadian(double degree) => degree * pi / 180;
Future delay(int millis) => Future.delayed(Duration(milliseconds: millis));

void repeat(int amount, ValueChanged<int> callback) {
  for (int i = 0; i < amount; i++) {
    callback(i);
  }
}

Color hexToColor(String code) {
  if (code[0] == "#")
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  else
    return Color(int.parse(code, radix: 16) + 0xFF000000);
}

//String capitalize(String text) => text[0].toUpperCase() + text.substring(1);

Duration parseDuration(String string) {
  int hours = 0;
  int minutes = 0;
//  int micros;
  List<String> parts = string.split(':');
//  if (parts.length > 2) {
  hours = int.parse(parts[0]);
//  }
//  if (parts.length > 1) {
  minutes = int.parse(parts[1]);
//  }

//  micros = (double.parse(parts[parts.length - 1]) * 1000000).round();

  return Duration(hours: hours, minutes: minutes);
}

String printDurationAsTwoDigits(Duration duration,
    {bool includeSeconds = false}) {
  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes${includeSeconds ? twoDigitSeconds : ""}";
}

typedef Future<T> FutureGenerator<T>();
typedef bool Predicate<T>(T value);

///A retry function for Futures
Future<T> retry<T>(
    int attempts,
    FutureGenerator aFuture, {
      Predicate<T> shouldRetry,
      Duration waitBetweenRetries,
    }) async {
  try {
    var returnedValue = await aFuture();

    if (shouldRetry?.call(returnedValue) == true && attempts > 1) {
      throw Exception("Needs retry");
    } else {
      return returnedValue;
    }
  } catch (e) {
    if (attempts > 1) {
      if (waitBetweenRetries != null) {
        await Future.delayed(waitBetweenRetries);
      }
      return await retry(
        attempts - 1,
        aFuture,
        shouldRetry: shouldRetry,
        waitBetweenRetries: waitBetweenRetries,
      );
    }

    rethrow;
  }
}
