import 'package:flutter/material.dart';

class SearchWidget extends StatefulWidget {
  final String text;
  final ValueChanged<String> onChanged;
  final String hintText;
  final Function onSearchTap;
  final Function onCameraTap;
  final Function onQrCodeTap;
  final Function onHistoryTap;
  final Function onSearchKeyboard;

  const SearchWidget({
    @required this.text,
    @required this.onChanged,
    @required this.hintText,
    @required this.onSearchTap,
    this.onCameraTap,
    this.onQrCodeTap,
    this.onHistoryTap,
    @required this.onSearchKeyboard,
    Key key,
  }) : super(key: key);

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final styleActive = TextStyle(color: Colors.black);
    final styleHint = TextStyle(color: Colors.black54);
    final style = widget.text.isEmpty ? styleHint : styleActive;

    return Container(
        height: 40,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        //padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                textInputAction: TextInputAction.search,
                controller: controller,
                decoration: InputDecoration(
                  icon: GestureDetector(
                    child: Icon(Icons.search, color: style.color),
                    onTap: widget.onSearchTap,
                  ),
                  suffixIcon: widget.text.isNotEmpty
                      ? GestureDetector(
                          child: Icon(Icons.close, color: style.color),
                          onTap: () {
                            controller.clear();
                            widget.onChanged('');
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                        )
                      : null,
                  hintText: widget.hintText,
                  hintStyle: style,
                  border: InputBorder.none,
                ),
                style: style,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSearchKeyboard,
              ),
            ),
            widget.onCameraTap != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: SizedBox(
                      width: 25,
                      child: IconButton(
                          icon: Icon(Icons.photo_camera, color: Colors.black),
                          onPressed: widget.onCameraTap),
                    ),
                  )
                : SizedBox(),
            widget.onQrCodeTap != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      width: 25,
                      child: IconButton(
                          icon: Icon(Icons.qr_code, color: Colors.black),
                          onPressed: widget.onQrCodeTap),
                    ),
                  )
                : SizedBox(),
            widget.onHistoryTap != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      width: 25,
                      child: IconButton(
                          icon: Icon(Icons.history, color: Colors.black),
                          onPressed: widget.onHistoryTap),
                    ),
                  )
                : SizedBox(),
          ],
        ));
  }
}
