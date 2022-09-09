import 'package:mobx/mobx.dart';
import 'package:to_do/app/modules/home/models/todo_model.dart';
import 'package:to_do/app/modules/home/repositories/todo_repository_interface.dart';

part 'home_store.g.dart';

class HomeStore = HomeStoreBase with _$HomeStore;

abstract class HomeStoreBase with Store {
  final ITodoRepository repository;
  @observable
  ObservableStream<List<TodoModel>>? todoList;

  HomeStoreBase({required this.repository}) {
    getList();
  }

  @action
  getList() {
    todoList = repository.getTodos().asObservable();
  }
}
