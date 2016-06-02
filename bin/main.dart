// Copyright (c) 2016, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:coffee_cli/coffee_cli.dart';

void helloworld(Map<String, CoffeeParameter> params) {
  String hello;
  if (params.containsKey("name")) {
    hello = "Hello ${params["name"].value} !";
  } else {
    hello = "Hello World !";
  }
  if (params.containsKey("style")) {
    if (params["style"].value == "CamelCase") {
      hello = hello.split(" ").join("");
    }
    if (params["style"].value == "snake_case") {
      hello = hello.replaceAll(" ", "_");
    }
  }
  if (params.containsKey("uppercase") && params["uppercase"].value) {
    print(hello.toUpperCase());
  } else {
    print(hello);
  }
}

CoffeeCommand get helloCommand => new  CoffeeCommand("hello", helloworld);
CoffeeCommand get helloWorldCommand =>  new CoffeeCommand("world", helloworld, parameters: [
  new CoffeeStringParameter("name",  help: "Use you name", question: "What is your Name ?"),
  new CoffeeBoolParameter("uppercase", help: "Big Hello World", question: "Do you want to use uppercase ?", defaultValue: false),
  new CoffeeStringParameter("style",
      help: "Style",
      question: "What kind of style ?",
      allowed: ["CamelCase", "snake_case"])
]);
CoffeeCommand get helloCommandComplex => new CoffeeCommand("complex", helloworld, commands: [ helloWorldCommand]);

main(List<String> args) {
  return new CoffeeCli([ helloCommand, helloCommandComplex, helloWorldCommand]).execute(args);
}
