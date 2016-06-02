import "cli.dart";
import "exception.dart";

const List<Type> _parameters_type = const [num, String, bool];

class CoffeeParameter {
  final String description;
  final String name;
  final bool isOptional;
  final Type type;
  final String question;
  final List<dynamic> possibleValues;

  dynamic _defaultValue;
  dynamic get defaultValue => _defaultValue;

  dynamic _value;
  dynamic get value => _value;
  set value(dynamic val) {
    if (val != null) {
      if (type == num) {
        _value = num.parse(val);
        return;
      } else if (type == bool) {
        if (val.toLowerCase() == "y" || val.toLowerCase() == "true") {
          _value = true;
        } else if (val.toLowerCase() == "n" || val.toLowerCase() == "false") {
          _value = false;
        }
        return;
      } else {
        if (val.runtimeType != type) {
          throw new CoffeeException("$type in CoffeeParameter is not supported.");
        }
      }
    }
    _value = val;
  }

  CoffeeParameter(this.name, this.type,
      {this.isOptional: false, this.question, dynamic defaultValue, this.description: "", this.possibleValues: null})
      : _defaultValue = defaultValue {
    if (type == null || !_parameters_type.contains(type)) {
      throw new CoffeeException("$type in CoffeeParameter is not supported.");
    }
    if (defaultValue != null && defaultValue.runtimeType != type) {
      throw new CoffeeException("defaultValue need to be the same type ($type).");
    }
    if (type == bool && defaultValue == null) {
      _defaultValue = false;
    }

    value = defaultValue;
  }

  String getQuestion() {
    String _question = question ?? name;
    if (type != bool) {
      if (possibleValues != null) {
        return "${outputGreen(_question)} (${outputWhite(possibleValues.join(", "))}) : ";
      } else if (defaultValue != null) {
        return "${outputGreen(_question)} (${outputWhite(defaultValue)}) : ";
      }
    } else if (type == bool && (defaultValue == false || defaultValue == null)) {
      return "${outputGreen(_question)} ${outputWhite('(y/N)')} : ";
    } else if (type == bool && defaultValue == true) {
      return "${outputGreen(_question)} ${outputWhite('(Y/n)')} : ";
    }
    return "${outputGreen(_question)} : ";
  }
}

class CoffeeStringParameter extends CoffeeParameter {
  CoffeeStringParameter(String name,
      {bool isOptional: false,
      String question,
      dynamic defaultValue,
      String help: "",
      List<dynamic> possibleValues})
      : super(name, String,
            isOptional: isOptional, question: question, defaultValue: defaultValue, possibleValues: possibleValues, description: help);
}

class CoffeeBoolParameter extends CoffeeParameter {
  CoffeeBoolParameter(String name,
      {bool isOptional: false,
      String question,
      dynamic defaultValue,
      String help: "",
      List<dynamic> possibleValues})
      : super(name, bool, isOptional: isOptional, question: question, defaultValue: defaultValue, description: help);
}

class CoffeeNumberParameter extends CoffeeParameter {
  CoffeeNumberParameter(String name,
      {bool isOptional: false,
      String question,
      dynamic defaultValue,
      String help: "",
      List<dynamic> possibleValues})
      : super(name, num,
            isOptional: isOptional, question: question, defaultValue: defaultValue, possibleValues: possibleValues, description: help);
}
