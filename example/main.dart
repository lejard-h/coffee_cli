// Copyright (c) 2016, <your name>. All rights reserved. Use of this source code

// is governed by a BSD-style license that can be found in the LICENSE file.
import 'package:coffee_cli/coffee_cli.dart';

class PolymerElementGenerator extends CoffeeCli {
  static const _cliHelp = "Polyce element, create and manage Polymer Elements.";
  static const _nameHelp = "Name of your element";
  static const _outputHelp = "Where would you like to create this element";
  static const _autonotifyHelp = "Whould you like to use polymer_autonotify";

  static CoffeeQuestion _questionOutputElement(CoffeeQuestion original) {
    return new CoffeeQuestion(_outputHelp, defaultValue: "./");
  }

  @CoffeeCommand()
  void create(@CoffeeParameter(help: _nameHelp, question: _nameHelp) String name,
      {@CoffeeParameter(help: _outputHelp, defineQuestion: _questionOutputElement) String output,
      @CoffeeParameter(help: _outputHelp, question: _autonotifyHelp) bool autonotify: true}) {
    print(name);
  }

  @override
  usage() {
    print(outputGray(_cliHelp, level: 0.5));
    super.usage();
  }
}

class PolyceCli extends CoffeeCli {
  @CoffeeCommand(help: "Element command usage")
  CoffeeCli element = new PolymerElementGenerator();

  @CoffeeCommand(help: "Init command usage")
  void init() {}

  @CoffeeCommand(help: "Toto command usage")
  void toto(@CoffeeParameter(allowed: const ["truc", "titi", "tata"]) String test) {}

  @override
  usage() {
    print(outputGray("Polyce cli, create and manage Polymer Dart Application.", level: 0.5));
    super.usage();
  }
}

testFunction(String value, @CoffeeParameter(defaultValue: 42.42) double otherValue) {
  print(value);
  print(otherValue);
}

main(List<String> args) {
  return new PolyceCli().execute(args);
}
