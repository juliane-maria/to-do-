import 'package:to_do/app/modules/home/models/todo_model.dart';

abstract class ITodoRepository {
  Stream<List<TodoModel>> getTodos();
}
