import "dart:io";
import "package:args/args.dart";
import "cli.dart";
import "parameter.dart";
import "exception.dart";

class CoffeeCommand {
  final String name;
  final String description;
  final executeCommand command;
  final List<CoffeeParameter> parameters;
  final List<CoffeeCommand> subcommands;
  ArgParser parser;

  CoffeeCommand(this.name, this.command,
      {this.parameters: const [], this.description: "", this.subcommands: const []}) {
    if (command == null && subcommands?.isEmpty) {
      throw new CoffeeException("command need to be defined.");
    }
    parser = new ArgParser();
    for (CoffeeParameter param in parameters) {
      parser.addOption(param.name, help: param.description);
    }
    for (CoffeeCommand cmd in subcommands) {
      parser.addCommand(cmd.name, cmd.parser);
    }
  }

  String _parseValue(String value, CoffeeParameter parameter) {
    value = value.split("\n")[0];
    if (value.isEmpty && !parameter.isOptional) {
      stderr.writeln(outputRed("Error: Missing value for '${parameter.name}' parameter."));
      return null;
    } else if (value.isEmpty && parameter.isOptional) {
      value = parameter.defaultValue;
    }
    if (parameter.possibleValues != null && !parameter.possibleValues.contains(value)) {
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
    print("$name usage: ");
    for (CoffeeCommand cmd in subcommands) {
      stdout.write("\t${cmd.name} ");
      print("\t${cmd.parser.usage.split("\n").join("\n\t\t")}");
    }
  }

  List<String> proposeSubCommands(List<String> args) {
      String value;
      List<String> available = subcommands.map((CoffeeCommand cmd) => cmd.name);
      while (value == null) {
          stdout.write(outputGreen("Available commands (${available.join(', ')}) : "));
          value = stdin.readLineSync();
          value = value.split("\n")[0];
          if (!available.contains(value)) {
              stderr.writeln(outputRed("Error: Invalid command '$value'."));
              value = null;
          }
      }

      return [value]..addAll(args);
  }

  execute(List<String> args) {
    try {
      ArgResults results = parser.parse(args);
      if (results.command != null) {
        CoffeeCommand cmd =
            subcommands.firstWhere((CoffeeCommand _) => _.name == results.command.name, orElse: () => null);
        if (cmd == null) {
          printUsage();
        }
        cmd.execute(results.command.arguments);
      } else if (command == null && subcommands.isNotEmpty) {
         execute(proposeSubCommands(args));
      } else if (command != null) {
        Map<String, CoffeeParameter> params = {};
        for (CoffeeParameter param in parameters) {
          if (results.wasParsed(param.name)) {
            param.value = _parseValue(results[param.name], param);
          }
          if (param.value == null && !param.isOptional) {
            ask(param);
          }
          params[param.name] = param;
        }
        command(params);
      }
    } on FormatException catch (_) {
      print(parser.usage);
    }
  }
}
