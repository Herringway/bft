[![Build Status](https://travis-ci.org/Herringway/bft.svg?branch=master)](https://travis-ci.org/Herringway/bft)
[![Coverage Status](https://coveralls.io/repos/Herringway/bft/badge.svg?branch=master&service=github)](https://coveralls.io/github/Herringway/bft?branch=master)
[![GitHub tag](https://img.shields.io/github/tag/herringway/bft.svg)](https://github.com/Herringway/bft)

# BFT

BFT is a BrainFuck Transpiler. BFT translates brainfuck code to native (but ugly) D code during compile-time.

This translated code may also be executed at compile-time, but requires a heavy amount of memory for anything non-trivial.

## Requirements

- dmd, ldc or gdc
- A generous amount of memory.

## Example

```D
import std.array;
import bft;

auto program = BFProgram!("++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.", 7)();
auto outbuf = appender!(char[])();
program.execute("", outbuf);
assert(outbuf.data == "Hello World!\n");
```

[Documentation](http://herringway.github.io/bft/)