# coffee_cli

Easy way to create interactive command line application.

- Parameter your cli with automatic usage
- Ask question to user, with defautValue and allowed value parametrable
- termcaps interaction for choice of allowed parameter


## Usage

#### Import

```dart
import 'package:coffee_cli/coffee_cli.dart';
```

2 differents usage

### Extends `CoffeeCli` class

```dart
class MyCli extends CoffeeCli {
  @CoffeeCommand(help: "Command usage")
  void command(String value, @CoffeeParameter(defaultValue: 42.42) double otherValue) {
    print(value);
    print(otherValue);
  }
  
  @CoffeeCommand(help: "Command usage")
  void otherCommand(@CoffeeParameter(allowed: const ["foo", "bar", "42"]) String value) {
    print(value);
  }

  @override
  usage() {
    print(outputGray("My awesome cli.", level: 0.5));
    super.usage();
  }
}
```

```dart
main(List<String> args) {
  return new MyCli().execute(args);
}
```

### Use `addCommand` function

#### Define a function to call
```dart
myFunction(String value, @CoffeeParameter(defaultValue: 42.42) double otherValue) {
  print(value);
  print(otherValue);
}
```

#### Define the cli

```dart
main(List<String> args) {
 return new CoffeeCli()
    ..addCommand("command", const CoffeeCommand(function: myFunction))
    ..execute(args);
}
```

## [Example](https://github.com/lejard-h/coffee_cli/tree/master/example)

## Fork of [cupid](https://github.com/dart-bridge/cupid)