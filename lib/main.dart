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
      debugShowCheckedModeBanner: false,
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
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 70),
        child: AppBar(
          title: Center(child: Text('Scenario Manager',style: TextStyle(fontSize: 16),)),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF1F1F1), // Начальный цвет
                //  Color(0xFFFFFFFF),
                //  Color(0xFFFFFFFF),
                  Color(0xFFD9D9D9), // Конечный цвет
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                  stops: [
                        0.0,
                      //  0.4,
                     //   0.5,
                        0.9,
                      ],
              ),
            ),
          ),
          bottom: TabBar(
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                if (states.contains(WidgetState.hovered)) {
                  return Color(0xE0E0E0); // Цвет при наведении
                }
                if (states.contains(WidgetState.pressed)) {
                  return Color(0xFFE30F0F); // Цвет при клике (опционально)
                }
                return null; // По умолчанию
              },
            ),
            controller: _tabController,
            labelPadding: EdgeInsets.symmetric(vertical: 0,horizontal: 20), // минимальные отступы
            indicatorPadding: EdgeInsets.symmetric(vertical: 0),
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(0.0),
                gradient: LinearGradient(
                  colors: [
                    Color(0xF1F1F1), // Начальный цвет
                    //  Color(0xFFFFFFFF),
                    //  Color(0xFFFFFFFF),
                    Color(0xFFFFFFFF), // Конечный цвет
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [
                    0.0,
                    //  0.4,
                    //   0.5,
                    0.9,
                  ],
                ),
              //  color: Color(0xFFB62828)
            ),
            labelColor: Color(0xFF262626),
           // overlayColor: Color(0xFF6E3636),
            unselectedLabelColor: Color(0xFF8C8C8C),
            tabs: const [
              Tab(text: 'Editor'),
              Tab(text: 'Executor'),
            ],
          ),


          backgroundColor: Colors.transparent, // Чтобы градиент был виден
          elevation: 6,
          shadowColor: Color(0x8E3F3F3F),// По желанию: убирает тень
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

