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

main(List<String> args) {
  CoffeeCli cli = new CoffeeCli("My Cli", [
    new CoffeeCommand("hello", helloworld, parameters: [
      new CoffeeStringParameter("name",
          isOptional: false, description: "Use you name", question: "What is your Name ?"),
      new CoffeeBoolParameter("uppercase",
          isOptional: false, description: "Big Hello World", question: "Do you want to use uppercase ?"),
      new CoffeeStringParameter("style",
          isOptional: true,
          description: "Style",
          question: "What kind of style ?",
          possibleValues: ["CamelCase", "snake_case"])
    ])
  ]);

  return cli.execute(args);
}