import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

void main() {
  runApp(ScenarioEditorApp());
}

class ScenarioEditorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // color: Colors.red,
      debugShowCheckedModeBanner: false,
      home: ScenarioEditorScreen(),
    );
  }
}

class Scenario {
  String name;
  List<ScenarioStep> steps;

  Scenario({required this.name, required this.steps});

  Map<String, dynamic> toJson() => {
        'name': name,
        'steps': steps.map((s) => s.toJson()).toList(),
      };

  static Scenario fromJson(Map<String, dynamic> json) {
    return Scenario(
      name: json['name'],
      steps:
          (json['steps'] as List).map((s) => ScenarioStep.fromJson(s)).toList(),
    );
  }
}

class ScenarioStep {
  String trigger;
  String command;
  String action;

  ScenarioStep(
      {required this.trigger, required this.command, required this.action});

  Map<String, dynamic> toJson() => {
        'trigger': trigger,
        'command': command,
        'action': action,
      };

  static ScenarioStep fromJson(Map<String, dynamic> json) {
    return ScenarioStep(
      trigger: json['trigger'],
      command: json['command'],
      action: json['action'],
    );
  }
}

class ScenarioEditorScreen extends StatefulWidget {
  @override
  _ScenarioEditorScreenState createState() => _ScenarioEditorScreenState();
}

class _ScenarioEditorScreenState extends State<ScenarioEditorScreen> {
  List<Scenario> scenarios = [];
  List<String> commands = [
    'Левый Клик',
    'Левый Клик 2х',
    'Переместить курсор'
  ]; // Заглушки

  @override
  void initState() {
    super.initState();
    _loadScenarios();
  }

  void _addScenario() {
    setState(() {
      scenarios.add(Scenario(name: 'Новый сценарий', steps: []));
    });
  }

  void _addStep(Scenario scenario) {
    setState(() {
      scenario.steps
          .add(ScenarioStep(trigger: '', command: 'Левый Клик', action: ''));
    });
  }

  Future<void> _pickFile(Function(String) onFilePicked) async {
    String? filePath = await FilePicker.platform
        .pickFiles(type: FileType.image)
        .then((result) => result?.files.single.path);
    if (filePath != null) {
      onFilePicked(filePath);
    }
  }

  void _saveScenarios() {
    final exeDir =
        File(Platform.resolvedExecutable).parent.path; // Папка с .exe
    final scenarioDir = Directory(path.join(exeDir, 'scenario'));

    if (!scenarioDir.existsSync()) {
      scenarioDir.createSync(recursive: true); // Создаем, если нет
    }
    String jsonContent =
        jsonEncode({'scenarios': scenarios.map((s) => s.toJson()).toList()});
    File('${scenarioDir.path}/plot.json').writeAsString(jsonContent);
  }

  void _loadScenarios() {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final scenarioFile = File(path.join(exeDir, 'scenario', 'plot.json'));

    if (scenarioFile.existsSync()) {
      final content = scenarioFile.readAsStringSync();
      final data = jsonDecode(content);
      setState(() {
        scenarios = (data['scenarios'] as List)
            .map((s) => Scenario.fromJson(s))
            .toList();
      });
    }
  }

  void _removeScenario(int index) {
    setState(() {
      scenarios.removeAt(index);
    });
  }

  Widget _buildImageOrIcon(String imagePath, VoidCallback onPressed) {
    if (imagePath.isNotEmpty && File(imagePath).existsSync()) {
      return Image.file(
        File(imagePath),
        width: 48,
        height: 48,
        fit: BoxFit.cover,
      );
    } else {
      return IconButton(
        icon: Icon(
          Icons.image_search_outlined,
          size: 32,
        ),
        onPressed: onPressed,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD7D7D7),
      // appBar: AppBar(
      //
      //     title: Text('Scenario Editor')),
      body: ListView(
        children: [
          for (int i = 0; i < scenarios.length; i++)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
              child: Card(
                color: Color(0xFFFFFFFF),
                elevation: 6,
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Checkbox(value: true, onChanged: (value) {}),
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: TextEditingController(
                                  text: scenarios[i].name),
                              onChanged: (value) => scenarios[i].name = value,
                              decoration:
                                  InputDecoration(labelText: 'Scenario Name'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _removeScenario(i),
                          ),
                        ),
                      ],
                    ),
                    for (var step in scenarios[i].steps)
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildImageOrIcon(
                                step.trigger,
                                () => _pickFile((path) =>
                                    setState(() => step.trigger = path))),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButton<String>(
                              value: step.command,
                              onChanged: (value) =>
                                  setState(() => step.command = value!),
                              items: commands
                                  .map((c) => DropdownMenuItem(
                                      value: c, child: Text(c)))
                                  .toList(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildImageOrIcon(
                                step.action,
                                () => _pickFile((path) =>
                                    setState(() => step.action = path))),
                          ),
                        ],
                      ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0, bottom: 8),
                        child: IconButton(
                          icon: Icon(
                            Icons.add,
                            //size: 48,
                          ),
                          onPressed: () => _addStep(scenarios[i]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(
                left: 12.0, right: 12, bottom: 16, top: 12),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton(
                    onPressed: _addScenario,
                    style: ButtonStyle(
                      elevation: WidgetStatePropertyAll(6),
                      backgroundColor:
                          WidgetStatePropertyAll<Color>(Color(0xFFFFFFFF)),
                    ),
                    child: Text(
                      'Add Scenario',
                      style: TextStyle(
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton(
                    onPressed: _saveScenarios,
                    style: ButtonStyle(
                      elevation: WidgetStatePropertyAll(6),
                      backgroundColor:
                          WidgetStatePropertyAll<Color>(Color(0xFFFFFFFF)),
                    ),
                    child: Text(
                      'Save Scenarios',
                      style: TextStyle(
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
