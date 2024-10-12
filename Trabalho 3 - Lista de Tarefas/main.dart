import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(const MeuApp());

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tarefas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
      ),
      home: const PaginaInicial(titulo: 'Minha Lista de Tarefas'),
    );
  }
}

class PaginaInicial extends StatefulWidget {
  final String titulo;

  const PaginaInicial({
    super.key,
    required this.titulo,
  });

  @override
  State<PaginaInicial> createState() => _PaginaInicialState();
}

class _PaginaInicialState extends State<PaginaInicial> {
  final List<String> listaTarefas = [];
  final TextEditingController controladorTexto = TextEditingController();
  final List<bool> tarefasConcluidas = [];
  final List<bool> marcadasParaExclusao = [];
  Timer? temporizadorExclusao;
  var indiceConcluidas = 0;

  String? ultimaTarefaExcluida;
  int? indiceUltimaExcluida;
  bool? tarefaExcluidaConcluida;

  void exibirMensagemTarefaInvalida() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tarefa inválida!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void adicionarTarefa(String novaTarefa) {
    setState(() {
      String tarefaLimpa = novaTarefa.trim();

      if (tarefaLimpa.isEmpty || listaTarefas.contains(tarefaLimpa)) {
        exibirMensagemTarefaInvalida();
        controladorTexto.clear();
        return;
      }

      listaTarefas.insert(indiceConcluidas, tarefaLimpa);
      tarefasConcluidas.insert(indiceConcluidas, false);
      marcadasParaExclusao.insert(indiceConcluidas, false);
      indiceConcluidas++;
      controladorTexto.clear();
    });
  }

  void alternarConclusao(int indice) {
    setState(() {
      tarefasConcluidas[indice] = !tarefasConcluidas[indice];
      listaTarefas.insert(indiceConcluidas, listaTarefas[indice]);
      tarefasConcluidas.insert(indiceConcluidas, tarefasConcluidas[indice]);
      marcadasParaExclusao.insert(indiceConcluidas, false);

      if (tarefasConcluidas[indice]) {
        listaTarefas.removeAt(indice);
        tarefasConcluidas.removeAt(indice);
        marcadasParaExclusao.removeAt(indice);
        indiceConcluidas--;
      } else {
        listaTarefas.removeAt(indice + 1);
        tarefasConcluidas.removeAt(indice + 1);
        marcadasParaExclusao.removeAt(indice + 1);
        indiceConcluidas++;
      }
    });
  }

  void iniciarCooldownExclusao(int indice) {
    setState(() {
      marcadasParaExclusao[indice] = true;
      temporizadorExclusao = Timer(const Duration(seconds: 3), () {
        excluirTarefa(indice);
      });
    });
  }

  void excluirTarefa(int indice) {
    setState(() {
      ultimaTarefaExcluida = listaTarefas[indice];
      indiceUltimaExcluida = indice;
      tarefaExcluidaConcluida = tarefasConcluidas[indice];

      listaTarefas.removeAt(indice);
      tarefasConcluidas.removeAt(indice);
      marcadasParaExclusao.removeAt(indice);

      if (indice < indiceConcluidas) {
        indiceConcluidas--;
      }

      temporizadorExclusao = null;
    });
  }

  void desfazerCooldown(int indice) {
    setState(() {
      temporizadorExclusao?.cancel();
      marcadasParaExclusao[indice] = false;
    });
  }

  void desfazerExclusao() {
    setState(() {
      if (ultimaTarefaExcluida != null && indiceUltimaExcluida != null) {
        listaTarefas.insert(indiceUltimaExcluida!, ultimaTarefaExcluida!);
        tarefasConcluidas.insert(indiceUltimaExcluida!, tarefaExcluidaConcluida!);
        marcadasParaExclusao.insert(indiceUltimaExcluida!, false);

        if (!tarefaExcluidaConcluida!) {
          indiceConcluidas++;
        }

        ultimaTarefaExcluida = null;
        indiceUltimaExcluida = null;
      }
    });
  }

  @override
  void dispose() {
    controladorTexto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        title: Text(widget.titulo),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TextField(
            controller: controladorTexto,
            autofocus: true,
            onSubmitted: adicionarTarefa,
          ),
          FloatingActionButton(
            onPressed: () => adicionarTarefa(controladorTexto.text),
            tooltip: 'Adicionar tarefa',
            child: const Icon(Icons.add),
          ),
          Expanded(
            child: ListView.builder(
              key: const Key('lista_reordenavel'),
              itemCount: listaTarefas.length,
              itemBuilder: (context, indice) {
                final tarefa = listaTarefas[indice];

                Color corTile = tarefasConcluidas[indice]
                    ? Colors.green
                    : (indice % 2 == 0
                        ? Colors.lightBlue.shade100
                        : Colors.lightBlue.shade300);

                return Dismissible(
                  key: ValueKey(tarefa),
                  background: Container(
                    color: Colors.green,
                    child: const Icon(Icons.check, color: Colors.white),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      iniciarCooldownExclusao(indice);
                      return false;
                    } else if (direction == DismissDirection.startToEnd) {
                      alternarConclusao(indice);
                      return false;
                    }
                    return false;
                  },
                  child: Container(
                    color: corTile,
                    child: ListTile(
                      leading: Checkbox(
                        value: tarefasConcluidas[indice],
                        onChanged: (value) => alternarConclusao(indice),
                      ),
                      title: Text(
                        tarefa,
                        style: TextStyle(
                          color: marcadasParaExclusao[indice]
                              ? Colors.red
                              : Colors.black,
                          decoration: tarefasConcluidas[indice]
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!marcadasParaExclusao[indice])
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => iniciarCooldownExclusao(indice),
                            ),
                          if (marcadasParaExclusao[indice])
                            IconButton(
                              icon: const Icon(Icons.undo),
                              onPressed: () => desfazerCooldown(indice),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
