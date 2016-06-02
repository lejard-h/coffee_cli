import "package:args/args.dart";
import "package:ansicolor/ansicolor.dart";
import "command.dart";
import 'parameter.dart';

typedef void executeCommand(Map<String, CoffeeParameter> parameters);

class CoffeeCli {
  final String name;
  final List<CoffeeCommand> commands;
  ArgParser _parser;

  CoffeeCli(this.name, this.commands) {
    _generateArgParser();
  }

  void _generateArgParser() {
    _parser = new ArgParser();
    for (CoffeeCommand cmd in commands) {
      _parser.addCommand(cmd.name, cmd.parser);
    }
  }

  execute(List<String> args) {
    try {
      ArgResults results = _parser.parse(args);

      if (results.command != null) {
        CoffeeCommand cmd =
            commands.firstWhere((CoffeeCommand _) => _.name == results.command.name, orElse: () => null);
        if (cmd == null) {
          print(_parser.usage);
        }
        cmd.execute(results.command.arguments);
      } else {
        print(_parser.usage);
      }
    } on FormatException catch (_) {
      print(_parser.usage);
    }
  }
}

String outputRed(String msg, {bool bold}) {
  AnsiPen pen = new AnsiPen()..red(bold: bold);
  return pen(msg);
}

String outputWhite(String msg, {bool bold}) {
  AnsiPen pen = new AnsiPen()..white(bold: bold);
  return pen(msg);
}

String outputGreen(String msg, {bool bold}) {
  AnsiPen pen = new AnsiPen()..green(bold: bold);
  return pen(msg);
}