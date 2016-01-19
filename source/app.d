void main() {
	auto program = BFProgram!(import("fib.b"))();
	program.execute();
}
///A brainfuck program
struct BFProgram(string program, size_t memSize = 0x1000) {
	///Just a big ol' block of memory
	char[memSize] memory = void;
	///Program data pointer
	size_t ptr = 0;

	///Compile and execute program
	void execute() {
		import std.stdio : write, readf;
		memory[] = '\0';
		mixin(transpile(program));
	}
}
///Transpile bf -> D
string transpile(string program) {
	import std.string : join;
	string[] prog;
	foreach (instruction; program) {
		switch(instruction) {
			case '+':
				prog ~= "++memory[ptr];";
				break;
			case '-':
				prog ~= "--memory[ptr];";
				break;
			case '>':
				prog ~= "++ptr;";
				break;
			case '<':
				prog ~= "--ptr;";
				break;
			case '.':
				prog ~= "write(memory[ptr]);";
				break;
			case ',':
				prog ~= `readf("%c", &memory[ptr]);`;
				break;
			case '[':
				prog ~= `while(memory[ptr] != '\0') {`;
				break;
			case ']':
				prog ~= `}`;
				break;
			default: break;
		}
	}
	return prog.join("\n");
}