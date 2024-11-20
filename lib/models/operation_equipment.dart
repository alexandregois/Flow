enum OperationEquipmentEnum {
  MAINTAIN,
  CHANGE,
  REMOVE,
  ADD
}

extension OperationEquipmentEnumExtension on OperationEquipmentEnum {
  String get id {
    switch (this) {
      case OperationEquipmentEnum.MAINTAIN:
        return 'M';
      case OperationEquipmentEnum.CHANGE:
        return 'C';
      case OperationEquipmentEnum.REMOVE:
        return 'D';
      case OperationEquipmentEnum.ADD:
        return 'A';

      default:
        return '';
    }
  }

  String get name {
    switch (this) {
      case OperationEquipmentEnum.MAINTAIN:
        return 'Manter';
      case OperationEquipmentEnum.CHANGE:
        return 'Alterar';
      case OperationEquipmentEnum.REMOVE:
        return 'Remover';
      case OperationEquipmentEnum.ADD:
        return 'Adicionar';

      default:
        return '';
    }
  }
}

class OperationEquipmentEnumHelper {
  static OperationEquipmentEnum getByValue(String value) {
    return OperationEquipmentEnum.values
        .firstWhere((e) => e.id == value, orElse: () => null);
  }
}
