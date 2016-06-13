import "package:ansicolor/ansicolor.dart";

String outputRed(String msg, {bool bold: false}) {
  AnsiPen pen = new AnsiPen()..red(bold: bold);
  return pen(msg);
}

String outputWhite(String msg, {bool bold: false}) {
  AnsiPen pen = new AnsiPen()..white(bold: bold);
  return pen(msg);
}

String outputGreen(String msg, {bool bold: false}) {
  AnsiPen pen = new AnsiPen()..green(bold: bold);
  return pen(msg);
}

String outputBlue(String msg, {bool bold: false}) {
  AnsiPen pen = new AnsiPen()..blue(bold: bold);
  return pen(msg);
}

String outputGray(String msg, {level: 1.0}) {
  AnsiPen pen = new AnsiPen()..gray(level: level);
  return pen(msg);
}

String getSymbolName(Symbol s) =>
    s.toString().replaceAll('Symbol("', '').replaceAll('")', '');
