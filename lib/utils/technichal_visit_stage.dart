class TechnicalVisitStage {
  final int id;

  const TechnicalVisitStage._({
    this.id,
  });

  static const HAS_ERRORS = TechnicalVisitStage._(id: 0);
  static const IN_PROGRESS = TechnicalVisitStage._(id: 1);
  static const FINISHED = TechnicalVisitStage._(id: 2);
  // static const DATA_UPLOADED = TechnicalVisitStage._(id: 3);
  static const CLOSED = TechnicalVisitStage._(id: 4);

  static const stages = [
    HAS_ERRORS,
    IN_PROGRESS,
    FINISHED,
    // DATA_UPLOADED,
    CLOSED,
  ];

  static stageFor(int id) => stages.firstWhere((element) => element.id == id);
}
