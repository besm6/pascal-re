(*=p-,t-,s8*)
program topult(input, output, isopgost, result);
var 
isopgost: packed array ['_000'..'_177'] of char;
result:text;
unused, syms, i, j, lines:integer;
map:array ['_000'..'_177'] of char;
unpline:array[1..80] of char;
pckline:packed array[1..80] of char;
procedure PASISOCD; external;
_(
unpack(isopgost, map, '_000');
 PASISOCD;
 rewrite(RESULT);
 lines := (0);
 syms := (0);
 map[''''] := chr(33B);
while not eof(input) do _(
readln(pckline);
unpack(pckline, unpline, 1);
i := 72;
 while (unpline[i] = ' ') and (0 < i) do
   i := i - 1;

for j := 1 to i do _(
 write(result, map[unpline[j]]);
 syms := syms + 1;
_);
write(result, chr(175B));
lines := lines + 1;
_);
 write(result, chr(172B), chr(175B) );
 writeln(' TO RESULT HAS WRITTEN ', lines:0, ' LINES (',
     syms:0, ' SYMBOLS ', 
     syms div 6144 + 1:0, ' TRACKS)');
_).
