import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:to_do/app/modules/home/home_store.dart';
import 'package:to_do/app/modules/home/models/todo_model.dart';

class HomePage extends StatefulWidget {
  final String title;
  const HomePage({Key? key, this.title = "Home"}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final store = Modular.get<HomeStore>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Observer(
          builder: (_) {
            List<TodoModel>? list = store.todoList?.data;

            if (list == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (store.todoList!.hasError) {
              return Center(
                child: ElevatedButton(
                  onPressed: store.getList(),
                  child: Text('Erro'),
                ),
              );
            }

            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, index) {
                TodoModel model = list[index];
                return ListTile(
                  title: Text(
                    model.title ?? 'Remover após tratar',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200),
                  ),
                  onTap: () {
                    _showDialog(model);
                  },
                  leading: IconButton(
                      onPressed: model.remove,
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: Colors.white,
                      )),
                  trailing: Checkbox(
                    activeColor: Colors.black,
                    checkColor: Colors.white,
                    value: model.check ?? false,
                    onChanged: (bool? check) {
                      model.check = check!;
                      model.save();
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDialog,
        backgroundColor: Colors.black,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  _showDialog([TodoModel? model]) {
    model ??= TodoModel();
    final formkey = GlobalKey<FormState>();
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(model!.title == null ? 'Novo' : 'Editar'),
            content: Form(
              key: formkey,
              child: TextFormField(
                initialValue: model.title,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'campo vazio';
                  }
                  return null;
                },
                onChanged: (value) => model!.title = value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Escreva...',
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                style: ButtonStyle(
                  textStyle: MaterialStateProperty.resolveWith(
                    (states) => const TextStyle(color: Colors.black),
                  ),
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.white;
                    }
                    return Colors.black;
                  }),
                ),
                onPressed: () {
                  Modular.to.pop();
                },
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (formkey.currentState!.validate()) {
                    await model?.save();
                    Modular.to.pop();
                  }
                },
                child: Text(
                  'Salvar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        });
  }
}
