import 'package:conduit/conduit.dart';
import 'package:taskapi/model/user.dart';

class Group extends ManagedObject<_Group> implements _Group {}


class _Group{
  @primaryKey
  int? id;
  @Column(unique: true, indexed: true)
  String? nameGroup;

  @Column(unique: false, indexed: true)
  int? adminid;

  ManagedSet<User>? userList;
}