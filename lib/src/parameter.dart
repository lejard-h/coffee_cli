import "cli.dart";
import "exception.dart";

const List<Type> _parameters_type = const [num, String, bool];

class CoffeeParameter<T> {
  final String help;
  final String name;
  final bool isOptional;
  Type get type => T;
  final String question;
  final List<dynamic> allowed;

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
        if (val is String) {
          if (val.toLowerCase() == "y" || val.toLowerCase() == "true") {
            _value = true;
          } else if (val.toLowerCase() == "n" || val.toLowerCase() == "false") {
            _value = false;
          }
        } else if (val is bool) {
          _value = val;
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

  CoffeeParameter(this.name,
      {this.isOptional: false, this.question, dynamic defaultValue, this.help: "", this.allowed: null})
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
  }

  String getQuestion() {
    String _question = question ?? name;
    if (type != bool) {
      if (allowed != null) {
        return "${outputGreen(_question)} (${outputWhite(allowed.join(", "))}) : ";
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

class CoffeeStringParameter extends CoffeeParameter<String> {
  CoffeeStringParameter(String name,
      {bool isOptional: false, String question, dynamic defaultValue, String help: "", List<dynamic> allowed})
      : super(name,
            isOptional: isOptional,
            question: question,
            defaultValue: defaultValue,
            allowed: allowed,
            help: help);
}

class CoffeeBoolParameter extends CoffeeParameter<bool> {
  CoffeeBoolParameter(String name,
      {bool isOptional: false, String question, dynamic defaultValue, String help: "", List<dynamic> allowed})
      : super(name, isOptional: isOptional, question: question, defaultValue: defaultValue, help: help);
}

class CoffeeNumberParameter extends CoffeeParameter<num> {
  CoffeeNumberParameter(String name,
      {bool isOptional: false, String question, dynamic defaultValue, String help: "", List<dynamic> allowed})
      : super(name,
            isOptional: isOptional,
            question: question,
            defaultValue: defaultValue,
            allowed: allowed,
            help: help);
}
