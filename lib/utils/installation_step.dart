import 'package:rxdart/rxdart.dart';

mixin InstallationPart<T> {
  final readyStream = BehaviorSubject.seeded(ReadyState.notReady());
  
  String name = "Passo";

  void dispose() {
    readyStream.close();
  }

  T build();
}

enum ReadyStatus { notReady, ready, warning }

class ReadyState {
  String message;
  ReadyStatus status;

  ReadyState.ready([this.message]) {
    this.status = ReadyStatus.ready;
  }

  ReadyState.notReady([this.message]) {
    this.status = ReadyStatus.notReady;
  }

  ReadyState.warning([this.message]) {
    this.status = ReadyStatus.warning;
  }

  @override
  String toString() => "ReadyState {$status} ${message != null ? message : ''}";
}
