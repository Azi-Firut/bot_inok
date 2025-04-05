import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:bot_inok/logic/position_identify.dart';
import 'package:ffi/ffi.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:win32/win32.dart';

import '../const.dart';

class ScreenshotTaker {
  Timer? _timer; // Таймер теперь nullable
  late String _savePath;
  bool isRunning = false; // Флаг работы таймера

  ScreenshotTaker() {
    _initialize();
  }

  void _initialize() {
    // final exeDir = File(Platform.resolvedExecutable).parent.path; // Папка с .exe
    //  shotDir = Directory(path.join(exeDir, 'shot'));
    //  triggerDir = Directory(path.join(exeDir, 'trigger'));
    //  actionDir = Directory(path.join(exeDir, 'action'));
    //  resultOfScanDir = Directory(path.join(exeDir, 'result'));
    //
    // if (!shotDir.existsSync()) {
    //   shotDir.createSync(recursive: true); // Создаем, если нет
    // }
    // if (!triggerDir.existsSync()) {
    //   triggerDir.createSync(recursive: true); // Создаем, если нет
    // }
    // if (!actionDir.existsSync()) {
    //   actionDir.createSync(recursive: true); // Создаем, если нет
    // }
    // if (!resultOfScanDir.existsSync()) {
    //   resultOfScanDir.createSync(recursive: true); // Создаем, если нет
    // }
    _savePath = path.join(shotDir.path, 'shot.png'); // Полный путь к файлу
    print('Скриншоты сохраняются в: $_savePath');
  }

   start() {
    if (isRunning) return; // Уже запущено
    print('isRunning $isRunning');
    isRunning = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _captureScreenshot();
    });
    print('Скриншотер запущен');
    /// ВАЖНО

  }

   stop() {
    if (!isRunning) return; // Уже остановлен
    print('isRunning $isRunning');
    isRunning = false;
    _timer?.cancel();
    print('Скриншотер остановлен');
  }

  String savePath (){
    return _savePath;
  }

  void _captureScreenshot() {
    final hDC = GetDC(NULL);
    final hMemoryDC = CreateCompatibleDC(hDC);

    final width = GetSystemMetrics(SM_CXSCREEN);
    final height = GetSystemMetrics(SM_CYSCREEN);

    final hBitmap = CreateCompatibleBitmap(hDC, width, height);
    SelectObject(hMemoryDC, hBitmap);
    BitBlt(hMemoryDC, 0, 0, width, height, hDC, 0, 0, SRCCOPY);

    final bmi = calloc<BITMAPINFO>();
    bmi.ref.bmiHeader.biSize = sizeOf<BITMAPINFOHEADER>();
    bmi.ref.bmiHeader.biWidth = width;
    bmi.ref.bmiHeader.biHeight = -height;
    bmi.ref.bmiHeader.biPlanes = 1;
    bmi.ref.bmiHeader.biBitCount = 32;
    bmi.ref.bmiHeader.biCompression = BI_RGB;

    final bufferSize = width * height * 4;
    final buffer = calloc<Uint8>(bufferSize);

    GetDIBits(hMemoryDC, hBitmap, 0, height, buffer.cast<Void>(), bmi, DIB_RGB_COLORS);

    final image = img.Image.fromBytes(
      width: width,
      height: height,
      bytes: buffer.asTypedList(bufferSize).buffer, // Используем Uint8List
      order: img.ChannelOrder.bgra, // Указываем порядок каналов
    );

    final file = File(_savePath);
    file.writeAsBytesSync(img.encodePng(image));
    print('Скриншот сохранен: $_savePath');

    calloc.free(buffer);
    calloc.free(bmi);
    DeleteObject(hBitmap);
    DeleteDC(hMemoryDC);
    ReleaseDC(NULL, hDC);
  }
}

