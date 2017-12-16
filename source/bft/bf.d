///A brainfuck implementation that uses transpiling to produce native machine code.
module bft.bf;

import std.range : ElementType, isInputRange, isOutputRange;
import std.traits : isSomeString;
struct StdInput {
	import std.stdio : stdin;
	char lastRead;
	bool empty() { return stdin.isOpen; }
	char front() { return lastRead; }
	void popFront() { if (stdin.rawRead([lastRead]).length == 0) stdin.close(); }
}
///A brainfuck program
struct BFProgram(string program, size_t memSize = 8192) {
	///Just a big ol' block of memory
	char[memSize] memory = void;
	///Program data pointer
	size_t ptr = 0;

	///Compile and execute program
	void execute() {
		import std.stdio : stdout;
		auto inp = StdInput();
		auto outp = stdout.lockingTextWriter;
		execute(inp, outp);
	}
	///ditto
	void execute(Input, Output)(Input stdin, Output stdout) if (isInputRange!Input && !isSomeString!Input && is(ElementType!Input : char) && isOutputRange!(Output, char)) {
		import std.range : put;
		import std.algorithm : copy;
		memory[] = '\0';
		mixin(transpile(program));
	}
	///ditto
	void execute(Input, Output)(Input stdin, Output stdout) if (isSomeString!Input && isOutputRange!(Output, char)) {
		import std.utf : byCodeUnit;
		execute(stdin.byCodeUnit, stdout);
	}
}
///Transpile bf -> D
string transpile(string program) pure @safe {
	import std.string : join, format;
	import std.algorithm : group;
	import std.range : repeat;
	import std.array : array;
	string[] prog;
	foreach (instruction, count; program.group) {
		switch(instruction) {
			case '+':
				prog ~= format("memory[ptr] += %d;", count);
				break;
			case '-':
				prog ~= format("memory[ptr] -= %d;", count);
				break;
			case '>':
				prog ~= format("ptr += %d;", count);
				break;
			case '<':
				prog ~= format("ptr -= %d;", count);
				break;
			case '.':
				prog ~= "copy([memory[ptr]], stdout);".repeat(count).array;
				break;
			case ',':
				prog ~= `if (!stdin.empty) { memory[ptr] = stdin.front; stdin.popFront(); }`.repeat(count).array;
				break;
			case '[':
				prog ~= `while(memory[ptr] != '\0') {`.repeat(count).array;
				break;
			case ']':
				prog ~= `}`.repeat(count).array;
				break;
			default: break;
		}
	}
	return prog.join("\n");
}
///
unittest {
	import std.array : appender;
	{
		auto program = BFProgram!(import("helloworld.b"), 7)();
		auto outbuf = appender!(char[])();
		program.execute("", outbuf);
		assert(outbuf.data == "Hello World!\n");
	}
	{
		auto program = BFProgram!(import("bench.b"), 8)();
		auto outbuf = appender!(char[])();
		program.execute("", outbuf);
		assert(outbuf.data == "ZYXWVUTSRQPONMLKJIHGFEDCBA\n");
	}
	{
		auto program = BFProgram!(import("rot13.b"), 8)();
		auto outbuf = appender!(char[])();
		string inbuf = "HELLO";
		program.execute(inbuf, outbuf);
		assert(outbuf.data == "URYYB");
	}
	{
		import std.algorithm : splitter, filter;
		import std.uni : isWhite;
		import std.array : array;
		import std.utf : toUTF8;
		auto program = BFProgram!(import("392quine.b"), 1024)();
		auto outbuf = appender!(char[])();
		program.execute("", outbuf);
		assert(outbuf.data == import("392quine.b").splitter("\x1A").front.filter!(x => !x.isWhite).array.toUTF8~"\x1A");
	}
}