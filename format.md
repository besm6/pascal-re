# Relocatable object format

Relocatable objects in the "Dubna" monitor system were typically kept in one of the two forms:

- as part of a library on a magnetic medium
- as a "standard deck" of punched cards which looks like
---
    ⠀⠆⢠⠤⠤⢄⠀⠀⡠⠤⡄⠀⡠⠤⢄⠀⡠⠤⠤⡀⢀⠤⠤⢄⠀⢀⠤⠤⡀⠠⠤⡤⠤⠀⠀⠀⠀⠀⠹⠃
    ⡀⡄⢸⠤⠤⠜⠀⣎⣀⣀⡇⠀⠑⠒⢢⠀⡇⠠⠤⡄⢸⠀⠀⢸⠀⠈⠒⠒⡄⠀⠀⡇⠀⠀⠀⠀⠀⠀⢲⡇
    ⠂⡃⠘⠀⠀⠀⠀⠃⠀⠀⠃⠈⠒⠒⠊⠀⠑⠒⠒⠁⠈⠒⠒⠊⠀⠑⠒⠒⠁⠀⠀⠃⠀⠀⠀⠀⠀⠀⣤⣫
---
    ⠈⠄⠹⠃⠀⠀⠀⠀⠁⠀⠅⠀⠀⠀⠀⠀⠀⠅⠀⡁⠀⠀⠀⠠⠀⠀⠀⠀⠀⢤⡀⠏⠀⢀⠸⠂⠠⡁⠹⠃
    ⡀⠄⢲⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡁⠀⡁⠀⠀⢈⠀⢐⠀⢲⡇
    ⠂⠇⣤⣫⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⠀⡀⢰⠀⣤⣫
---
    ⠐⠂⡀⠟⠀⡈⠸⠄⢀⠺⠅⠀⠀⠀⢘⠀⠀⡇⠀⡂⠀⢨⠹⠃⠀⠇⠁⡀⠁⢐⠈⠰⠈⠀⡁⠁⢓⠀⠹⠃
    ⡀⠃⠀⡁⠀⠀⢈⠀⠀⢈⠀⠀⡄⠀⠀⠀⠀⠀⠀⠇⠀⠸⢲⡇⠀⢠⠀⢠⠀⠀⡄⠀⡄⠀⢠⢸⠦⠀⢲⡇
    ⠂⡆⡆⢀⠀⡆⠀⡀⢰⠀⡀⠀⡅⠀⠀⠀⠀⠀⠀⠀⠀⠀⣤⣫⠀⣨⠀⣨⠀⢀⡅⢀⡅⠀⣨⢠⣈⠀⣤⣫
---
    ⠘⡈⠩⣌⢑⢒⠈⠥⡊⣵⡂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⠃
    ⡀⠃⢲⣾⢺⢧⠐⣖⡔⡶⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢲⡇
    ⠂⡇⣤⣣⣤⣙⢠⣜⣤⣔⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣤⣫
---

## Obtaining an object file

Each object file can have, in addition to the main entry point at relative offset 0,
up to 19 additional externally visible entry points. They are represented in the the library catalog;
the module proper contains only the name of the main routine. The binary stream of a module,
omitting the information about additional entry points, can be extracted by running a Monitor System batch
in the BESM-6 emulator:

    *NAME
    *TABLE:LIBLIST(module_name)
    *     LU - two octal digits 30 to 67 - logical unit to which
    *          a disk with the library is attached
    *     ZZZZ - four octal digits - the starting disk block
    *LIBLIST:LUZZZZ
    *     Here LU - the logical unit to which a scratch volume is attached (e.g. 1234)
    *TO PERSONAL LIBRARY:LU0000
    *END FILE
    
There will be a line telling the length of the newly created library containing just one module as an octal number.
Then, `besmtool dump NNNN --to-file=module_name.obj --start=2 --length=0LLL`, 
where NNNN is the volume number used to run the batch,and LLL is the number reported minus 2. 
    
## Format of an object file

### Header

The first three words contain lengths of the object module blocks.

Word 0:

|  Bits 48-37 | Bits 36-25| Bits 24-13|Bits 12-1|
|-------------|-----------|-----------|---------|
|   debug     |    ???    |  symtab   |  symhdr |

Words 1-2:

| Bits 48-46 | Bits 45-31   | Bits 30-16 | Bits 15-1  |
|------------|--------------|------------|------------|
|            |   longsym    |    data    |      set   |
|            |    const     |     bss    |     insn   |

### Section order

After the header, the section order in the object is  
`insn` - `const` - `data` - `set` - `symhdr` - `symtab` - `longsym` - `debug`  
(`bss` doesn't take space in the object).
The memory footprint of the module at load time will be `insn` + `const` + `bss`.
`data` and `set` are used for initialization (they may refer to local as well as external locations as sources or targets,
and for the purpose of reference using relative offsets, the `data` section is considered to be just after the `bss` section.

### INSN section

All words in that section are subject to address modification during
linking/loading, if the address field in a word matches a "relocatable" pattern. Thus, that section will include
at least up to the last word needing relocation. The "relocatable" patterns are:

- for the "long address" instructions: 40000B to 77777B
- for the "short address" instructions: 4000B to 7777B (only the address field is considered, not the sign bit).

This ensures that most small constants can be included in the `insn` section verbatim without incurring a link time cost.

### CONST section

Copied verbatim during loading.

### BSS section

Its length indicates how many words to reserve during loading; no space in the object module is taken.

### DATA section

Not copied to the executable image; considered during processing of the `set` section.

### SET section

Each word of this section has the format

| Bits 48-37 | Bits 36-25 | Bits 24-13| Bits 12-1 |
|------------|------------|-----------|-----------|
|   length   |   source   |   count   |   target  |

`length` words starting from the word referred to by the symbol table entry `source`
are copied `count` times to the memory location referred to by the symbol table entry `target`.

### SYMHDR section

Typically contains just one word: the module name in the TEXT (modified [ECMA-1](http://wikipedia.org/wiki/ECMA-1)) encoding.

### SYMTAB section

(All references to the symbol table account for the header; as the format of the header and the symbol table proper differ,
using symtab reference numbers less than `symhdr` is nonsensical.)

As discovered so far, the meaning of symbol table entries is (all literal values are octal):

#### Literal values

|  Bits 48-24  | Bits 24-1   |
|--------------|-------------|
|   0000 0000  |  400x xxxx  |

xxxxx is an absolute address

---

|  Bits 48-24  | Bits 24-1   |
|--------------|-------------|
|   0000 0000  |  410x xxxx  |

xxxxx is a relative address

#### External names

|     Bits 48-25       |  Bits 24-1       |
|----------------------|------------------|
|   Left-aligned name  |  bit 23 not set  |

If the upper 6 bits of the word are non-zero (not a space character in the TEXT encoding),
the bits 48-25 contain a literal short name (up to 4 characters) of an external symbol.

---

|  Bits 48-25   |  Bits 24-1       |
|---------------|------------------|
|   0000 XXXX   |   bit 23 is set  |
    
If XXXX > 04000, the value of (XXXX & 03777) is the number of a symbol table entry 
(within the LONGSYM area) containing a long name 
(up to 8 characters) of an external object in the TEXT encoding. 

#### External reference types

|        Bits 24-1          |
|---------------------------|
|   4300 0000 or 6300 0000  |

This lower halfword pattern defines an external symbol that must be present in the library during linking,
typically a subroutine. Bit 23 determines whether the symbol name is short or long.

---

|        Bits 24-1           |
|----------------------------|
|   470x xxxx or 670x xxxx   |

This lower halfword pattern defines a common block in the sense of FORTRAN. `xxxxx` specifies its length. 

#### Expressions

|   Bits 48-25  |     Bits 24-1  |
|---------------|----------------|
|   0000 XXXX   |    000Y YYYY   |
    
If XXXX > 4000, this word defines a reference to an external object
referred to by the symbol table entry (XXXX & 03777) plus YYYYY.

### LONGSYM section

Contains names of external symbols that are longer than 4 characters. It is considered a part of the symbol table when referred to.

### DEBUG section

Contains names of local labels. No information about its format so far.









