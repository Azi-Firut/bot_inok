import 'dart:ffi';
import 'package:win32/win32.dart';

/// Перемещение курсора в указанные координаты (X, Y)
void moveCursor(int x, int y) {
  SetCursorPos(x, y);
}

/// Левый клик мыши
void leftClick() {
  final mouseEvent = DynamicLibrary.open('user32.dll')
      .lookupFunction<Void Function(Uint32, Uint32, Int32, UintPtr, IntPtr),
      void Function(int, int, int, int, int)>('mouse_event');
  mouseEvent(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
  mouseEvent(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
}
void leftClickDouble() {
  final mouseEvent = DynamicLibrary.open('user32.dll')
      .lookupFunction<Void Function(Uint32, Uint32, Int32, UintPtr, IntPtr),
      void Function(int, int, int, int, int)>('mouse_event');
  mouseEvent(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
  mouseEvent(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
  Future.delayed(Duration(milliseconds: 200));
  mouseEvent(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
  mouseEvent(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
}
void holdLeftClick() {
  final mouseEvent = DynamicLibrary.open('user32.dll')
      .lookupFunction<Void Function(Uint32, Uint32, Int32, UintPtr, IntPtr),
      void Function(int, int, int, int, int)>('mouse_event');
  mouseEvent(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
}
void releaseLeftClick() {
  final mouseEvent = DynamicLibrary.open('user32.dll')
      .lookupFunction<Void Function(Uint32, Uint32, Int32, UintPtr, IntPtr),
      void Function(int, int, int, int, int)>('mouse_event');
  mouseEvent(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
}
/// Правый клик мыши
void rightClick() {
  final mouseEvent = DynamicLibrary.open('user32.dll')
      .lookupFunction<Void Function(Uint32, Uint32, Int32, UintPtr, IntPtr),
      void Function(int, int, int, int, int)>('mouse_event');
  mouseEvent(MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0);
  mouseEvent(MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0);
}
void holdRightClick() {
  final mouseEvent = DynamicLibrary.open('user32.dll')
      .lookupFunction<Void Function(Uint32, Uint32, Int32, UintPtr, IntPtr),
      void Function(int, int, int, int, int)>('mouse_event');
  mouseEvent(MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0);
}
void releaseRightClick() {
  final mouseEvent = DynamicLibrary.open('user32.dll')
      .lookupFunction<Void Function(Uint32, Uint32, Int32, UintPtr, IntPtr),
      void Function(int, int, int, int, int)>('mouse_event');
  mouseEvent(MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0);
}
/// Прокрутка колесика мыши (положительное значение – вверх, отрицательное – вниз)
void scrollMouse(int delta) {
  final mouseEvent = DynamicLibrary.open('user32.dll')
      .lookupFunction<Void Function(Uint32, Uint32, Int32, UintPtr, IntPtr),
      void Function(int, int, int, int, int)>('mouse_event');

  mouseEvent(MOUSEEVENTF_WHEEL, 0, 0, delta, 0);
}
