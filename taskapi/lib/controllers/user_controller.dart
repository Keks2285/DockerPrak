import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:taskapi/model/group.dart';

import '../model/user.dart';
import '../model/user_group.dart';
import '../utils/app_responce.dart';
import '../utils/app_utils.dart';
import '../utils/model_responce.dart';

class AppUserConttolelr extends ResourceController {
  AppUserConttolelr(this.managedContext);

  final ManagedContext managedContext;

  @Operation.get()
  Future<Response> getProfile(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
  ) async {
    try {
      // Получаем id пользователя
      // Была создана новая функция ее нужно реализоваться для просмотра функции нажмите на картинку
      final id = AppUtils.getIdFromHeader(header);
      // Получаем данные пользователя по его id
      final user = await managedContext.fetchObjectWithID<User>(id);
      // Удаляем не нужные параметры для красивого вывода данных пользователя
      user!.removePropertiesFromBackingMap(['refreshToken', 'accessToken']);

      return AppResponse.ok(
          message: 'Успешное получение профиля', body: user.backing.contents);
    } catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка получения профиля');
    }
  }








  @Operation.get("id")
  Future<Response> getGroups(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.path("id") int uId,
  ) async {
    try {
      // Получаем id пользователя
      // Была создана новая функция ее нужно реализоваться для просмотра функции нажмите на картинку
      final id = AppUtils.getIdFromHeader(header);
      

      final query = Query<User>(managedContext)
      ..where((t) => t.id).equalTo(id)
      ..join(set: (t) => t.groupList).join(object: (tp) => tp.group);


      // final qGetGroupsUser= Query<Group>(managedContext)
      // ..where((el)=>el.id).equalTo(qid)
      // ..join();

      final  gropusListData  = await query.fetchOne();
      
      // if (gropusListData.groupList!.isEmpty)
      // {
      //   return Response.notFound(body: ModelResponse(data: [], message: "Нет ни одной группы"));
      // }
      // List<Group> grouplist=[];
      //   Future.forEach(list, (element) async{
      //      var qGetGroup = Query<Group>(managedContext)
      //         ..where((el)=>el.id).equalTo(element.id);
      //         var ele=await qGetGroup.fetchOne();
      //     grouplist.add(ele!);
      //   }).then((value) {
      //     return Response.ok(grouplist);
      //   });
      return Response.ok(gropusListData);
    } catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка получения данных');
    }
  }
}