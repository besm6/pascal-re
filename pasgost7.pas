(*=p-,t-,s8*)
program pasgost7(output, input 27270000B, lgo 27270000B);
var lgo:file of alfa;
ch: char; i, j: integer;
word: alfa;
map: array[char] of char;
glob299z: integer;
unpWord: array [1..6] of char;
procedure pasgost;external;
procedure initMap;
var c1, c2, c3:char;
{
 c1 := '_377';
 c2 := '_201';
 c3 := '_177';
 for ch := '_000' to '_377' do
     map[ch] := ch;
 map['_175'] := '_012';
 map['_172'] := '_003';
 (*=a1*)map['0'] := (*=a2*)'0';
 (*=a1*)map['1'] := (*=a2*)'1';
 (*=a1*)map['2'] := (*=a2*)'2';
 (*=a1*)map['3'] := (*=a2*)'3';
 (*=a1*)map['4'] := (*=a2*)'4';
 (*=a1*)map['5'] := (*=a2*)'5';
 (*=a1*)map['6'] := (*=a2*)'6';
 (*=a1*)map['7'] := (*=a2*)'7';
 (*=a1*)map['8'] := (*=a2*)'8';
 (*=a1*)map['9'] := (*=a2*)'9';
 (*=a1*)map['+'] := (*=a2*)'+';
 (*=a1*)map['-'] := (*=a2*)'-';
 (*=a1*)map['/'] := (*=a2*)'/';
 (*=a1*)map[','] := (*=a2*)',';
 (*=a1*)map['.'] := (*=a2*)'.';
 (*=a1*)map[' '] := (*=a2*)' ';
 map['_020'] := '_027';
 map['_021'] := '^';
 (*=a1*)map['('] := (*=a2*)'(';
 (*=a1*)map[')'] := (*=a2*)')';
 map['_024'] := '_006';
 (*=a1*)map['='] := (*=a2*)'=';
 (*=a1*)map[';'] := (*=a2*)';';
 (*=a1*)map['['] := (*=a2*)'[';
 (*=a1*)map[']'] := (*=a2*)']';
 (*=a1*)map['*'] := (*=a2*)'*';
 map['_032'] := '_047';
 map['_033'] := '_047';
 map['_034'] := '_030';
 (*=a1*)map['<'] := (*=a2*)'<';
 (*=a1*)map['>'] := (*=a2*)'>';
 (*=a1*)map[':'] := (*=a2*)':';
 (*=a1*)map['A'] := (*=a2*)'A';
 (*=a1*)map['Б'] := (*=a2*)'Б';
 (*=a1*)map['В'] := (*=a2*)'В';
 (*=a1*)map['Г'] := (*=a2*)'Г';
 (*=a1*)map['Д'] := (*=a2*)'Д';
 (*=a1*)map['Е'] := (*=a2*)'Е';
 (*=a1*)map['Ж'] := (*=a2*)'Ж';
 (*=a1*)map['З'] := (*=a2*)'З';
 (*=a1*)map['И'] := (*=a2*)'И';
 (*=a1*)map['Й'] := (*=a2*)'Й';
 (*=a1*)map['К'] := (*=a2*)'К';
 (*=a1*)map['Л'] := (*=a2*)'Л';
 (*=a1*)map['М'] := (*=a2*)'М';
 (*=a1*)map['Н'] := (*=a2*)'Н';
 (*=a1*)map['О'] := (*=a2*)'О';
 (*=a1*)map['П'] := (*=a2*)'П';
 (*=a1*)map['Р'] := (*=a2*)'Р';  
 (*=a1*)map['С'] := (*=a2*)'С';  
 (*=a1*)map['Т'] := (*=a2*)'Т';  
 (*=a1*)map['У'] := (*=a2*)'У';  
 (*=a1*)map['Ф'] := (*=a2*)'Ф';  
 (*=a1*)map['Х'] := '_150';  (* ?? *)
 (*=a1*)map['Ц'] := (*=a2*)'Ц';
 (*=a1*)map['Ч'] := (*=a2*)'Ч';
 (*=a1*)map['Ш'] := (*=a2*)'Ш';
 (*=a1*)map['Щ'] := (*=a2*)'Щ';
 (*=a1*)map['Ы'] := (*=a2*)'Ы';
 (*=a1*)map['Ь'] := (*=a2*)'Ь';
 (*=a1*)map['Э'] := (*=a2*)'Э';
 (*=a1*)map['Ю'] := (*=a2*)'Ю';
 (*=a1*)map['Я'] := (*=a2*)'Я';
 (*=a1*)map['D'] := (*=a2*)'D';
 (*=a1*)map['F'] := (*=a2*)'F';
 (*=a1*)map['G'] := (*=a2*)'G';
 (*=a1*)map['I'] := (*=a2*)'I';
 (*=a1*)map['J'] := (*=a2*)'J';
 (*=a1*)map['L'] := (*=a2*)'L';
 (*=a1*)map['N'] := (*=a2*)'N';
 (*=a1*)map['Q'] := (*=a2*)'Q';
 (*=a1*)map['R'] := (*=a2*)'R';
 (*=a1*)map['S'] := (*=a2*)'S';
 (*=a1*)map['U'] := (*=a2*)'U';
 (*=a1*)map['V'] := (*=a2*)'V';
 (*=a1*)map['W'] := (*=a2*)'W';
 (*=a1*)map['Z'] := (*=a2*)'Z';
 map['_115'] := '^';
 map['_116'] := 'F'; (* <= *)
 map['_117'] := 'G'; (* >= *)
 map['_120'] := '_036';
 map['_121'] := '_046';
 map['_122'] := '_034';
 map['_123'] := '_037';
 map['_124'] := '_032';
 map['_125'] := '_035';
 map['_126'] := '_045';
 map['_127'] := '_044';
 map['_130'] := '_041';
 map['_131'] := '_025';
 map['_132'] := '_';
 map['_133'] := '_041';
 map['_134'] := '_042';
 map['_135'] := '_005';
 map['_136'] := '_031';
 map['_137'] := '_036';
%  c1 := c1;
};
procedure doChar;
{
    unpWord[i] := map[ch];
    if i = 6 then {
        pck(unpWord[1], word);
        lgo@ := word;
        put(lgo);
        i := 1;
    } else {
        i := i + 1;
    }
};
procedure FLUSH;
var l2var1z:integer;
{
    for l2var1z to 7 do doChar;
};

{
 j := 0;
 initMap;
 map['_175'] := '_012';
 map['_172'] := '_003';
 i := 1;
 PASGOST;
 rewrite(LGO);
 (loop) {
     ch := input@;
     get(INPUT);
     doChar;
     if (ch = '_172') then {
         (*=a1*)writeln('RECODING FINAL');
         FLUSH;
         exit loop
     } else goto loop
 }
}.
