import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:taskapi/model/task.dart';

import '../model/user.dart';
import '../utils/app_responce.dart';
import '../utils/app_utils.dart';
import '../utils/model_responce.dart';


class AppTaskConttolelr extends ResourceController {
  AppTaskConttolelr(this.managedContext);
  final ManagedContext managedContext;



   @Operation.post() Future<Response> createTask(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.body() Task task,) async {
    try{
      final fUser = await managedContext.fetchObjectWithID<User>(AppUtils.getIdFromHeader(header));

      if(task.dateTask==null || task.description=="" || task.tag==""){
        return Response.badRequest(
          body:
              ModelResponse(message: 'Все поля должны быть заполнены'),
        );
      }
      late final int id;
      await managedContext.transaction((transaction) async {
          final qCreateTask = Query<Task>(transaction)
          ..values.dateTask = task.dateTask!.add(Duration(hours: 3)) //добавляю 3 часа
          ..values.description = task.description
          ..values.tag=task.tag
          ..values.user = fUser;

          final createdtask = await qCreateTask.insert();
          id=createdtask.id!;
      });

        final taskData = await managedContext.fetchObjectWithID<Task>(id);
       return Response.ok(
         ModelResponse(
          data:{
            "dateTask":taskData!.dateTask.toString(),
            "description":taskData.description
          } ,
          message: 'Задача успешно добавлена',
        ),
      );
       
    }on QueryException catch(e){
      return Response.serverError(

        body:  ModelResponse(message: e.message, error: "Not added")
      
      );
    }
    
  }

    @Operation.put('id') Future<Response> updateTask(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.body() Task task,
    @Bind.path("id") int taskId) async {
    try{
      final fUser = await managedContext.fetchObjectWithID<User>(AppUtils.getIdFromHeader(header));
      final taskData = await managedContext.fetchObjectWithID<Task>(taskId);
      final uId = AppUtils.getIdFromHeader(header) ;
    
      if(taskData?.id ==null){
        return Response.notFound(body: {
          "message":"запись не найдена"
        });
      }
      if(taskData?.user?.id !=uId){
        return Response.ok(
          ModelResponse(error: "У вас нет доступа к этой записи")
        );
      }
      if(task.dateTask==null || task.description=="" || task.tag==""){
        return Response.badRequest(
          body:
              ModelResponse(message: 'Все поля должны быть заполнены'),
        );
      }
      await managedContext.transaction((transaction) async {
          final qUpdateTask = Query<Task>(transaction)
          ..where((x) => x.id).equalTo(taskId)
          ..values.dateTask = task.dateTask!.add(Duration(hours: 3)) //добавляю 3 часа
          ..values.description = task.description
          ..values.tag=task.tag;
          //..values.user = fUser;

          final createdtask = await qUpdateTask.update();
      });

        //final taskData = await managedContext.fetchObjectWithID<Task>(id);
       return Response.ok(
         ModelResponse(
          data:{
            "dateTask":taskData!.dateTask.toString(),
            "description":taskData.description
          } ,
          message: 'Задача успешно обновлена',
        ),
      );
       
    }on QueryException catch(e){
      return Response.serverError(

        body:  ModelResponse(message: e.message, error: "Not added")
      
      );
    }
    
  }







   @Operation.get()
  Future<Response> getAllTasks(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
  ) async {
    try {
      // Получаем id пользователя из header
      final uId = AppUtils.getIdFromHeader(header) ;

      final qGetTasks = Query<Task>(managedContext)
      ..where((el)=>el.user!.id).equalTo(uId);

      final List<Task> list = await qGetTasks.fetch();

      if (list.isEmpty)
      {
        return Response.notFound(body: ModelResponse(data: [], message: "Нет ни одной задачи"));
      }

      return Response.ok(list);
    } catch (e) {
      return AppResponse.serverError(e);
    }
  }


     @Operation.get("id")
  Future<Response> get10onPageTasks(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path("id") int pageNum
  ) async {
    try {
      // Получаем id пользователя из header
      final uId = AppUtils.getIdFromHeader(header) ;

      final qGetTasks = Query<Task>(managedContext)
      ..where((el)=>el.user!.id).equalTo(uId)
      ..fetchLimit=10
      ..offset =(pageNum-1)*10;


      final List<Task> list = await qGetTasks.fetch();

      if (list.isEmpty)
      {
        return Response.notFound(body: ModelResponse(data: [], message: "Нет ни одной задачи"));
      }

      return Response.ok(list);
    } catch (e) {
      return AppResponse.serverError(e);
    }
  }






   @Operation.delete('id')
  Future<Response> deleteTask(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.path("id") int taskId,
    //@Bind.path("logical") int logical,
  ) async {
    try {
      final uId = AppUtils.getIdFromHeader(header) ;
      // Получаем id пользователя из header
      final taskData = await managedContext.fetchObjectWithID<Task>(taskId);
      if(taskData?.id ==null){
        return Response.notFound(body: {
          "message":"запись не найдена"
        });
      }
      if(taskData?.user?.id !=uId){
        return Response.ok(
          ModelResponse(error: "У вас нет доступа к этой записи")
        );
      }

      //  final qDeleteTask = Query<Task>(managedContext)
      // ..where((el)=>el.id).equalTo(taskId);
      // if(logical==1){
      //   qDeleteTask.values.isDeleted=true;
      //   qDeleteTask.update();
      // }else{
        final qDeleteTask = Query<Task>(managedContext)
      ..where((el)=>el.id).equalTo(taskId);
      qDeleteTask.delete();
      //}


      
     // final List<Task> list = await qGetTasks.fetch();
      
      

      return Response.ok(
        ModelResponse(data: {
          "message":"Запись удалена"
        })
      );
    } catch (e) {
      return AppResponse.serverError(e);
    }
  }



}