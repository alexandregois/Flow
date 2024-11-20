import 'package:flow_flutter/models/company_config.dart';
import 'package:flow_flutter/models/installation.dart';
import 'package:flow_flutter/utils/utils.dart';

class InstallationType {
  final int id;
  final String name;
  final bool hasVehicleInfo;
  final bool hasChecklistItems;
  final List<InstallationLocal> installationLocals;
  final InstallationTypes installationTypes;

  InstallationType transform({InstallationTypes installationTypes}) {

    printDebug('Tipo de instalação ${installationTypes.name}');

    Features featureDevice = installationTypes.config.features
        .firstWhere((feature) => feature.featureType.id == 'DEVICE' || feature.featureType.id == 'DEVICE_NEW' || feature.featureType.id == 'DEVICE_V3');

    List<InstallationLocal> locals = [];

    if (featureDevice != null &&
        featureDevice.deviceConfig != null &&
        featureDevice.deviceConfig.locals != null &&
        featureDevice.deviceConfig.locals.length > 0) {
      locals = featureDevice.deviceConfig.locals;
    } else {
      var vehicleTypeId = installationTypes.config.vehicleType?.id;
      if (vehicleTypeId == "C" || vehicleTypeId == "Carro") {
        locals = [
          InstallationLocal(id: 0, name: "Não informado"),
          InstallationLocal(id: 1, name: "Para-choque dianteiro"),
          InstallationLocal(id: 2, name: "Para-choque traseiro"),
          InstallationLocal(id: 3, name: "Farol dianteiro"),
          InstallationLocal(id: 4, name: "Lanterna traseira"),
          InstallationLocal(id: 5, name: "Cofre do motor"),
          InstallationLocal(id: 6, name: "Para-lama dianteiro"),
          InstallationLocal(id: 7, name: "Para-lama traseiro"),
          InstallationLocal(id: 8, name: "Painel de instrumentos"),
          InstallationLocal(id: 9, name: "Console central"),
          InstallationLocal(id: 10, name: "Porta-luvas"),
          InstallationLocal(id: 11, name: "Assoalho"),
          InstallationLocal(id: 12, name: "Teto"),
          InstallationLocal(id: 13, name: "Chassis"),
          InstallationLocal(id: 14, name: "Tanque de combustível"),
          InstallationLocal(id: 15, name: "Banco dianteiro"),
          InstallationLocal(id: 16, name: "Banco traseiro"),
          InstallationLocal(id: 17, name: "Bagageiro interno"),
          InstallationLocal(id: 18, name: "Porta dianteira esquerda"),
          InstallationLocal(id: 19, name: "Porta dianteira direita"),
          InstallationLocal(id: 20, name: "Porta traseira esquerda"),
          InstallationLocal(id: 21, name: "Porta traseira direita"),
          InstallationLocal(id: 22, name: "Porta-malas"),
          InstallationLocal(id: 26, name: "Caixa de fusícel central"),
          InstallationLocal(id: 27, name: "Caixa de fusível do motor"),
          InstallationLocal(id: 28, name: "Assoalho lado esquerdo"),
          InstallationLocal(id: 29, name: "Assoalho lado direito"),
          InstallationLocal(id: 30, name: "Painel corta fogo esquerdo"),
          InstallationLocal(id: 31, name: "Painel corta fogo direito"),
          InstallationLocal(id: 32, name: "Churrasqueira"),
          InstallationLocal(id: 33, name: "Duto de ar esquerdo"),
          InstallationLocal(id: 34, name: "Duto de ar lado direito"),
          InstallationLocal(id: 35, name: "Tampão do som"),
          InstallationLocal(id: 40, name: "Coluna da esquerda"),
          InstallationLocal(id: 41, name: "Coluna da direita"),
          InstallationLocal(id: 42, name: "Caixa da roda lado esquerdo"),
          InstallationLocal(id: 43, name: "Caixa da roda lado direito")
        ];
      }

      if (vehicleTypeId == "M" ||
          vehicleTypeId == "Moto" ||
          vehicleTypeId == "Motocicleta") {
        locals = [
          InstallationLocal(id: 0, name: "Não informado"),
          InstallationLocal(id: 3, name: "Farol dianteiro"),
          InstallationLocal(id: 4, name: "Lanterna traseira"),
          InstallationLocal(id: 5, name: "Cofre do motor"),
          InstallationLocal(id: 6, name: "Para-lama dianteiro"),
          InstallationLocal(id: 8, name: "Painel de instrumentos"),
          InstallationLocal(id: 14, name: "Tanque de combustível"),
          InstallationLocal(id: 15, name: "Banco dianteiro"),
          InstallationLocal(id: 16, name: "Banco traseiro"),
          InstallationLocal(id: 23, name: "Carenagem dianteira"),
          InstallationLocal(id: 24, name: "Rabeta"),
          InstallationLocal(id: 36, name: "Carenagem dianteira esquerda"),
          InstallationLocal(id: 37, name: "Carenagem dianteira direita")
        ];
      }

      if (vehicleTypeId == "T" ||
          vehicleTypeId == "Caminhão" ||
          vehicleTypeId == "Caminhao") {
        locals = [
          InstallationLocal(id: 0, name: "Não informado"),
          InstallationLocal(id: 1, name: "Para-choque dianteiro"),
          InstallationLocal(id: 2, name: "Para-choque traseiro"),
          InstallationLocal(id: 3, name: "Farol dianteiro"),
          InstallationLocal(id: 4, name: "Lanterna traseira"),
          InstallationLocal(id: 5, name: "Cofre do motor"),
          InstallationLocal(id: 6, name: "Para-lama dianteiro"),
          InstallationLocal(id: 7, name: "Para-lama traseiro"),
          InstallationLocal(id: 8, name: "Painel de instrumentos"),
          InstallationLocal(id: 9, name: "Console central"),
          InstallationLocal(id: 10, name: "Porta-luvas"),
          InstallationLocal(id: 11, name: "Assoalho"),
          InstallationLocal(id: 12, name: "Teto"),
          InstallationLocal(id: 13, name: "CHASSIS"),
          InstallationLocal(id: 14, name: "Tanque de combustível"),
          InstallationLocal(id: 15, name: "Banco dianteiro"),
          InstallationLocal(id: 16, name: "Banco traseiro"),
          InstallationLocal(id: 17, name: "Bagageiro interno"),
          InstallationLocal(id: 18, name: "Porta dianteira esquerda"),
          InstallationLocal(id: 19, name: "Porta dianteira direita"),
          InstallationLocal(id: 25, name: "Climatizador")
        ];
      }
    }

    return InstallationType(
      id: installationTypes?.id,
      name: installationTypes.name,
      hasChecklistItems: true,
      hasVehicleInfo: true,
      installationLocals: locals,
      installationTypes: installationTypes,
    );
  }

  InstallationType({
    this.id,
    this.name,
    this.hasVehicleInfo,
    this.hasChecklistItems,
    this.installationLocals,
    this.installationTypes,
  });
}
