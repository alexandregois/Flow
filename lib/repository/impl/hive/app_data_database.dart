import 'package:flow_flutter/models/customer.dart';
import 'package:flow_flutter/models/get_all_info.dart';
import 'package:flow_flutter/models/hive/hive_models.dart';
import 'package:flow_flutter/repository/repositories.dart';
import 'package:hive/hive.dart';

class HiveAppData extends AppDataRepository {
  static const boxConfiguration = 'configuration';
  static const boxAppData = 'appData';
  static const boxCustomers = 'customers';
  static const appDataAccessToken = 'accessToken';

  @override
  Future<String> getAccessToken() => Hive.openBox<String>(boxAppData)
      .then((box) => box.get(appDataAccessToken));

  @override
  Future setAccessToken(String token) => Hive.openBox<String>(boxAppData)
      .then((box) => box.put('accessToken', token));

  @override
  Future<String> getEnvironment() =>
      Hive.openBox<String>(boxAppData).then((box) => box.get('environment'));

  @override
  Future setEnvironment(String environment) => Hive.openBox<String>(boxAppData)
      .then((box) => box.put('environment', environment));

  @override
  Future<String> getRefreshToken() =>
      Hive.openBox<String>(boxAppData).then((box) => box.get('refreshToken'));

  @override
  Future setRefreshToken(String token) => Hive.openBox<String>(boxAppData)
      .then((box) => box.put('refreshToken', token));

  @override
  Future<List<Customer>> getCustomers() =>
      Hive.openBox<HiveCustomer>(boxCustomers)
          .then((box) => box.values.map((e) => e.fromHive).toList());

  @override
  Future setCustomers(List<Customer> customers) =>
      Hive.openBox<HiveCustomer>(boxCustomers).then((box) {
        customers.forEach((customer) => box.put(customer.id, customer.toHive));
      });

  @override
  Future<Configuration> getConfiguration() =>
      Hive.openBox<HiveConfiguration>(boxConfiguration)
          .then((box) => box.get('configuration').fromHive);

  @override
  Future setConfiguration(Configuration configuration) =>
      Hive.openBox<HiveConfiguration>(boxConfiguration)
          .then((box) => box.put('configuration', configuration.toHive));
}

extension on Customer {
  HiveCustomer get toHive => HiveCustomer()
    ..id = this.id
    ..name = this.name;
}

extension on HiveCustomer {
  Customer get fromHive => Customer()
    ..id = this.id
    ..name = this.name;
}

extension on Configuration {
  HiveConfiguration get toHive => HiveConfiguration()
    ..checklistEasyCheck = this.checklistEasyCheck
    ..mandatoryPictures = this.mandatoryPictures;
}

extension on HiveConfiguration {
  Configuration get fromHive => Configuration()
    ..checklistEasyCheck = this.checklistEasyCheck
    ..mandatoryPictures = this.mandatoryPictures;
}
