import 'dart:async';
import 'package:conduit_core/conduit_core.dart';   

class Migration6 extends Migration { 
  @override
  Future upgrade() async {
   		database.createTable(SchemaTable("_User_Group", [SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false)]));
		database.addColumn("_User_Group", SchemaColumn.relationship("group", ManagedPropertyType.bigInteger, relatedTableName: "_Group", relatedColumnName: "id", rule: DeleteRule.cascade, isNullable: false, isUnique: false));
		database.addColumn("_User_Group", SchemaColumn.relationship("user", ManagedPropertyType.bigInteger, relatedTableName: "_User", relatedColumnName: "id", rule: DeleteRule.cascade, isNullable: false, isUnique: false));
		database.addColumn("_Group", SchemaColumn("adminid", ManagedPropertyType.integer, isPrimaryKey: false, autoincrement: false, isIndexed: true, isNullable: false, isUnique: true));
		database.deleteColumn("_Group", "admin");
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    