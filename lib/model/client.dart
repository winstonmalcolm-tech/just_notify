import 'package:isar/isar.dart';

part 'client.g.dart';

@Collection()
class Client {
  Id id = Isar.autoIncrement;
  String? name;
  String? telephone;
}