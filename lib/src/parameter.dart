import "question.dart";

typedef CoffeeQuestion QuestionFactory(CoffeeQuestion original);

class CoffeeParameter {
	final String name;
	final String question;
	final List allowed;
	final dynamic defaultValue;
	final String help;
	final QuestionFactory defineQuestion;

	const CoffeeParameter({this.name, this.question, this.allowed, this.defaultValue, this.help, this.defineQuestion});
}