import 'package:clean_architecture_cubit/common/network/api_result.dart';
import 'package:clean_architecture_cubit/features/todo/data/models/todo.dart';
import 'package:clean_architecture_cubit/features/todo/domain/entities/todo_entity.dart';

abstract class TodoRepository {
  Future<ApiResult<List<ToDo>>> getTodos(int userId, {TodoStatus? status});

  Future<ApiResult<bool>> createTodo(ToDo todo);

  Future<ApiResult<bool>> updateTodo(ToDo todo);

  Future<ApiResult<bool>> deleteTodo(ToDo todo);
}
