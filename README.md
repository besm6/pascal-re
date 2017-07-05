# pascal-re
Reverse engineering of the Pascal-Monitor compiler

## Goal
The goal of this project is to recreate the source code of the Pascal
compiler included in the "Dubna" monitor system ("Pascal-Monitor").

### Method

#### Selecting the binary

When the Pascal compiler is selected with the `*PASCAL` command,
the pre-linked overlay is used which would be cumbersome to reverse.

Luckily, an object file of the compiler, which prints the same build date
as the overlay, is included in one of the copies of the runtime library.

The object file has been extracted by copying it to a fresh library on a fresh
volume, then performing a binary dump starting from the known place and using
the block count reported by the library creation process.

#### Validating the process

Before starting to decompile, it is worth trying to disassemble the binary first.

A disassembler (`DTRAN`) exists in the system, but the object file of the compiler
is too large for it; a warning message about a possible failure is printed, and
the process terminates with the partial assembly code left on
a scratch medium (a magnetic drum). Extracting it reveals that the disassembly
process works reliably up to the code section offset 020000 (in words),
whereas the code section length is 024155.

The source code of the dissassembler contains a comment describing the structure
of the header of an object file but not of the symbol table.
This allowed to bootstrap writing a disassembler in C++
which could handle only the symbol table records used in the object file under analysis,
without a clear understanding of the semantics of various bit flags in the symbol table.

This process yielded an assembly code that essentially matches the output of `DTRAN` as far
as it is reliable. The remaining part of the code section disassembled uneventfully;
the constant data section was first dumped in octal for simplicity (recognizing integers and character literals
in ISO and ECMA-1 encodings was added later); the variable initialization section
required some experimentation with `DTRAN` run on compiled FORTRAN programs with `DATA` operators
but proved to be straightforward enough.

The resulting assembly file was accepted by the assembler `*MADLEN` but contained too many
symbols. After all labels within the code section were thrown out and all references to them
replaced with an equivalent of `START+offset`, the code compiled and the resulting object file
was able to link and to compile a small Pascal program.
