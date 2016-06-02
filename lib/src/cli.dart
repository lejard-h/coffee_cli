import "dart:io";
import "package:args/args.dart";
import "package:ansicolor/ansicolor.dart";
import "command.dart";

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

String outputBlue(String msg, {bool bold}) {
  AnsiPen pen = new AnsiPen()..blue(bold: bold);
  return pen(msg);
}

String outputGray(String msg, {level: 1.0}) {
  AnsiPen pen = new AnsiPen()..gray(level:level);
  return pen(msg);
}


class CoffeeCli {

  final List<CoffeeCommand> commands;
  final ArgParser parser;

  CoffeeCli(this.commands) : parser = new ArgParser() {
    for (CoffeeCommand cmd in commands) {
      parser.addCommand(cmd.name, cmd.parser);
    }
    parser.addFlag("help", abbr: "h", help: "Print Usage", negatable: false);
  }

  printUsage() {
    print("Usage:");
    for (CoffeeCommand cmd in commands) {
      cmd.printUsage();
    }
  }


  int execute(List<String> args) {
    try {
     ArgResults results = parser.parse(args);

      if (results.command != null) {
        CoffeeCommand cmd = commands.firstWhere((CoffeeCommand _) => _.name == results.command.name, orElse: () => null);
        if (cmd == null) {
          cmd.printUsage();
        }
        return cmd.execute(results.command.arguments);
      } else {
        printUsage();
      }
    } on FormatException catch (e) {
      stderr.writeln(outputRed(e.message));
      printUsage();
    } catch (_, stacktrace) {
      print(_);
      //print(stacktrace);
    }
    return 1;
  }
}
