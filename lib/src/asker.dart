import 'dart:isolate';
import "dart:io";
import "dart:async";
import "utils.dart";
import 'package:console/console.dart';

class AskerWindow {
	final String question;
	final List allowed;

	Completer<String> _completer = new Completer<String>();

	String _response;
	Future<String> get response => _completer.future;
	int _selected;
	bool _init = false;

	AskerWindow(this.question, this.allowed) {
		stdin.echoMode = false;
		initialize();
		Console.onResize.listen((_) {
			draw();
		});
	}

	close() {
		Console.showCursor();
		stdin.echoMode = true;
	}

	bool _cursorCTRLC = false;

	void hideCursor() {
		if (!_cursorCTRLC) {
			ProcessSignal.SIGINT.watch().listen((signal) {
				close();
				exit(0);
			});
			_cursorCTRLC = true;
		}
		Console.writeANSI("?25l");
	}



	void draw() {
		if (_init) {
			Console.moveCursorUp(allowed.length + 1);
		}
		Console.overwriteLine(outputGray("$question\n", level: 0.5));
		if (_selected == null) {
			_selected = 0;
		}
		for (String name in allowed) {
			if (allowed[_selected] == name) {
				Console.overwriteLine("\t${outputGray(">", level: 0.5)} ${outputGreen(name)}\n");
			} else {
				Console.overwriteLine("\t  ${outputBlue(name)}\n");
			}
		}


	}

	//@override
	void initialize() {
		hideCursor();
		Keyboard.bindKey("up").listen((_) {
			Console.resetAll();
			_selected = (_selected + allowed.length - 1) % allowed.length;
			draw();
		});

		Keyboard.bindKey("down").listen((_) {
			Console.resetAll();
			_selected = (_selected + 1) % allowed.length;
			draw();
		});

		Keyboard.bindKey("\n").listen((_) {
			close();
			_response = allowed[_selected];
			_completer.complete(_response);
		});
	}

	display() {
		draw();
		_init = true;
	}
}

main(List<String> args, SendPort replyTo) async {
	String question = args[0];
	List allowed = args[1].split(";");

	AskerWindow window = new AskerWindow(question, allowed);
	window.display();

	String result = await window.response;
	replyTo.send(result);
}