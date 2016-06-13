/**
 * Created by lejard_h on 05/06/16.
 */

import "package:test/test.dart";
import "package:coffee_cli/src/execute.dart";
import "package:coffee_cli/src/coffee.dart";

testFunction1(String string) => string;

testFunction2({String string}) => string;

testFunction3(int number, {String string}) => {"string": string, "number": number};

class TestResult1 extends CoffeeResults {
  TestResult1() : super(null, null);

  Map<String, dynamic> _values = {"string": "Rennes", "number": 42, "boolean": true};

  @override
  dynamic get(String name) => _values[name];
}

main() {
  test("basic", () {
    String value = execute(testFunction1, new TestResult1());
    expect(value, "Rennes");
  });

  test("basic named args", () {
    String value = execute(testFunction2, new TestResult1());
    expect(value, "Rennes");
  });

  test("basic named args and positional", () {
    Map values = execute(testFunction3, new TestResult1());
      expect(values, {"string": "Rennes", "number": 42});
  });
}
