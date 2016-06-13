import 'parameter.dart';

class CoffeeCommand {
	final String name;
	final String help;
	final Map<String, CoffeeParameter> options;
	final Function function;

	const CoffeeCommand({this.name, this.help, this.options, this.function});
}
