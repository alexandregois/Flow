import 'package:flow_flutter/utils/animation/showup.dart';
import 'package:flutter/material.dart';

class SuccessWidget extends StatelessWidget {
  final bool fullSize;
  final String title;
  final String message;
  final double size;
  final VoidCallback onFinishClicked;

  const SuccessWidget({
    Key key,
    this.title = "Pronto!",
    this.message = "UMA MENSAGEM DE SUCESSO",
    @required this.onFinishClicked,
    this.fullSize = true,
    this.size = 120,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ShowUp.fifth(
            child: Icon(
              Icons.check_circle,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 16),
          ShowUp.half(
            delay: 100,
            child: Text(
              this.title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          ShowUp.fifth(
            delay: 200,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                this.message,
//                style: theme.textTheme.caption,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 8),
          ShowUp.fifth(
            delay: 300,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
              ),
              child: Text("Ok, entendi."),
              onPressed: onFinishClicked,
            ),
          ),
          SizedBox(
              height:
                  this.fullSize ? MediaQuery.of(context).size.height * .25 : 0),
        ],
      ),
    );
  }
}
