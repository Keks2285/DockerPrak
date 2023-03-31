import 'package:conduit/conduit.dart';
import 'package:taskapi/model/group.dart';
import 'package:taskapi/model/task.dart';
import 'package:taskapi/model/user.dart';

class User_Group extends ManagedObject<_User_Group> implements _User_Group {}

class _User_Group{
  @primaryKey
  int? id;

  @Relate(#userList, isRequired: true, onDelete: DeleteRule.cascade)
  Group? group;
  @Relate(#groupList, isRequired: true, onDelete: DeleteRule.cascade)
  User? user;
}