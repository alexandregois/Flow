import 'dart:convert';
import 'dart:io';
import 'package:flow_flutter/pages/forgot_password_page.dart';
import 'package:flow_flutter/pages/signup_page.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/services/get_all_info_service.dart';
import 'package:flow_flutter/utils/animation/showup.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
//import 'package:package_info/package_info.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:http/http.dart' as http;
import 'package:version/version.dart';
import 'package:pub_semver/pub_semver.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();
  var _floatingVisibilityStream = BehaviorSubject<String>();

  var _performingLogin = false;

  var _scaffold = GlobalKey<ScaffoldState>();

  var _packageInfoFuture = PackageInfo.fromPlatform();

  bool hidePassword = true;

  @override
  void initState() {
    super.initState();

    getDeviceId();

    verificarVersaoApp(context);

    //sendErrorEmail("TESTE ALEXANDRE OLIVEIRA - MAXTRACK");

    _emailController.addListener(() {
      _floatingVisibilityStream.add(_emailController.text);
    });

    _passwordController.addListener(() {
      _floatingVisibilityStream.add(_passwordController.text);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _floatingVisibilityStream.close();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var originalTheme = Theme.of(context);
    var darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: originalTheme.primaryColor,
      primaryColorDark: originalTheme.primaryColorDark,
      accentColor: originalTheme.accentColor,
      scaffoldBackgroundColor: originalTheme.primaryColor,
      textTheme: originalTheme.primaryTextTheme,
      primaryTextTheme: originalTheme.textTheme,
    );

    return Theme(
      data: darkTheme,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: <Color>[Colors.blue[600], Colors.blue[900]]),
        ),
        child: Scaffold(
          key: _scaffold,
          backgroundColor: Colors.transparent,
          floatingActionButton: ShowUp.fifth(
            delay: 100,
            child: _buildFloatingActionButton(),
          ),
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return StreamBuilder(
      stream: _floatingVisibilityStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final enabled = _emailController.text.isNotEmpty &&
            _passwordController.text.isNotEmpty;

        return FloatingActionButton.extended(
          onPressed: (_performingLogin || !enabled) ? null : _performLogin,
          backgroundColor: enabled ? null : Theme.of(context).primaryColorDark,
          tooltip: "Entrar",
          label: _performingLogin
              ? SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: SpinKitWave(
                    color: Colors.white,
                    size: 15.0,
                  ),
                )
              : Text("Entrar"),
          icon: _performingLogin ? Container() : Icon(Icons.arrow_forward),
        );
      },
    );
  }

  Widget _buildBody() {
    var themeData = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ShowUp(
              delay: 50,
              offset: 0.05,
              child: ListView(
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                children: [
                  Container(
                      child: Align(
                          alignment: Alignment.topRight,
                          child: _getLoginField(themeData))),
                  Padding(
                    padding: const EdgeInsets.only(top: 0.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(child: Container()),
                        Image.asset('assets/image/Logo_Flow-03.png',
                            width: 150, height: 150),
                        // SizedBox(width: 16.0),
                        Expanded(child: Container()),
                      ],
                    ),
                  ),
                  SizedBox(height: 5.0),
                  TextFormField(
                    enabled: !_performingLogin,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.mail_outline),
                      labelText: "Email",
                      labelStyle: TextStyle(color: Colors.white),
                      // border: OutlineInputBorder(),
                      // focusedBorder: OutlineInputBorder(
                      //   borderSide:
                      //       const BorderSide(color: Colors.white, width: 2.0),
                      // ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    enabled: !_performingLogin,
                    controller: _passwordController,
                    obscureText: hidePassword,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.security),
                      suffixIcon: IconButton(
                        icon: hidePassword
                            ? Icon(Icons.remove_red_eye)
                            : Icon(Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                      ),
                      labelStyle: TextStyle(color: Colors.white),
                      labelText: "Senha",
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 50.0,
                              child: Center(
                                child: Text(
                                  "Esqueci minha senha",
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            _forgotPassword();
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 60,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/image/logo_maxtrack.png',
                          width: 150, height: 150)
                    ],
                  ),
                  SizedBox(
                    height: 80.0,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 8,
            child: Platform.isIOS
                ? Material(
                    color: Colors.transparent,
                    child: InkWell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 50.0,
                          child: Center(
                            child: Text("Cadastre-se"),
                          ),
                        ),
                      ),
                      onTap: _onSignUpClicked,
                    ),
                  )
                : SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _getLoginField(ThemeData themeData) {
    Widget loginText = FutureBuilder<PackageInfo>(
        future: _packageInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return Text(
              "v${snapshot.data.version}",
              style: Theme.of(context).textTheme.bodySmall,
            );
          else {
            return Container();
          }
        });

    if (isDebug()) {
      loginText = GestureDetector(
        onTap: () {
          _emailController.text = "danieloliveira@denox.com.br&&&";
          _passwordController.text = "a123456";
          _performLogin();
        },
        child: loginText,
      );
    }

    return loginText;
  }

  bool isVersionGreater(String a, String b) { //a - instalada / b - loja

    String strInstalada = a.replaceAll('.', '');
    String strLoja = b.replaceAll('.', '');

    if (strLoja.length == 3) {
      strLoja = strLoja + "0";
    }

    int numInstalada = int.parse(strInstalada);
    int numLoja = int.parse(strLoja);

    if (numLoja > numInstalada ) {
      return true;
    }

  }

  String verificaStringVersao(String text) {
    // Verifica se a string contém "2.0."
    if (text.contains("2.0.")) {
      // Encontra o índice onde "2.0." começa
      int startIndex = text.indexOf("2.0.");

      int endIndex;

      // Verifica a plataforma e ajusta o índice de término conforme necessário
      if (Platform.isAndroid) {
        // Para Android, procura pela primeira ocorrência de aspas duplas após "2.0."
        endIndex = text.indexOf("\"", startIndex + "2.0.".length);
      } else if (Platform.isIOS) {
        // Para iOS, procura pela primeira ocorrência de "\>" após "2.0."
        endIndex = text.indexOf("\<", startIndex + "2.0.".length);
      } else {
        // Caso não seja nem Android nem iOS, ou como fallback
        endIndex = text.length;
      }

      // Se não encontrar o caractere esperado, use o comprimento total da string como endIndex
      if (endIndex == -1) {
        endIndex = text.length;
      }

      // Extrai a substring que começa com "2.0." e vai até o caractere de término especificado ou o fim da string
      String extracted = text.substring(startIndex, endIndex);

      return extracted;

    } else {
      return "";
    }
  }

  void verificarVersaoApp(BuildContext context) async {

    // Obter informações do pacote
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    // Identificar a plataforma
    String platform = Platform.isAndroid ? "android" : "ios";

    // Definir a URL da API para verificar a versão na loja
    String urlLoja = Platform.isAndroid ? 'https://play.google.com/store/apps/details?id=com.denox.flow' :
    'https://apps.apple.com/br/app/maxtrack-flow/id1559033669';

    try {
      var response = await http.get(Uri.parse(urlLoja));
      if (response.statusCode == 200) {
        String responseBody = response.body;

        if(currentVersion.contains(".dev")) {
          currentVersion = currentVersion.replaceAll(".dev", "");
        }

        String versao = verificaStringVersao(responseBody);

        if (versao != "") {
          print('Versão encontrada na loja: $versao');
          if (isVersionGreater(currentVersion, versao)) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Atualização disponível'),
                  content: Text('Existe uma nova versão do aplicativo disponível. Por favor, atualize para continuar.'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Fechar'),
                      onPressed: () {
                        // Encerrar o aplicativo
                        Navigator.of(context).pop();
                        exit(0); // Usar exit(0) para fechar o aplicativo
                      },
                    ),
                  ],
                );
              },
            );
          } else {
            print('A versão atual está de acordo com a loja.');
          }
        } else
          {
            print('Versão não encontrada na loja.');
          }

      } else {
        print('Falha ao buscar versão na loja.');
      }
    } catch (e) {
      print('Erro ao verificar versão: $e');
    }
  }

  void showDialogAtualizacao(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Atualização Disponível'),
          content: Text('Existe uma nova versão do aplicativo disponível. Por favor, atualize para continuar.'),
          actions: <Widget>[
            TextButton(
              child: Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
                SystemNavigator.pop(); // Fecha a aplicação
              },
            ),
          ],
        );
      },
    );
  }


  void _performLogin() async {
    var appData = Provider.of<AppDataRepository>(context, listen: false);
    var requestsRepository =
        Provider.of<RequestsRepository>(context, listen: false);
    var emailText = _emailController.text.replaceAll(" ", "");
    var passwordText = _passwordController.text.trim();

    if (emailText.isEmpty || passwordText.isEmpty) {
      return;
    }

    if (emailText.endsWith("&&&")) {
      appData.setEnvironment("&&&");
      requestsRepository.setEnvironment("&&&");
      emailText = emailText.replaceAll("&&&", "").trim();
    } else if (emailText.endsWith("***")) {
      appData.setEnvironment("***");
      requestsRepository.setEnvironment("***");
      emailText = emailText.replaceAll("***", "").trim();
    } else if (emailText.endsWith("###")) {
      appData.setEnvironment("###");
      requestsRepository.setEnvironment("###");
      emailText = emailText.replaceAll("###", "").trim();
    } else if (emailText.endsWith("%%%")) {
      appData.setEnvironment("%%%");
      requestsRepository.setEnvironment("%%%");
      emailText = emailText.replaceAll("%%%", "").trim();
    } else if (emailText.endsWith("!!!")) {
      appData.setEnvironment("!!!");
      requestsRepository.setEnvironment("!!!");
      emailText = emailText.replaceAll("!!!", "").trim();
    } else {
      appData.setEnvironment(null);
      requestsRepository.setEnvironment(null);
    }

    setState(() {
      _performingLogin = true;
    });

    var errorMessage = "Não foi possível realizar o login";

    try {
      var response =
          await requestsRepository.performLogin(emailText, passwordText);

      if (response.statusCode == 200) {
        errorMessage = null;
      } else {
        var decode = json.decode(response.body);
        var error = decode["error_description"] != null
            ? decode["error_description"]
            : decode["message"];

        switch (error) {
          case "user.password.invalid":
            errorMessage = "Usuário ou senha inválidos.";
            break;
          case "flow.version.invalid":
            errorMessage = "Versão desatualizada!\n\nAtualize seu app.";
            break;
          case "flow.person.not.technical":
            errorMessage = "Usuário não encontrado.";
            break;
        }
      }
    } catch (e) {
      print(e);

      switch (e.runtimeType) {
        case SocketException:
          errorMessage = "Por favor, verifique sua conexão com a internet.";
          break;
      }
    }

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 5),
        content: Padding(
          padding: const EdgeInsets.all(35),
          child: Text(errorMessage,
              style: TextStyle(color: Colors.white, fontSize: 20)),
        ),
        backgroundColor: Colors.red,
      ));
    }

    setState(() {
      _performingLogin = false;
    });
  }

  Future<String> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId;

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;  // Unique ID on Android
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor;  // Unique ID on iOS
    } else {
      throw Exception('Plataforma não suportada');
    }

    return deviceId;
  }

  void _forgotPassword() {
    showDialog(
      context: context,
      builder: (context) {
        return ShowUp(
          offset: 0.1,
          child: Dialog(
            clipBehavior: Clip.antiAlias,
            shape: const RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(const Radius.circular(20.0)),
            ),
            // backgroundColor: Theme.of(context).primaryColorDark,
            child: ForgotPasswordPage(email: _emailController.text),
          ),
        );
      },
    );
  }

  void _onSignUpClicked() {
    showDialog(
      context: context,
      builder: (context) {
        return ShowUp(
          offset: 0.1,
          child: Dialog(
            clipBehavior: Clip.antiAlias,
            shape: const RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(const Radius.circular(20.0)),
            ),
            // backgroundColor: Theme.of(context).primaryColorDark,
            child: SignUpPage(),
          ),
        );
      },
    );
  }
}

class LoginBackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
//    return Path()..lineTo(size.width, size.height/3)..lineTo(size.width, 0.0);
    return Path()
      ..addOval(Rect.fromCircle(
          center: Offset(size.width * 1.2, -size.width / 5),
          radius: size.width * 1.2));
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => true;
}
