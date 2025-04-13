import 'dart:async';

import 'package:dartcv4/dartcv.dart' as Imgproc;
import 'package:dartcv4/dartcv.dart';

import '../const.dart';
import 'mouse_activity.dart';

void executeCommand(String command) {
  switch (command) {
    case 'Левый Клик':
      moveCursor(mouseX, mouseY);
      Future.delayed(Duration(milliseconds: 100));
      print("Левый Клик");
      leftClick();
      break;
    case 'Левый Клик 2х':
      moveCursor(mouseX, mouseY);
      Future.delayed(Duration(milliseconds: 100));
      print("Левый Клик 2х");
      leftClickDouble();
      break;
    case 'Переместить курсор':
      print("Переместить курсор");
      moveCursor(mouseX, mouseY);
      break;
    default:
      print("Unknown command: $command");
  }
}

positionIdentifyLoop(triggerStep, actionStep, commandStep) async {
  String saveResultImagePath = resultOfScanDir.path;

  Mat trigger = imread(triggerStep); //пути к картинкам
  Mat action = imread(actionStep); //пути к картинкам

  if (trigger.isEmpty || action.isEmpty) {
    print("Ошибка загрузки trigger/action изображения.");
    return;
  }

  while (true) {
    // 1. Обновление скриншота
    await Future.delayed(Duration(milliseconds: 300));
    String screenshotPath = '${shotDir.path}\\shot.png';
    Mat screenshot = imread(screenshotPath);
    //moveCursor(0, 0);

    if (screenshot.isEmpty) {
      print("Ошибка: скриншот не найден.");
      continue;
    }

    // 2. Поиск триггера
    Point? triggerPos = _matchTemplate(screenshot, trigger);
    if (triggerPos != null) {
      int centerX = triggerPos.x + trigger.width ~/ 2;
      int centerY = triggerPos.y + trigger.height ~/ 2;

      print("Триггер найден в ($centerX, $centerY)");

      // Рисуем найденный триггер
      // Rect rect =
      //     Rect(triggerPos.x, triggerPos.y, trigger.width, trigger.height);
      // rectangle(screenshot, rect, Scalar(0, 255, 0));
      // circle(screenshot, Point(centerX, centerY), 5, Scalar(0, 0, 255));
      // imwrite('$saveResultImagePath/result_trigger.png', screenshot);

      // 3. Запускаем 10 секундный цикл поиска action
      final stopwatch = Stopwatch()..start();
      while (stopwatch.elapsed.inMinutes < 99) {
        await Future.delayed(Duration(milliseconds: 100));
        Mat updatedShot = imread(screenshotPath);
        if (updatedShot.isEmpty) continue;

        Point? actionPos = _matchTemplate(updatedShot, action);
        if (actionPos != null) {
          int actX = actionPos.x + action.width ~/ 2;
          int actY = actionPos.y + action.height ~/ 2;
          print("Action найден в ($actX, $actY)");
          mouseX = actX;
          mouseY = actY;

          // Отмечаем и сохраняем результат
          Rect rect =
              Rect(actionPos.x, actionPos.y, action.width, action.height);
          rectangle(updatedShot, rect, Scalar(255, 0, 0));
          circle(updatedShot, Point(actX, actY), 5, Scalar(0, 255, 255));
          imwrite('$saveResultImagePath/result_action.png', updatedShot);

          /// TEST (works)
          executeCommand(commandStep);
          return;

          ///
          break; // нашли action — выходим из 10-секундного цикла
        }
      }
      // После 10 секунд вернёмся к поиску триггера
    }
  }
}

/// Вспомогательная функция для поиска шаблона
Point? _matchTemplate(Mat source, Mat template) {
  int resultCols = source.width - template.width + 1;
  int resultRows = source.height - template.height + 1;

  if (resultCols < 1 || resultRows < 1) {
    return null;
  }

  Mat result = Mat.zeros(resultRows, resultCols, MatType.CV_32FC1);
  matchTemplate(source, template, Imgproc.TM_CCOEFF_NORMED, result: result);

  var (minVal, maxVal, minLoc, maxLoc) = minMaxLoc(result);

  if (maxVal > 0.9) {
    // порог уверенности  0.8
    return maxLoc;
  } else {
    return null;
  }
}
