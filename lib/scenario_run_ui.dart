import 'dart:convert';
import 'dart:io';

import 'package:bot_inok/logic/print_screen.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import 'logic/position_identify.dart';

void main() {
  runApp(ScenarioApp());
}

class ScenarioApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScenarioScreen(),
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

class ScenarioScreen extends StatefulWidget {
  @override
  _ScenarioScreenState createState() => _ScenarioScreenState();
}

class _ScenarioScreenState extends State<ScenarioScreen> {
  bool _isExecuting = false;
  List<Scenario> scenarios = [];
  List<String> commands = [
    'Левый Клик',
    'Левый Клик 2х',
    'Переместить курсор'
  ]; // Заглушки
  Map<Scenario, bool> selectedScenarios = {};

  @override
  void initState() {
    super.initState();
    _loadScenarios();
  }

  Future<void> _loadScenarios() async {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final scenarioFile = File(path.join(exeDir, 'scenario', 'plot.json'));

    if (scenarioFile.existsSync()) {
      String jsonContent = await scenarioFile.readAsString();
      Map<String, dynamic> data = jsonDecode(jsonContent);
      setState(() {
        scenarios = (data['scenarios'] as List)
            .map((s) => Scenario.fromJson(s))
            .toList();
        for (var scenario in scenarios) {
          selectedScenarios[scenario] = false;
        }
      });
    }
  }

  void _executeSelectedScenarios() async {
    setState(() => _isExecuting = true);
    for (var scenario in scenarios) {
      if (selectedScenarios[scenario] == true) {
        print("🚀 Выполняется сценарий: ${scenario.name}");
        for (var step in scenario.steps) {
          ScreenshotTaker().start();
          await positionIdentifyLoop(
              step.trigger, step.action, step.command); // 💡 await
          print(
              "✅ Завершён шаг: Trigger=${step.trigger}, Command=${step.command}, Action=${step.action}");
        }
        print("✅ Сценарий '${scenario.name}' завершён\n");
      }
    }
    setState(() => _isExecuting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Scenario Executor')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                for (var scenario in scenarios)
                  ListTile(
                    leading: Checkbox(
                      value: selectedScenarios[scenario] ?? false,
                      onChanged: (bool? value) {
                        setState(() {
                          selectedScenarios[scenario] = value ?? false;
                        });
                      },
                    ),
                    title: Text(scenario.name),
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _isExecuting ? null : _executeSelectedScenarios,
            child: Text('Execute Selected'),
          ),
        ],
      ),
    );
  }
}
