import "dart:mirrors" as mirror;

import "coffee.dart";
import "utils.dart";

dynamic executeMirror(mirror.ClosureMirror mirFunc, CoffeeResults result) {
  List<mirror.ParameterMirror> params = mirFunc.function.parameters;
  List<dynamic> positionalArgs = [];
  Map<Symbol, dynamic> namedArgs = {};

  for (mirror.ParameterMirror param in params) {
    String name = getSymbolName(param.simpleName);
    dynamic value = result.get(name);
    if (param.isNamed) {
      namedArgs[param.simpleName] = value;
    } else {
      positionalArgs.add(value);
    }
  }

  mirror.InstanceMirror mir = mirFunc.apply(positionalArgs, namedArgs);
  return mir.reflectee;
}

dynamic execute(Function function, CoffeeResults result) => executeMirror(mirror.reflect(function), result);
