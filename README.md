# coffee_cli

Easy way to create interactive command line application

## Usage

```dart
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
          isOptional: false, help: "Use you name", question: "What is your Name ?"),
      new CoffeeBoolParameter("uppercase",
          isOptional: false, help: "Big Hello World", question: "Do you want to use uppercase ?"),
      new CoffeeStringParameter("style",
          isOptional: true,
          help: "Style",
          question: "What kind of style ?",
          possibleValues: ["CamelCase", "snake_case"])
    ])
  ]);

  return cli.execute(args);
}

```