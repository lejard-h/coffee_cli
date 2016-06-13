/**
 * Created by lejard_h on 05/06/16.
 */

import "dart:async";
import "dart:io";
import "dart:isolate";
import "utils.dart";
import "exception.dart";

class CoffeeQuestion {
  final String question;
  final String defaultValue;
  final List allowed;

  const CoffeeQuestion(this.question, {this.defaultValue, this.allowed});

  String _constructQuestion() {
    String _question = "${outputGreen("$question ?")} ";

    if (defaultValue != null) {
      _question += "${outputWhite("(default: $defaultValue)")} ";
    }
    if (allowed != null) {
      _question += "${outputWhite("[allowed: ${allowed.join(", ")}]")} ";
    }
    return "$_question: ";
  }

  Future<String> _allowedChoice() async {
    MultiChoiceAsker asker = new MultiChoiceAsker(question, allowed);
    return asker.ask();
  }

  Future<String> ask() async {
    if (allowed == null) {
      stdout.write(_constructQuestion());
      return stdin.readLineSync();
    }
    return await _allowedChoice();
  }
}

class MultiChoiceAsker {
  final String question;
  final List allowed;

  MultiChoiceAsker(this.question, this.allowed);

  ask() async {
    ReceivePort response = new ReceivePort();
    Isolate.spawnUri(Uri.parse("packages/coffee_cli/src/asker.dart"), [question, allowed.join(";")], response.sendPort);
    return response.first;
  }
}

class CoffeeAsker<T> {
  Type get type => T;
  T value;
  T _defaultValue;
  final List<T> allowed;
  CoffeeQuestion question;

  CoffeeAsker(String question, {T defaultValue, this.allowed}) {
    _defaultValue = defaultValue;
    String _default = _defaultValue?.toString();
    if (T == bool) {
      if (_defaultValue == true) {
        _default = "Y/n";
      } else {
        _default = "y/N";
        _defaultValue = false as T;
      }
    }
    this.question = new CoffeeQuestion(question, defaultValue: _default, allowed: T == bool ? null : allowed);
  }

  Future<T> ask() async {
    String _value = await question.ask();
    if (_value.isEmpty) {
      value = _defaultValue;
    } else {
      if (T == bool) {
        if (_value.toLowerCase() == "true" || _value.toLowerCase() == "y") {
          value = true as T;
        } else {
          value = false as T;
        }
      } else if (T == num) {
        value = num.parse(_value) as T;
      } else if (T == int) {
        value = int.parse(_value) as T;
      } else if (T == double) {
        value = double.parse(_value) as T;
      } else {
        value = _value as T;
      }

      if (allowed != null && !allowed.contains(value)) {
        throw new CoffeeException("'$value' is not Authorized");
      }
    }

    return value;
  }
}
