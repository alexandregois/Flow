import 'dart:async';

import 'package:rxdart/rxdart.dart';

mixin BasicController<T> on Stream<T> {
  final _subject = BehaviorSubject<T>();

  Stream<T> get stream => _subject;

  void add(T object) {
    // print("add: " + object.toString());
    if (!_subject.isClosed) _subject.add(object);
  }

  void addError(dynamic error) {
    if (!_subject.isClosed) {
      _subject.addError(error);
    }
  }

  T get() => _subject.value;

  void dispose() {
    _subject.close();
  }

  bool get isClosed => _subject.isClosed;

  @override
  StreamSubscription<T> listen(void Function(T event) onData,
          {Function onError, void Function() onDone, bool cancelOnError}) =>
      _subject.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
}
