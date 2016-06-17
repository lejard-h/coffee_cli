import "dart:io";
import "dart:async";
import "dart:mirrors" as mirror;
import "package:args/args.dart";

import "utils.dart";
import "execute.dart" as exec;
import "question.dart";
import "exception.dart";
import "parameter.dart";
import "command.dart";

class _CoffeeParameter {
  Type type;

  String question;
  bool optional;
  dynamic defaultValue;
  List allowed;
  String help;
  QuestionFactory defineQuestion;

  String usage(String name) => type == bool
      ? "--[no-]$name ${help != null ? help : ''}"
      : "--$name='$name'${ defaultValue != null ? ' (default: $defaultValue)' : ''}${help != null ? " $help" : ''}";

  _CoffeeParameter(
      {this.question, this.optional: true, this.defaultValue, this.type, this.allowed, this.help, this.defineQuestion});

  _CoffeeParameter.fromConst(final CoffeeParameter opt) {
    question = opt.question;
    defaultValue = opt.defaultValue;
    allowed = opt.allowed;
    help = opt.help;
    defineQuestion = opt.defineQuestion;
  }
}

class _CoffeeCommand {
  Map<String, _CoffeeParameter> options = {};
  mirror.ClosureMirror function;
  String help;
  ArgParser parser;
  String name;

  _CoffeeCommand(this.name, {this.options: const {}, this.function, this.help}) {
    _constructOptions();
  }

  _CoffeeCommand.fromConst(final CoffeeCommand cmd, {mirror.ClosureMirror func}) {
    if (func != null || cmd.function == null) {
      function = func;
    } else {
      function = mirror.reflect(cmd.function);
    }
    help = cmd.help;
    _constructOptions();
  }

  ArgParser constructParser() {
    parser = new ArgParser();
    for (String name in options.keys) {
      _CoffeeParameter opt = options[name];
      if (opt.type == bool) {
        parser.addFlag(name, defaultsTo: opt.defaultValue, negatable: true, help: opt.help);
      } else {
        parser.addOption(name,
            allowed: opt.allowed?.map((value) => value.toString()), defaultsTo: opt.defaultValue, help: opt.help);
      }
    }
    return parser;
  }

  Future<dynamic> ask(CoffeeAsker asker, [bool optional]) async {
    dynamic value = await asker.ask();
    while (value == null && !optional) {
      stdout.writeln(outputRed("Please provide a value"));
      value = await asker.ask();
    }
    return value;
  }

  Future execute(List<String> args) async {
    ArgResults results = parser.parse(args);
    CoffeeResults opts = new CoffeeResults(results, this);
    for (String name in options.keys) {
      _CoffeeParameter opt = options[name];
      if (opts.get(name) == null) {
        CoffeeAsker asker;
        String question = opt.question ?? name;
        if (opt.type == bool) {
          asker = new CoffeeAsker<bool>(question, defaultValue: opt.defaultValue, allowed: opt.allowed as List<bool>);
        } else if (opt.type == double) {
          asker =
              new CoffeeAsker<double>(question, defaultValue: opt.defaultValue, allowed: opt.allowed as List<double>);
        } else if (opt.type == num) {
          asker = new CoffeeAsker<num>(question, defaultValue: opt.defaultValue, allowed: opt.allowed as List<num>);
        } else if (opt.type == int) {
          asker = new CoffeeAsker<int>(question, defaultValue: opt.defaultValue, allowed: opt.allowed as List<int>);
        } else {
          asker =
              new CoffeeAsker<String>(question, defaultValue: opt.defaultValue, allowed: opt.allowed as List<String>);
        }
        if (opt.defineQuestion != null) {
          asker.question = opt.defineQuestion(asker.question) ?? asker.question;
        }
        opts.setValue(name, await ask(asker, opt.optional));
      }
      /* else if (opts.get(name) == null && opt.optional && opt.defaultValue != null) {
        opts.setValue(name, opt.defaultValue);
      }*/
    }
    return exec.executeMirror(function, opts);
  }

  _constructOptions() {
    Map<String, _CoffeeParameter> opts = options ?? {};

    function.function.parameters.forEach((final mirror.ParameterMirror param) {
      CoffeeParameter opt = param.metadata
          .firstWhere((final mirror.InstanceMirror i) => i.reflectee is CoffeeParameter, orElse: () => null)
          ?.reflectee;
      if (opt != null) {
        dynamic defaultValue;
        if (param.isOptional) {
          defaultValue = param.defaultValue.reflectee;
        } else {
          defaultValue = opt.defaultValue;
        }
        if (param.type.reflectedType == bool && defaultValue == null) {
          defaultValue = false;
        }
        opts[getSymbolName(param.simpleName)] = new _CoffeeParameter(
            help: opt.help,
            question: opt.question,
            optional: param.isOptional,
            defaultValue: defaultValue,
            type: param.type.reflectedType,
            defineQuestion: opt.defineQuestion,
            allowed: opt.allowed);
      } else {
        opts[getSymbolName(param.simpleName)] = new _CoffeeParameter(
            question: getSymbolName(param.simpleName), optional: false, type: param.type.reflectedType);
      }
    });
    options = opts;
  }
}

class CoffeeResults {
  _CoffeeCommand command;
  ArgResults _result;
  Map<String, dynamic> values = {};

  CoffeeResults(this._result, this.command);

  setValue(String name, dynamic value) {
    values[name] = value;
  }

  dynamic get(String name) {
    if (_result.wasParsed(name)) {
      values[name] = _result[name];
    }
    return values[name];
  }
}

class CoffeeCli {
  final Map<String, _CoffeeCommand> _commands = {};
  final Map<String, CoffeeCli> _subCommands = {};
  ArgParser parser = new ArgParser();
  String help;

  CoffeeCli() {
    _constructCommands();
  }

  _constructCommands() {
    mirror
        .reflect(this)
        .type
        .instanceMembers
        .values
        .where((mirror.MethodMirror m) => m.metadata.any((i) => i.reflectee is CoffeeCommand))
        .forEach((mirror.MethodMirror m) {
      _addCommand(
          getSymbolName(m.simpleName),
          m.metadata.firstWhere((i) => i.reflectee is CoffeeCommand).reflectee as CoffeeCommand,
          mirror.reflect(mirror.reflect(this).getField(m.simpleName).reflectee));
    });
    mirror
        .reflect(this)
        .type
        .declarations
        .values
        .where((mirror.DeclarationMirror m) => m.metadata.any((i) => i.reflectee is CoffeeCommand))
        .where((mirror.DeclarationMirror m) => m is mirror.VariableMirror)
        .forEach((mirror.DeclarationMirror d) {
      if (mirror.reflect(this).getField(d.simpleName).reflectee is CoffeeCli) {
        (mirror.reflect(this).getField(d.simpleName).reflectee as CoffeeCli).help =
            (d.metadata.firstWhere((i) => i.reflectee is CoffeeCommand).reflectee as CoffeeCommand).help;
        addSubCommand(getSymbolName(d.simpleName), mirror.reflect(this).getField(d.simpleName).reflectee);
      }
    });

    parser.addFlag("help", abbr: "h");
  }

  _addCommand(String name, CoffeeCommand cmd, mirror.ClosureMirror func) {
    if (_commands.containsKey(name)) {
      throw new CoffeeException("Command '${name}' already exist.");
    }
    _commands[name] = new _CoffeeCommand.fromConst(cmd, func: func);
    _commands[name].name = name;
    parser.addCommand(name, _commands[name].constructParser());
  }

  addCommand(String name, CoffeeCommand cmd) {
    if (cmd.function == null) {
      throw new CoffeeException("Function in '${name}' command is undefined.");
    }
    _addCommand(name, cmd, mirror.reflect(cmd.function));
  }

  addSubCommand(String name, CoffeeCli cli) {
    if (_subCommands.containsKey(name)) {
      throw new CoffeeException("SubCommand '${name}' already exist.");
    }
    _subCommands[name] = cli;
    parser.addCommand(name, cli.parser);
  }

  Future executeCommand(String name, List<String> args) {
    if (!_commands.containsKey(name)) {
      throw new CoffeeException("Command '$name' not found.");
    }
    return _commands[name].execute(args);
  }

  usage() {
    _subCommands.forEach((String name, CoffeeCli cli) {
      stdout.writeln("\t${outputBlue(name)}${cli.help == null ? "" : '\t\t${cli.help}'}");
    });
    if (_subCommands.isNotEmpty && _commands.isNotEmpty) {
      print("");
    }
    _commands.forEach((String name, _CoffeeCommand cmd) {
      stdout.write("\t${outputBlue(name)}");
      if (cmd.help != null) {
        stdout.write("\t\t${cmd.help}");
      }
      stdout.writeln("");
      for (String p in cmd.options.keys) {
        stdout.writeln("\t\t\t\t${cmd.options[p].usage(p)}");
      }
    });
  }

  Future execute(List<String> args) async {
    try {
      ArgResults results = parser.parse(args);

      if (results["help"]) {
        return usage();
      } else if (results.command != null) {
        if (_commands.containsKey(results.command.name)) {
          return executeCommand(results.command.name, results.command.arguments);
        } else if (_subCommands.containsKey(results.command.name)) {
          return _subCommands[results.command.name].execute(results.command.arguments);
        }
      } else if (_commands.isNotEmpty) {
        List allowed = _commands.keys.toList();
        MultiChoiceAsker asker = new MultiChoiceAsker("Available commands", allowed);
        String result = await asker.ask();
        stdout.writeln("${outputGray("You choose the command =>", level: 0.5)} ${outputBlue(result)}");
        return executeCommand(result, []);
      } else {
        return usage();
      }
    } on FormatException catch (e) {
      stderr.writeln(outputRed(e.message));
      return usage();
    } catch (_, stacktrace) {
      print(_);
      print(stacktrace);
    }
    return 1;
  }
}
