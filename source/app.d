import bft;
void main() {
	auto program = BFProgram!(import("mandel.b"))();
	program.execute();
}