import 'dart:async';
import 'dart:io';
import 'package:dartcv4/core.dart';
import 'package:dartcv4/dartcv.dart';
import 'package:dartcv4/dartcv.dart' as Imgproc;
import 'package:path/path.dart' as path;
import '../const.dart';
import 'mouse_activity.dart';

void positionIdentifyLoop() async {
  //String screenshotPath = shotDir.path;
  String triggerImagePath = triggerDir.path;
  String actionImagePath = actionDir.path;
  String saveResultImagePath = resultOfScanDir.path;

  Mat trigger = imread('$triggerImagePath\\trigger.png');
  Mat action = imread('$actionImagePath\\action.png');

  if (trigger.isEmpty || action.isEmpty) {
    print("Ошибка загрузки trigger/action изображения.");
    return;
  }

  while (true) {
    // 1. Обновление скриншота
    await Future.delayed(Duration(seconds: 1));
    String screenshotPath = '${shotDir.path}\\shot.png';
    Mat screenshot = imread(screenshotPath);

    if (screenshot.isEmpty) {
      print("Ошибка: скриншот не найден.");
      continue;
    }

    // 2. Поиск триггера
    Point? triggerPos = _matchTemplate(screenshot, trigger);
    if (triggerPos != null) {
      int centerX = triggerPos.x + trigger.width ~/ 2;
      int centerY = triggerPos.y + trigger.height ~/ 2;
      //mouseX = centerX;
      //mouseY = centerY;

      print("Триггер найден в ($centerX, $centerY)");

      // Рисуем найденный триггер
      Rect rect = Rect(triggerPos.x, triggerPos.y, trigger.width, trigger.height);
      rectangle(screenshot, rect, Scalar(0, 255, 0));
      circle(screenshot, Point(centerX, centerY), 5, Scalar(0, 0, 255));
      imwrite('$saveResultImagePath/result_trigger.png', screenshot);

      // 3. Запускаем 10 секундный цикл поиска action
      final stopwatch = Stopwatch()..start();
      while (stopwatch.elapsed.inSeconds < 10) {
        await Future.delayed(Duration(seconds: 1));
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
          Rect rect = Rect(actionPos.x, actionPos.y, action.width, action.height);
          rectangle(updatedShot, rect, Scalar(255, 0, 0));
          circle(updatedShot, Point(actX, actY), 5, Scalar(0, 255, 255));
          imwrite('$saveResultImagePath/result_action.png', updatedShot);
          /// TEST (works)
          moveCursor(mouseX, mouseY);
          Future.delayed(Duration(milliseconds: 100));
          leftClickDouble();
          ///
         // moveCursor(mouseX, mouseY);
         // executeCommand(step.command);
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

  if (maxVal > 0.8) { // порог уверенности
    return maxLoc;
  } else {
    return null;
  }
}





// import 'dart:io';
// import 'package:dartcv4/core.dart';
// import 'package:dartcv4/dartcv.dart';
// import 'package:dartcv4/dartcv.dart' as Imgproc;
//
// import '../const.dart';
//
// void positionIdentify() {
//   // Пути к изображениям
//   String screenshotPath = shotDir.path;
//   String triggerImagePath = triggerDir.path;
//   String saveResultImagePath = resultOfScanDir.path;
//   String actionImagePath = actionDir.path;
//   /// ACTION
//   //String actionImagePath = pathToActionImage;
//   //Mat action = imread('$actionImagePath/action.png');
//
//   // Загружаем изображения
//   Mat screenshot = imread('$screenshotPath/shot.png');
//   Mat trigger = imread('$triggerImagePath/trigger.png');
//   Mat action = imread('$actionImagePath/action.png');
//
//   // Проверяем, загружены ли изображения
//   if (screenshot.isEmpty || trigger.isEmpty) {
//     print("Ошибка: не удалось загрузить изображения trigger.");
//     return;
//   }
//   if (screenshot.isEmpty || action.isEmpty) {
//     print("Ошибка: не удалось загрузить изображения action.");
//     return;
//   }
//   // Создаем матрицу для результата
//   int resultCols = screenshot.width - trigger.width + 1;
//   int resultRows = screenshot.height - trigger.height + 1;
//   Mat result = Mat.zeros(resultRows, resultCols, MatType.CV_32FC1);
//
//   // Применяем matchTemplate
//   matchTemplate(screenshot, trigger, Imgproc.TM_CCOEFF_NORMED, result: result);
//
//   // Ищем максимальное совпадение
//   var (minVal, maxVal, minLoc, maxLoc) = minMaxLoc(result);
//   Point topLeft = maxLoc;
//
//   int foundX = topLeft.x.toInt();
//   int foundY = topLeft.y.toInt();
//   int centerX = foundX + trigger.width ~/ 2;
//   int centerY = foundY + trigger.height ~/ 2;
//   // Передаём глобальные координаты найденного центра для мышки
//   mouseX=centerX;
//   mouseY=centerY;
//
//   print("Координаты верхнего левого угла: ($foundX, $foundY)");
//   print("Центр малой картинки: ($centerX, $centerY)");
//
//   // Создаем прямоугольник вокруг найденной области
//   Rect rect = Rect(topLeft.x, topLeft.y, trigger.width, trigger.height);
//   rectangle(screenshot, rect, Scalar(0, 255, 0)); // Теперь корректный вызов!
//
//   // Рисуем точку в центре найденного объекта
//   circle(screenshot, Point(centerX, centerY), 5, Scalar(0, 0, 255)); // Добавлен цвет
//
//
//   // Сохраняем результат
//   print("Текущая директория: ${Directory.current.path}");
//
//   imwrite('$saveResultImagePath/result.png', screenshot);
//
//  // imwrite('result.png', screenshot);
//
//   print("Результат сохранен в result.png");
// }
