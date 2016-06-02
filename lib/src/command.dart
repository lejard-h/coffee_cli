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
    ArgParser parser;

    CoffeeCommand(this.name, this.command, {this.parameters: const [], this.description: ""}) {
        if (command == null) {
            throw new CoffeeException("command need to be defined.");
        }
        parser = new ArgParser();
        for (CoffeeParameter param in parameters) {
            parser.addOption(param.name, help: param.description);
        }
    }

    void setParameterValue(String name, dynamic value) {
        CoffeeParameter param = parameters.firstWhere((CoffeeParameter _) => _.name == name, orElse: () => null);
        if (param != null) {
            param.value = value;
            return;
        }
        throw new CoffeeException("$name parameter not found.");
    }

    dynamic getParameterValue(String name) {
        CoffeeParameter param = parameters.firstWhere((CoffeeParameter _) => _.name == name, orElse: () => null);
        if (param != null) {
            return param.value;
        }
        throw new CoffeeException("$name parameter not found.");
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

    execute(List<String> args) {
        try {
            ArgResults results = parser.parse(args);
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
        } on FormatException catch (_) {
            print(parser.usage);
        }
    }
}