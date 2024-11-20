import 'package:auto_size_text/auto_size_text.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:flow_flutter/utils/animation/showup.dart';
import 'package:flow_flutter/utils/request_status.dart';
import 'package:flow_flutter/utils/utils.dart';
import 'package:flow_flutter/widget/success_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rxdart/rxdart.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage();

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  var _nameTextController = TextEditingController();
  var _emailTextController = TextEditingController();
  var _passwordTextController = TextEditingController();
  var _passwordRepeatTextController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  var _requestStatus = BehaviorSubject.seeded(RequestStatus.IDLE);

  final ValueNotifier<bool> _validForm = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _requestStatus.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: const Radius.circular(20.0),
                  topRight: const Radius.circular(20.0),
                ),
                // color: theme.primaryColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: AutoSizeText(
                    "Cadastre-se",
                    minFontSize: 10,
                    maxLines: 1,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            StreamBuilder<RequestStatus>(
                stream: _requestStatus,
                builder: (context, snapshot) {
                  final requestStatus = snapshot.data;

                  if (requestStatus == RequestStatus.WAITING) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ShowUp.fifth(
                          child: SpinKitRipple(
                              size: 20,
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                        SizedBox(height: 8),
                        ShowUp.fifth(
                          delay: 100,
                          child: Text("Processando..."),
                        )
                      ],
                    );
                  }

                  if (requestStatus == RequestStatus.DONE) {
                    return SuccessWidget(
                      fullSize: false,
                      size: 80,
                      message: "Cadastro realizado com sucesso.",
                      onFinishClicked: Navigator.of(context).pop,
                    );
                  }

                  if (requestStatus == RequestStatus.ERROR) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ShowUp.fifth(
                          child: Icon(
                            Icons.error_outline,
                            size: 36,
                            color: theme.errorColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        ShowUp.fifth(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "Falha ao realizar cadastro. Por favor entre em contato com o suporte.",
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        ShowUp.fifth(
                          delay: 100,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                            ),
                            child: const Text('Tentar novamente'),
                            onPressed: () {
                              _requestStatus.add(RequestStatus.IDLE);
                            },
                          ),
                        )
                      ],
                    );
                  }

                  return _mainBody(requestStatus, theme);
                }),
            SizedBox(height: 16),
          ],
        ));
  }

  Widget _mainBody(RequestStatus requestStatus, ThemeData theme) => Column(
        mainAxisSize: MainAxisSize.min,
        key: ValueKey("mainBody"),
        children: <Widget>[
          SizedBox(height: 8),
//          ShowUp.half(
//            delay: 50,
//            child: Row(
//              mainAxisAlignment: MainAxisAlignment.center,
//              children: <Widget>[
//                Icon(Icons.vpn_key, size: 16),
//                SizedBox(width: 8),
//                Text(
//                  "Recuperação de senha",
//                  style: Theme.of(context).textTheme.caption,
//                ),
//              ],
//            ),
//          ),
//          Divider(),
          SizedBox(height: 8),
          ShowUp.half(
            delay: 50,
            child: Text(
              "Insira seu e-mail abaixo",
              textAlign: TextAlign.center,
            ),
          ),
          ShowUp.fifth(
            delay: 50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _nameTextController,
                enabled: requestStatus == RequestStatus.IDLE ||
                    requestStatus == RequestStatus.ERROR,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(),
                  labelText: "Nome",
                ),
                validator: _validarNome,
              ),
            ),
          ),
          ShowUp.fifth(
            delay: 50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _emailTextController,
                enabled: requestStatus == RequestStatus.IDLE ||
                    requestStatus == RequestStatus.ERROR,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(),
                  labelText: "E-mail",
                ),
                validator: _validarEmail,
              ),
            ),
          ),
          ShowUp.fifth(
            delay: 50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                obscureText: true,
                controller: _passwordTextController,
                enabled: requestStatus == RequestStatus.IDLE ||
                    requestStatus == RequestStatus.ERROR,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(),
                  labelText: "Senha",
                ),
                validator: _validarSenha,
              ),
            ),
          ),
          ShowUp.fifth(
            delay: 50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                obscureText: true,
                controller: _passwordRepeatTextController,
                enabled: requestStatus == RequestStatus.IDLE ||
                    requestStatus == RequestStatus.ERROR,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(),
                  labelText: "Repita a senha",
                ),
                validator: _validarSenha,
              ),
            ),
          ),
          ShowUp.fifth(
            delay: 50,
            child: ValueListenableBuilder<bool>(
              valueListenable: _validForm,
              builder: (context, value, child) {
                return MaterialButton(
                  child: Text("Cadastrar"),
                  textColor: theme.colorScheme.secondary,
                  onPressed: _sendRequest,
                );
              },
            ),
          ),
        ],
      );

  String _validarNome(String value) {
    if (value.length == 0) {
      return "Informe o nome";
    } else {
      return null;
    }
  }

  String _validarEmail(String value) {
    if (value.length == 0) {
      return "Informe o Email";
    } else if (!RegExp(EMAIL_REGEX)
        .hasMatch(_getEmailWithoutEnvironmentString())) {
      return "Email inválido";
    } else {
      return null;
    }
  }

  String _validarSenha(String value) {
    if (value.length == 0) {
      return "Informe a senha";
    } else {
      return null;
    }
  }

  String _getEmailWithoutEnvironmentString() => _emailTextController.text
      .trim()
      .replaceAll(" ", "")
      .replaceAll("&&&", "")
      .replaceAll("***", "");

  void _sendRequest() async {
    if (_formKey.currentState.validate()) {
      _requestStatus.add(RequestStatus.WAITING);

      var requestsRepo = context.provide<RequestsRepository>();

      var emailText = _emailTextController.text.trim().replaceAll(" ", "");

      if (emailText.endsWith("&&&")) {
        requestsRepo.setEnvironment("&&&");
      } else if (emailText.endsWith("***")) {
        requestsRepo.setEnvironment("***");
      } else if (emailText.endsWith("###")) {
        requestsRepo.setEnvironment("###");
      } else {
        requestsRepo.setEnvironment(null);
      }

      if (await requestsRepo.signUp(
          _nameTextController.text,
          _getEmailWithoutEnvironmentString(),
          _passwordTextController.text,
          _passwordRepeatTextController.text)) {
        _requestStatus.add(RequestStatus.DONE);
      } else {
        _requestStatus.add(RequestStatus.ERROR);
      }

      requestsRepo.setEnvironment("&&&");
    }
  }
}
