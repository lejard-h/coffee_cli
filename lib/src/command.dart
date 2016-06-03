import "dart:io";
import "package:args/args.dart";
import "cli.dart";
import "parameter.dart";
import "exception.dart";

typedef executeCommand(Map<String, CoffeeParameter> parameters);

class CoffeeCommand extends CoffeeCli {
  final String name;
  final String description;
  final executeCommand executable;
  final List<CoffeeParameter> parameters;

  CoffeeCommand(this.name, this.executable,
      {this.parameters: const [], this.description: "", List<CoffeeCommand> commands: const []}) {
    this.commands = commands;
    if (executable == null && (commands == null || commands.isEmpty)) {
      throw new CoffeeException("command need to be defined.");
    }
    for (CoffeeParameter param in parameters) {
      if (param.type != bool) {
        parser.addOption(param.name, help: param.help);
      } else {
        parser.addFlag(param.name, negatable: true, help: param.help);
      }
    }
  }

  String _parseValue(String value, CoffeeParameter parameter) {
    value = value.split("\n")[0];
    if (value.isEmpty && !parameter.isOptional && parameter.defaultValue == null) {
      stderr.writeln(outputRed("Error: Missing value for '${parameter.name}' parameter."));
      return null;
    } else if (value.isEmpty && (parameter.isOptional || parameter.defaultValue != null)) {
      value = parameter.defaultValue;
    }
    if (parameter.allowed != null && !parameter.allowed.contains(value)) {
      stderr.writeln(outputRed("Error: Invalid value '$value' for '${parameter.name}' parameter."));
      return null;
    }
    return value;
  }

  ask(CoffeeParameter parameter) {
    String value;
    while (value == null) {
      stdout.write(parameter.getQuestion());
      value = _parseValue(stdin.readLineSync(), parameter);
    }
    parameter.value = value;
  }

  printUsage() {
    stdout.write("\t${outputBlue(name)}");
    print("\t\t${parser.usage.split("\n").join("\n\t\t\t")}");
  }

  printUsageSubCommands() {
    stdout.write("${outputBlue(name)}");
    print("\t${parser.usage.split("\n").join("\n\t")}");
    for (CoffeeCommand cmd in commands) {
      stdout.write("\t${outputBlue(cmd.name)}");
      print("\t${cmd.parser.usage.split("\n").join("\n\t\t")}");
    }
  }

  List<String> proposeSubCommands(List<String> args) {
    String value;
    List<String> available = commands.map((CoffeeCommand cmd) => cmd.name);
    while (value == null) {
      stdout.writeln(outputGray("Available commands", level: 0.5));
      for (String cmd in available) {
        stdout.writeln("${outputGray(" > ", level: 0.5)}${outputBlue(cmd)}");
      }
      value = stdin.readLineSync();
      value = value.split("\n")[0];
      if (value.isEmpty) {
        stderr.writeln(outputRed("Error: Please choose a command."));
        value = null;
      } else if (!available.contains(value)) {
        stderr.writeln(outputRed("Error: Invalid command '$value'."));
        value = null;
      }
    }
    stdout.writeln(outputGray("Launching ", level: 0.5) + outputGray("$name $value") + outputGray(" command...", level: 0.5));
    return [value]..addAll(args);
  }

  int execute(List<String> args) {
    try {
      ArgResults results = parser.parse(args);
      if (results.command != null) {
        CoffeeCommand cmd =
            commands.firstWhere((CoffeeCommand _) => _.name == results.command.name, orElse: () => null);
        if (cmd == null) {
          printUsage();
        }
        return cmd.execute(results.command.arguments);
      } else if (results["help"]) {
        printUsageSubCommands();
      } else if (executable == null && commands.isNotEmpty) {
        return execute(proposeSubCommands(args));
      } else if (executable != null) {
        Map<String, CoffeeParameter> params = {};
        for (CoffeeParameter param in parameters) {
          if (results.wasParsed(param.name)) {
            if (param.type == bool) {
              param.value = results[param.name];
            } else {
              param.value = _parseValue(results[param.name], param);
            }
          }
          if (param.value == null && !param.isOptional) {
            ask(param);
          }
          params[param.name] = param;
        }
        return executable(params);
      }
    } on FormatException catch (_) {
      printUsage();
    } catch (_, stacktrace) {
      print(_);
      print(stacktrace);
    }
    return 1;
  }
}
