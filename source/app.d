import bf;
void main() {
	auto program = BFProgram!(import("mandel.b"))();
	program.execute();
}