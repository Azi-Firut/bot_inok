import 'dart:convert';
import 'dart:io';
import 'package:bot_inok/scenario_run_ui.dart';
import 'package:bot_inok/scenario_create_ui.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

import 'const.dart';

void main() {
  runApp(BotInok());
}

class BotInok extends StatelessWidget {
  const BotInok({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScenarioMainScreen(),
    );
  }
}

class ScenarioMainScreen extends StatefulWidget {
  @override
  _ScenarioMainScreenState createState() => _ScenarioMainScreenState();
}

class _ScenarioMainScreenState extends State<ScenarioMainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final exeDir = File(Platform.resolvedExecutable).parent.path; // Папка с .exe
    shotDir = Directory(path.join(exeDir, 'shot'));
    triggerDir = Directory(path.join(exeDir, 'trigger'));
    actionDir = Directory(path.join(exeDir, 'action'));
    resultOfScanDir = Directory(path.join(exeDir, 'result'));

    if (!shotDir.existsSync()) {
      shotDir.createSync(recursive: true); // Создаем, если нет
    }
    if (!triggerDir.existsSync()) {
      triggerDir.createSync(recursive: true); // Создаем, если нет
    }
    if (!actionDir.existsSync()) {
      actionDir.createSync(recursive: true); // Создаем, если нет
    }
    if (!resultOfScanDir.existsSync()) {
      resultOfScanDir.createSync(recursive: true); // Создаем, если нет
    }
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scenario Manager'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Editor'),
            Tab(text: 'Executor'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ScenarioEditorApp(),
          ScenarioScreen(),
        ],
      ),
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
      steps: (json['steps'] as List).map((s) => ScenarioStep.fromJson(s)).toList(),
    );
  }
}

class ScenarioStep {
  String trigger;
  String command;
  String action;

  ScenarioStep({required this.trigger, required this.command, required this.action});

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
  List<String> commands = ['noop', 'command1', 'command2'];

  void _addScenario() {
    setState(() {
      scenarios.add(Scenario(name: 'New Scenario', steps: []));
    });
  }

  void _addStep(Scenario scenario) {
    setState(() {
      scenario.steps.add(ScenarioStep(trigger: '', command: 'noop', action: ''));
    });
  }

  Future<void> _pickFile(Function(String) onFilePicked) async {
    String? filePath = await FilePicker.platform.pickFiles(type: FileType.image).then((result) => result?.files.single.path);
    if (filePath != null) {
      onFilePicked(filePath);
    }
  }

  void _saveScenarios() {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final scenarioDir = Directory(path.join(exeDir, 'scenario'));
    if (!scenarioDir.existsSync()) {
      scenarioDir.createSync(recursive: true);
    }
    String jsonContent = jsonEncode({'scenarios': scenarios.map((s) => s.toJson()).toList()});
    File('${scenarioDir.path}/plot.json').writeAsString(jsonContent);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              for (var scenario in scenarios)
                Card(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Checkbox(value: true, onChanged: (value) {}),
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(text: scenario.name),
                              onChanged: (value) => scenario.name = value,
                              decoration: InputDecoration(labelText: 'Scenario Name'),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => _addStep(scenario),
                          ),
                        ],
                      ),
                      for (var step in scenario.steps)
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.image),
                              onPressed: () => _pickFile((path) => setState(() => step.trigger = path)),
                            ),
                            DropdownButton<String>(
                              value: step.command,
                              onChanged: (value) => setState(() => step.command = value!),
                              items: commands.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            ),
                            IconButton(
                              icon: Icon(Icons.image),
                              onPressed: () => _pickFile((path) => setState(() => step.action = path)),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        ElevatedButton(onPressed: _addScenario, child: Text('Add Scenario')),
        ElevatedButton(onPressed: _saveScenarios, child: Text('Save Scenarios')),
      ],
    );
  }
}

