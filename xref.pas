(*
 * Most likely
 * here was a boilerplate
 * and a copyright notice
 * as well as a description
 * of the functionality
 * of the program.
 * As the program has been written in the DDR
 * the description was most likely
 * in German.
 * Length of the comment deduced by line numbers in the object file.
 *)
(*=p-,t-,k23*)program xref(input, output);
type ctype=(letter, digit, eot, quote, asterisk, oparen, other);
idtype=packed array[1..8] of char;
list=packed record 
    num: 0..8000000000;
    next: @list
end;
rec=record 
    name: idtype;
    next: @list;
    left, right: @rec
end;
var ch: char; cnt, lineno: integer;
SY: ctype;
curname: idtype;
title: array[1..2] of idtype;
unpacked: array[1..8] of char;
idx, idx2: integer;
idents, occurs, pagenum, pos:integer;
table: array ['A'..'_176'] of @rec;
string: array [1:72] of char;
tail: array[1:8] of char;
ctypes: array [char] of ctype;
procedure init;
var ct: ctype;
{
 cnt := 8;
 for ch := 'A' to '_176' do table[ch] := nil;
 idents := 0; occurs := 0; pagenum := 1; lineno := 0;
 tail[1] := ' '; tail[2] := '_377';
 for ch := '_000' to '_377' do {
    if (ch >= '0') and (ch <= '9') then
	 ct := digit
    else if (ch >= 'A') and (ch <= 'Z') or
            (ch >= 'Ю') and (ch <= 'Ч') then
	ct := letter
    else { ct := other; (q) exit q; };
    ctypes[ch] := ct;
 };
 ctypes['*'] := asterisk; ctypes['('] := oparen;
 ctypes['_377'] := eot; ctypes[''''] := quote;
};
procedure nextch; {
	ch := string[pos];
	SY := ctypes[ch];
        pos := pos + 1;
};
procedure report;
var curline:integer; curpage:@text; 
    first:char; listptr, unused: @list;
    str: array[1..60] of char;
    x, y: text;
procedure newpage;
procedure stars(arg: integer); var i:integer;
{ 
for i to arg do write('*'); };
{ (* newpage *)
 rewrite(x); rewrite(y); writeln; curpage := ref(y);
 stars(28); write(pagenum:3, ' ');
 stars(61); write((pagenum + 1):3, ' ');
 stars(28); writeln; writeln; pagenum := pagenum + 2; }; 
procedure printpage; {
 reset(x); curline := 0; reset(y);
 for idx to 64 do {
        read(y, str); write(str, ' ':5); read(x, str); writeln(str);
 };
 newpage; rewrite(y); rewrite(x);
};
procedure nextline; {
 curline := curline + 1;
 if curline = 64 then
	curpage := ref(x)
 else if curline = 128 then printpage;
};
procedure printlist(arg:@rec); 
var i, j: integer;
{
 write(curpage@, ' ', arg@.name, ' ');
 listptr := arg@.next; i := 1;
repeat write(curpage@, listptr@.num:5);
 listptr := listptr@.next; j := i mod 10;
 if (j = 0) then {
	nextline;
        if listptr <> NIL then write(curpage@, ' ':10);
  };
  i := i + 1;
  until (listptr = NIL);
 if j <> 0 then { write(curpage@, ' ':(10-j)*5); nextline }
};
procedure inorder(arg:@rec);
{
 if (arg <> NIL) then 
    { inorder(arg@.left); printlist(arg); inorder(arg@.right); }
};

procedure header;
{ write(' >>>', title[1], title[2]:9, '<<<') };

procedure skip(arg:integer);
{ 
    for idx2 to arg do writeln;
};

{ (* report *)
 header;
 write(idents:10, ' IDENTIFIERS ', occurs:10, ' OCCURRENCES', 
       lineno:10, ' LINES', ' ':15);
 header; skip(4); pagenum := 1; curline := 0; newpage;
 for first := 'A' to '_176' do inorder(table[first]); 
 for idx to 60 do str[idx] := ' ';
 for idx to 127 do { write(curpage@, str:60); nextline };
};

procedure readline;
{
 if eof(INPUT) then { report; halt };
 readln(string);
 pos := 1; nextch; lineno := lineno + 1;
};
procedure parse;
var stopquote: boolean; i, j: integer;
procedure skipComment;
{
  repeat
     nextch;
     if SY = eot then readline;
  until (SY = asterisk) and (string[pos] = ')');
  nextch; nextch;
};

{ (* parse *) (loop) {
while SY = other do nextch;
case SY of
quote: {
	stopquote := false;
	repeat
	    nextch;
            if SY = eot then {
 		stopquote := true;
                readline;
            } else if (SY = quote) then {
                if (ctypes[string[pos]]  = quote) then {
                    nextch;
                    nextch;
                } else {
                    stopquote := true;
                    nextch;
                }; (q) exit q
            }; 
	until stopquote;
};
asterisk: nextch;
oparen: {
 if (ctypes[string[pos]] = asterisk) then { nextch; skipComment; }
     else nextch;
};
eot:readline;
digit: {
 repeat nextch until (SY <> digit);
 if (ch = 'B') or (ch = 'C') or (ch = 'E') or (ch = 'T') then nextch;
};
letter:{ i := 1;
 repeat if i <> 9 then {
     unpacked[i] := ch; i := i + 1;
 }; nextch until (SY <> letter) and (SY <> digit);
 for j := i to cnt do unpacked[j] := ' ';
 cnt := i; pack(unpacked, 1, curname); exit
}
end; goto loop }
};

procedure process; label 1,2; var first: char; currec, prevrec: @rec;
listptr: @list; right: boolean;
procedure alloc; 
{ new(currec); idents := idents + 1; };
procedure chain;
{
 new(listptr);
 with listptr@ do { num := lineno; next := currec@.next };
 currec@.next := listptr;
};
{  (* process *)
 1: parse;
 first := unpacked[1];
 currec := table[first];
 occurs := occurs + 1;
 if (occurs <= 2) then
     title[occurs] := curname;
 if (currec = NIL) then 
    { alloc; table[first] := currec; }
 else {
 repeat
 prevrec := currec;
 right := currec@.name < curname;
 if right  then currec := currec@.right
 else if curname = currec@.name then { chain; goto 2 }
 else currec := currec@.left;
 until (currec = NIL);
 alloc;
 if right then prevrec@.right := currec
 else prevrec@.left := currec;
};
 with currec@ do{
    name := curname;
    left := nil; right := nil; next := nil
 };
chain;
2: goto 1;
};

{
    writeln(' *** PASCAL CROSSREFERENCER. 12.9.79. ***':60); 
    init; readline; process;
}.
