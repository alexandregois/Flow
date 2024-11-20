enum TechnicalVisitStateEnum {
  WAITING,
  SCHEDULED,
  IN_PROGRESS,
  COMPLETED,
  CANCELED,
  CLOSE_AUTOMATIC,
  HOUR_EXCEDDED,
  UNPRODUCTIVE,
  WAITING_FOR_MANAGER_ACTION,
  CANCELED_DISPLACEMENT
}

extension TechnicalVisitStateEnumExtension on TechnicalVisitStateEnum {
  int get id {
    switch (this) {
      case TechnicalVisitStateEnum.WAITING:
        return 1;
      case TechnicalVisitStateEnum.SCHEDULED:
        return 2;
      case TechnicalVisitStateEnum.IN_PROGRESS:
        return 3;
      case TechnicalVisitStateEnum.COMPLETED:
        return 4;
      case TechnicalVisitStateEnum.CANCELED:
        return 5;
      case TechnicalVisitStateEnum.CLOSE_AUTOMATIC:
        return 6;
      case TechnicalVisitStateEnum.HOUR_EXCEDDED:
        return 7;
      case TechnicalVisitStateEnum.UNPRODUCTIVE:
        return 8;
      case TechnicalVisitStateEnum.WAITING_FOR_MANAGER_ACTION:
        return 9;
      case TechnicalVisitStateEnum.CANCELED_DISPLACEMENT:
        return 10;

      default:
        return -1;
    }
  }

  String get name {
    switch (this) {
      case TechnicalVisitStateEnum.WAITING:
        return "Aguardando";
      case TechnicalVisitStateEnum.SCHEDULED:
        return "Agendada";
      case TechnicalVisitStateEnum.IN_PROGRESS:
        return "Em Andamento";
      case TechnicalVisitStateEnum.COMPLETED:
        return "Concluído";
      case TechnicalVisitStateEnum.CANCELED:
        return "Cancelada";
      case TechnicalVisitStateEnum.CLOSE_AUTOMATIC:
        return "Fechada Automaticamente";
      case TechnicalVisitStateEnum.HOUR_EXCEDDED:
        return "Horário excedido";
      case TechnicalVisitStateEnum.UNPRODUCTIVE:
        return "Improdutiva";
      case TechnicalVisitStateEnum.WAITING_FOR_MANAGER_ACTION:
        return "Aguardando ação gestor";
      case TechnicalVisitStateEnum.CANCELED_DISPLACEMENT:
        return "Cancelada/Pagamento deslocamento";

      default:
        return "";
    }
  }
}

class TechnicalVisitStateEnumHelper {
  static TechnicalVisitStateEnum getByValue(int value) {
    return TechnicalVisitStateEnum.values
        .firstWhere((e) => e.id == value, orElse: () => null);
  }
}
