import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Tarefas',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  String? _jwtToken;

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, preencha todos os campos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.https('barra.cos.ufrj.br:443', '/rest/rpc/fazer_login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _jwtToken = responseData['token'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login realizado com sucesso!')),
        );
        // Redirecionar para a tela de tarefas
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PaginaInicial(
                  titulo: "Tarefas",
                  userEmail: email,
                  jwtToken: _jwtToken!)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro de login: Verifique suas credenciais')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de rede: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Senha',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
              obscureText: _obscureText,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: Text('Login'),
                  ),
            TextButton(
              onPressed: _navigateToSignUp,
              child: Text('Não tem uma conta? Cadastre-se'),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _signUp() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final phone = _phoneController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('As senhas não coincidem')),
      );
      return;
    }

    final url =
        Uri.https('barra.cos.ufrj.br:443', '/rest/rpc/registra_usuario');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': name,
          'email': email,
          'celular': phone,
          'senha': password,
        }),
      );


      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cadastro realizado com sucesso!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de rede: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Celular'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirmar Senha'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUp,
              child: Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}



class PaginaInicial extends StatefulWidget {
  final String titulo;
  final String jwtToken;
  final String userEmail; // Armazena o email do usuário

  const PaginaInicial({
    super.key,
    required this.titulo,
    required this.jwtToken,
    required this.userEmail, // Recebe o email do usuário
  });

  @override
  State<PaginaInicial> createState() => _PaginaInicialState();
}

class _PaginaInicialState extends State<PaginaInicial> {
  List<dynamic> listaTarefas = [];
  final TextEditingController controladorTexto = TextEditingController();
  List<dynamic> tarefasConcluidas = [];
  List<bool> marcadasParaExclusao = [];
  Timer? temporizadorExclusao;
  var indiceConcluidas = 0;
  bool primeiroEnvio = true;

  String? ultimaTarefaExcluida;
  int? indiceUltimaExcluida;
  bool? tarefaExcluidaConcluida;
  
@override
  void initState() {
    super.initState();
    _carregarTarefasServidor();
  }

  Future<void> _carregarTarefasServidor() async {
    final url = Uri.https('barra.cos.ufrj.br:443', '/rest/tarefas');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.jwtToken}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        setState(() {
          listaTarefas = responseData[0]['valor']['listaTarefas'];
          tarefasConcluidas = responseData[0]['valor']['tarefasConcluidas'];
          indiceConcluidas = responseData[0]['valor']['indiceConcluidas'];
          primeiroEnvio = responseData[0]['valor']['primeiroEnvio'];
          for (int i = 0; i <= listaTarefas.length;i++){
            marcadasParaExclusao.add(false);
          }
          });
      } else {
        print('Erro ao carregar tarefas');
      }
    } catch (error) {
      print('Erro de rede ao carregar tarefas: $error');
    }
  }

  Future<void> _salvarTarefasServidor() async {
    final url = Uri.https('barra.cos.ufrj.br:443', '/rest/tarefas');
    try {
      final response = primeiroEnvio
          ? await http.post(
              url,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ${widget.jwtToken}',
              },
              body: jsonEncode({
                'email': widget.userEmail,
                'valor': {
                  'listaTarefas': listaTarefas,
                  'tarefasConcluidas': tarefasConcluidas,
                  'indiceConcluidas':indiceConcluidas,
                  'primeiroEnvio': primeiroEnvio
                }
              }), // Usa o email do usuário
            )
          : await http.patch(
              url,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ${widget.jwtToken}',
              },
              body: jsonEncode({
                'email': widget.userEmail,
                'valor': {
                  'listaTarefas': listaTarefas,
                  'tarefasConcluidas': tarefasConcluidas,
                  'indiceConcluidas':indiceConcluidas,
                  'primeiroEnvio': primeiroEnvio
                }
              }), // Usa o email do usuário
            );

      if (response.statusCode == 201) {
        print('Tarefas salvas com sucesso!');
        primeiroEnvio = false; // Atualiza para o próximo envio ser PATCH
      } else if (response.statusCode == 401) {
          final decodedBody = json.decode(response.body);
          if (decodedBody['code'] == "PGRST301"){
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => false,
            );
          }
      } else {
          print(json.decode(response.body));
      }
    } catch (error) {
      print('Erro de rede: $error');
    }
  }

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
    _salvarTarefasServidor();
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
    _salvarTarefasServidor();
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
    _salvarTarefasServidor();
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
        tarefasConcluidas.insert(
            indiceUltimaExcluida!, tarefaExcluidaConcluida!);
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