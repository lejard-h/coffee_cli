// Copyright (c) 2016, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:coffee_cli/coffee_cli.dart';

int helloworld(Map<String, CoffeeParameter> params) {
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
  return 0;
}

CoffeeCommand get helloCommandWho => new CoffeeCommand("who", helloworld, parameters: [
  new CoffeeStringParameter("name",  help: "Use you name", question: "What is your Name ?"),
  new CoffeeBoolParameter("uppercase", help: "Big Hello World", question: "Do you want to use uppercase ?", defaultValue: false),
  new CoffeeStringParameter("style",
      help: "Style",
      question: "What kind of style ?",
      allowed: ["CamelCase", "snake_case"])
]);

CoffeeCommand get helloWorldCommand =>  new CoffeeCommand("world", helloworld);


CoffeeCommand get helloCommand => new  CoffeeCommand("hello", null, commands: [
  helloWorldCommand,
  helloCommandWho
]);

main(List<String> args) {
  return new CoffeeCli([ helloCommand]).execute(args);
}
