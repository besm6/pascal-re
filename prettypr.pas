(*=p-,t-,y+*)
program prettypr(output, input, result);
label 3575;
const boilerplate = '*** VERSION 25.02.82 ***';
type
    bool3=record f0, f1, expand: boolean end;
keyword=(k0, k1, kif, kthen, kelse, kcase, kof, krepeat, kuntil, kwhile,
kdo,kfor,kbegin, kend, kwith, kselect, kgoto, kexit, kconst,kvar,
ktype,krecord,klabel,karray,kset,kfile,kpacked,kfunct,kproced, kfortran,
kextern, kforward, kprogram, klast);
var result:text;
line:array [1..84] of char;
errline:array [1..80] of char;
varskip:array[204..261] of char;
errpos, errlnum:integer;
varskip2:array[264..270] of char;
longLines:boolean; glob272z, glob273z:alfa;
garr273z:array[1..72] of char;
glob346z,
glob347z, glob348z:integer;
glob349z:char;
initMode,curmode:bool3;
glob356z:boolean; glob357z, glob358z, glob359z:integer;
glob360z:boolean;
garr360z:array [1..50] of integer;
pos, glob412z:integer;
ch, nextch:char;
unp: array [1..12] of char;
pck1, pck2: alfa;
keywrd1:array [kif..klast] of alfa;
keywrd2:array [kfunct..kprogram] of alfa;
SY:keyword;
inComment, glob469z:boolean;
glob470z, glob471z:integer; glob472z: boolean;
vartail:array [473..486] of char;
glob487z, glob488z:integer;
glob489z, atEOF, eol:boolean;
comMeta,meta:char;
glob494z:integer; first: boolean;

procedure PASENDED(var f: text); external;
(*line 145*) function isdigit(c:char):boolean; {
  isdigit := ('0' <= c) and (c <= '9');
};
(*line 148*) function isletter(c:char):boolean; {
  isletter := (('A' <= c) and (c <= 'Z')) or
              (('Ю' <= c) and (c <= 'Ч'));
};
procedure setMode(i:integer; var l:bool3);
(*line 153*) {
  case i of
  0: { l.f0 := false;
       l.f1 := false;
     };
  1: l.f0 := true;
  2: { l.f0 := true;
       l.f1 := true
     };
  3: l.expand := true;
  4: l.expand := false
  end
};
procedure outLine;
var l1, l2: integer;
    l3: char;
procedure P0104;
(*line 170*) { 
  if l2 <> 0 then {
  write(result, chr(128+l2)); l2 := 0
  }
};
(*line 172, outLine*) {
 for l1 := 73 to 83 do line[l1] := ' ';
 l1 := 1; l2 := 0;
 repeat
   l3 := line[l1];
   if (l3  = ' ') then l2 := l2 + 1
   else {
     P0104; write(result, l3);
   };
   l1 := l1 + 1;
 until l1 >= 84;
 P0104;
 writeLN(result); PASENDED(RESULT);
};
procedure printErr;
var l2var1z:integer;
(*line 183*) {
 write( ' ' );
 for l2var1z := 1 to errpos do 
    write( errline[l2var1z] );
 write( '<--' );
 for l2var1z := errpos + 1 to 80 do
    write( ' ' );
 write(' ***LINE', errlnum:4, '*** ');
};
procedure P0301;
var l2var1z:integer; l2var2z:boolean; l2var3z:integer;
procedure P0203;
var l3var1z, l3var2z, l3var3z:integer;
{
  if curmode.f1 and (72 - glob348z + 1 < glob359z) then {
     glob359z := 72 - glob348z + 1;
     if glob357z < glob359z then glob359z := glob357z;
  };
  l3var2z := glob359z - 1;
  for l3var1z := 1 to l3var2z do {
    line[l3var1z] := ' ';
  };
  l3var3z := glob359z + glob348z - 1;
  for l3var1z := glob359z to l3var3z do {
     line[l3var1z] := garr273z[l3var1z-glob359z+1];
  };
  for l3var1z := glob359z + glob348z to 72 do 
     line[l3var1z] := ' ';
  outLine;
  glob359z := glob358z;
  glob357z := glob359z;
  errlnum := errlnum + 1;
};
procedure P0253;
{
 if not inComment then {
   printErr;
   writeln('SYNT. UNIT OVER EOLN');
 }
};
procedure P0265(var a:integer);
var i:integer;
{
 i := a - glob348z;
 if i > 0 then
    a := i
 else a := 0;
};

{ (* P0301 *)
 if (glob348z > 0) then {
   if glob469z and (glob348z = glob347z) then P0253;
   P0203;
   repeat 
     l2var2z := true;
     if (glob348z < glob347z) and
      (garr273z[glob348z+1] = ' ') then {
      glob348z := glob348z + 1;
      l2var2z := false;
     }
   until l2var2z;
   l2var3z := glob347z - glob348z;
   for l2var1z := 1 to l2var3z do {
     garr273z[l2var1z] := garr273z[glob348z+l2var1z];
   };
   P0265( glob347z );
   P0265( glob346z );
   glob348z := -73;
   glob360z := true;
 }
};

procedure P0344;
var l2var1z:integer;
{
 if (glob347z <= 0) and (ch = ' ') and curmode.f0 then exit;
 glob347z := glob347z + 1;
 garr273z[glob347z] := ch;
 (L0357) if 72 - glob359z < glob347z then {
   if curmode.f1 then {
   if (0 < glob346z) and (glob346z < glob348z) then
    glob348z := glob346z;
   if 50 - glob357z < glob348z then {
    P0301;
    goto L0357;
   };
   if 1 < glob359z then {
    glob359z := glob359z - 1;
    goto L0357;
   };
 if 0 >= glob348z then {
   if not inComment then {
     printErr;
     writeln('TOO LONG SYNT. UNIT');
   };
   glob348z := glob347z;
 };
 P0301;
} else {
 for l2var1z := 1 to errpos do 
   garr273z[l2var1z] := errline[l2var1z];
 glob347z := errpos;
 glob348z := glob347z;
 glob359z := 1;
 }
 }
};
procedure getch(var l2arg1z:char);
var l2var1z, l2var2z: integer;
{
  if atEOF then {
    writeln('0***** EOF BEFORE END OF PROGRAM');
    GOTO 3575;
  };
  l2arg1z := INPUT@;
 if eol then
 errpos := 1
else
 errpos := errpos + 1;

 eol := eoln(INPUT );
 atEOF := eof(INPUT );
if not atEOF then get(INPUT );

 if (l2arg1z = '''') then {
 if (l2arg1z = glob349z) then {
 l2arg1z := '''';
 } else {
 glob349z := l2arg1z;
 l2arg1z := '''';
 };
 } else {
 if (eol ) then  l2arg1z := ' ';
 };
 errline[errpos] := l2arg1z;
};
procedure P0503;
var l2var1z:integer;
procedure P0470;
{
  if not curmode.f1 and (glob347z = 0) then {
   glob347z := 1;
   garr273z[1] := ' ';
  };
  glob348z := glob347z;
  P0301;
};
{ (* P0503 *)
if longLines then {
 if eol then {
   P0470;
   getch( nextch );
 };
 } else  if 72 < errpos then {
   line[73] := nextch;
   for l2var1z := 74 to 80 do
     getch( line[l2var1z] );
   P0470;
   repeat  getch( nextch ) until eol;
   getch( nextch );
 };
 ch := nextch;
 P0344;
 getch( nextch );
};
procedure P0543;
{
if (curmode.f1 and not glob360z) then P0301
};
procedure Indent;
var i: integer;
{
  i := glob357z + glob347z - glob412z;
 if 50 >= i then {
   glob358z := i;
 } else {
   glob358z := 50;
 };
 garr360z[pos] := glob358z;
 pos := pos + 1;
 glob412z := 0;
};
procedure Dindent;
{
 pos := pos - 1;
 glob358z := garr360z[pos-1];
 if glob360z then {
 glob357z := glob358z;
 glob359z := glob357z;
 }
};
procedure P0605;
{
if 0 < glob347z then {
 glob347z := glob347z - 1;
 if glob347z < glob348z then  glob348z := glob347z;
}
};
procedure token;
label 1322;
var l2var1z:boolean;
procedure P0617;
{
if glob347z = 0 then {
 printErr;
 writeln('F3 OR =U- ERROR');
 } else 
   P0605;
};
procedure doBegin;
{
if curmode.expand and (ch = '(') then {
 P0617; P0617;
 ch := 'B'; P0344;
 ch := 'E'; P0344;
 ch := 'G'; P0344;
 ch := 'I'; P0344;
 ch := 'N'; P0344;
 ch := ' '; P0344;
 }
};
procedure doEnd;
{
if curmode.expand and (ch = ')') then {
 P0617; P0617;
 ch := ' '; P0344;
 ch := 'E'; P0344;
 ch := 'N'; P0344;
 ch := 'D'; P0344;
 P0543;
 glob348z := glob347z;
}
};
procedure matchKeyword;
var l3var1z:boolean;
{
pck(unp[1], pck1);
pck(unp[7], pck2);
repeat
SY := succ(SY);
 l3var1z := keywrd1[SY] = pck1;
 if l3var1z and (ord(SY) >= 27) then 
  l3var1z := keywrd2[SY] = pck2;
until l3var1z or (SY = klast);
};
procedure getIdent;
var l3var1z:integer;
{
if ord(ch) = 88 then ch := 'X';
 unp[1] := ch;
 for l3var1z := 2 to 8 do 
    unp[l3var1z] := ' ';
 l3var1z := 1;
 while isLetter (nextch) or isDigit (nextch) do {
   P0503;
   if l3var1z < 8 then {
     l3var1z := l3var1z + 1;
     if ord(ch) = 88 then  ch := 'X';
     unp[l3var1z] := ch;
   }
 }
};
procedure doComment;
var l3var1z:integer; good:boolean;
procedure getAttr(var l4arg1z:integer; l4arg2z: char);
{
 P0503;
 if (ch >= '0') and (ch <= l4arg2z) then {
  l4arg1z := ord(ch) - ord('0');
  good := true;
 }
};
procedure P1026(var l4arg1z:boolean);
{
 P0503;
 if (ch = '-') or (ch = '+') then {
 l4arg1z := ch = '+';
 good := true;
}
};
{ (* doComment *) 
 glob469z := true; inComment := true;
 P0503; P0503;
 if (ch = comMeta) or (ch = '=') then repeat
 P0503;
 good := false;
 case (ch) of
 (* 1067*) 'F': {
   getAttr(l3var1z, '4');
   if (good) then setMode(l3var1z, curmode)
   else if (ch = 'S') then {
   good := true;
   curmode := initMode;
   }
 };
 (* 1107 *) 'U': {
   P1026( longLines );
   longLines := not longLines;
   if longLines then {
     setMode (2, curmode );
     P0617;
     ch := '+';
     P0344;
   }
 };
 (* 1124*) 'A': {
   getAttr(l3var1z, '3' );
   printErr;
   writeln('PSEUDOCOMM. A', ch);
 };
 (* 1135 *) 'J': {
   P0503;
   meta := ch;
   good := true;
 };
 (* 1142*)'B','C','E','I','K','L','M','N',
          'P','R','S','T','Y','Z','Г': {
   P0503;
   good := true;
 }
 end;
 if good then P0503
 else {
   printErr;
   writeln('ERROR IN PSEUDOCOMMENT');
 };
 until ch <> ',';
 repeat while ch <> '*' do P0503; P0503 until ch = ')';
 glob469z := false;
 inComment := false;
 glob348z := glob347z;
 glob360z := false;
 l2var1z := true;
};
procedure P1220;
{
 while isDigit (nextch) do P0503;
 if isLetter (nextch) or (nextch = '.') then  P0503;
 SY := k0;
};
procedure doChar;
{
 glob469z := true;
 (loop) repeat
 P0503;
 if (ch = '''') and (nextch = '''') then {
   P0503;
   ch := ' ';
   if (nextch = ']') or (nextch = ';') then exit loop;
 }
 until ch = '''';
 glob349z := '_000';
 glob469z := false;
};
{ (* token *)
 glob360z := false;
 glob348z := glob347z;
 l2var1z := true;
 while l2var1z do {
 P0503;
 l2var1z := ch = ' ';
 if l2var1z and curmode.f0 then {
 if glob356z then 
    P0605
  else
   glob356z := true;
 } else if (ch = '(') and (nextch = '*') then {
   doComment;
 } else {
   SY := k1;
   if isLetter( ch) then {
   1322:
    getIdent;
    matchKeyword;
   } else if ch = meta then {
     P0503;
     if isLetter( ch) then goto 1322;
     if ch = '(' then {
       SY := kbegin;
       doBegin;
     } else if ch = ')' then {
       SY := kend;
       doEnd; (q) exit q;
     }; 
   }  else if isDigit( ch) then P1220
     else if (ch = '''') then { doChar; (q) exit q }
 };
}; (* while *)
 glob356z := false;
 if ch = ';' then {
 glob348z := glob347z;
 glob346z := glob347z;
 } else if (SY = kend) and (ch <> ')') then {
   P0543;
   glob348z := glob347z;
 } else if ch = ',' then {
   glob348z := glob347z;
 }
};
procedure P1405;
var l2var1z:integer;
function atEOL:boolean;
{
 if longLines then atEOL := eol else
 if errpos > 72 then atEOL := true else atEOL := false;
};
{ (* 1405 *)
 setMode(0, curmode );
 glob359z := 1;
 glob348z := glob347z;
 while not atEOL do {
   glob348z := glob347z;
   P0503;
 };
 if longLines then {
   P0301;
 } else {
 line[73] := nextch;
 for l2var1z := 74 to 80 do 
   getch( line[l2var1z] );
 P0301;
 repeat 
   getch( nextch );
 until eol;
 }
};
procedure synterr;
var l2var1z:keyword; l2var2z:boolean;
{
 printErr;
 writeln(' SYNT. ERROR ');
 setMode(0, curmode );
 comMeta := '_012';
 pos := 1;
 glob359z := 1;
 glob357z := 1;
 glob412z := glob347z;
 Indent;
 repeat
   l2var1z := SY;
   token;
   l2var2z := (l2var1z = kend) and (ch = '.') and (nextch <> '.');
 until l2var2z;
 P1405;
 GOTO 3575;
};
procedure P1504;
{
 Indent;
 repeat token until ch = ')';
 token;
 Dindent;
};
procedure P3077;
procedure P1517;
var l3var1z: char;
{
 if curmode.f0 then {
   l3var1z := ch;
   ch := ' ';
   P0344;
   ch := l3var1z;
   glob356z := true;
 }
};
procedure P1532;
{
 if (0 < glob347z) and curmode.f0 then 
 while glob347z < 8 do P1517;

};
procedure P1544;
var l3var1z:boolean;
{
if curmode.f0 then {
repeat
 P0605;
 if 0 < glob347z then 
   l3var1z := garr273z[glob347z] <> ' '
 else
   l3var1z := true;
 until l3var1z;
 P1532;
 P0344;
 }
};
procedure getDigits;
{
  token;
  if SY <> k0 then synterr;
};
procedure getNumber;
{
 if (ch = '.') and (isDigit (nextch)) then
   getDigits;
 if (ch = 'E') then {
   if (nextch IN ['+','-']) then  token;
   getDigits;
 };
 if (ch <> '.') then  token;
};
procedure getAtom;
{
 if (ch IN ['+','-']) then token;
 if (SY = k0) then {
   getNumber;
 } else {
   if not (SY IN [k1,klast]) then synterr;
   token;
 }
};
procedure P1646;
{
 P1517; token; getAtom
};
procedure P1656;
{
 Indent;
 repeat
   token;
 until (ch = ';') or (SY IN [kthen,kelse,kof,kuntil,kdo,kend]);
 Dindent;
};
procedure P1673;
{
repeat token until ch = ':'; P1544
};
procedure doTypeDecl;
procedure P1703;
{
 if (ch = '(') then {
 P1504;
 } else {
   getAtom;
   if (ch = '.') and (nextch = '.') then {
     token; token; getAtom;
   }
 }
};
procedure P1725; { token; token };
procedure doArray; {
  repeat token until SY = kof;
  doTypeDecl
};
procedure doFile; { doArray };
procedure doSet; { doArray };
procedure doRecord;
procedure doFields(l5arg1z:boolean);
procedure doRecCase;
{
 P1517;  P0543;
 glob412z := 4;
 Indent;  P1656;
 if (SY <> kof) then synterr;
 repeat token until ch <> ';';
 while (SY <> kend) and (ch <> ')') do {
 P0543;
 getAtom;
 while (ch <> ':') do  P1646;
 P1544;
 P1517;
 glob412z := glob347z - 10;
 Indent;
 token;
 if (ch <> '(') then synterr;
 Indent;
 P1517;
 doFields (false);
 Dindent;
 if (ch <> ')') then synterr;
 repeat token until ch <> ';';
 Dindent;
 };
 Dindent;
};
{ (* doFields *)
 if l5arg1z then glob412z := 5;
 Indent; token;
 while (SY = klast) do {
   if l5arg1z then  P0543;
   l5arg1z := true;
   repeat token until ch = ':';
   P1544;
   doTypeDecl;
   while (ch = ';') do token;
 };
 Dindent;
 if (SY = kcase) then doRecCase;
};
{ (* doRecord *)
 doFields(true);
 if (SY <> kend) then synterr;
 token;
};
{ (* 2120 *)
 P1517;  Indent;  token;
 if (SY = kpacked) then token;
 if (ch = '^') or (ch = '_026') or (ch = '@') then P1725
 else if (SY = karray) then doArray
 else if (SY = kfile) then doFile
 else if (SY = kset) then doSet
 else if (SY = krecord) then doRecord
 else P1703;
 Dindent;
};
procedure doLabel;
{
 P1517; Indent;
 repeat token until ch = ';';
 token; P0543; Dindent;
};
procedure doConst;
{
 P1517; Indent; token;
 if (SY <> klast) then synterr;
 repeat 
 P1532; token;
 if (ch <> '=') then synterr;
 P1646;
 if (ch <> ';') then synterr;
 P1517; token;
 until (SY <> klast);
 P0543; Dindent;
};
procedure doType;
{
 P1517; P1517; Indent; token;
 if (SY <> klast) then synterr;
 repeat
 P1532; token;
 if (ch <> '=') then synterr;
 doTypeDecl;
 if (ch <> ';') then synterr;
 P1517; token;
 until (SY <> klast);
 P0543; Dindent;
};
procedure doVar;
{
 P1517; P1517; P1517; Indent; token;
 if (SY <> klast) then synterr;
repeat
 token;
 while (ch <> ':') do token;
 P1544; doTypeDecl;
 if (ch <> ';') then synterr;
 P1517; token;
 until (SY <> klast);
 P0543; Dindent;
};
procedure P2334;
{
 Indent;
 repeat 
   token;
   if (ch = ':') or (ch = ';') then P1517;
 until (ch = ')');
 token; Dindent;
};
procedure P2356;
{
 glob412z := 8;
 Indent; token;
 if (SY <> klast) and (SY <> kexit) then synterr;
 token;
 if (ch = '(') then P2334;
 if (ch <> ';') then synterr;
 P3077;
};
procedure P2405;
{
 glob412z := 7;
 Indent; token;
 if (SY <> klast) then synterr;
 token;
 if (ch = '(') then P2334;
 if (ch <> ':') then synterr;
 P1517; token; token;
 if (ch <> ';') then synterr;
 P3077;
};
procedure P3070;
function F2442:boolean;
{
  F2442 := (SY in [kelse,kuntil,kend]) or (ch = ';');
};
procedure P2454;
{
 if (ch <> '(') then glob412z := (2);
 Indent;
 repeat P3070 until SY = kend;
 Dindent;
 token;
};
procedure doWhile;
{
 glob412z := (4);
 Indent; P1656;
 if (SY <> kdo) then  synterr;
 P3070; Dindent;
};
procedure doRepeat;
{
 glob412z := (5);
 Indent;
 repeat P3070 until SY = kuntil;
 Dindent; P1656;
};
procedure doFor;
{
 glob412z := (2);
 Indent; P1656;
 if SY <> kdo then synterr;
 P3070; Dindent;
};
procedure doWith;
{
 glob412z := (3);
 Indent; P1656;
 if SY <> kdo then synterr;
 P3070; Dindent;
};
procedure doSelect;
{
 glob412z := (5);
 Indent; token;
 while (SY <> kend) do {
 P0543; P1673;
 glob412z := glob347z - 8;
 Indent; P3070; Dindent;
 if (ch = ';') then token;
 };
 Dindent; token;
};
procedure P2621;
{
 token;
 if (SY = klast) then token;
};
procedure P2632;
{
  token; token;
};
procedure doIf;
procedure P2641;
{
 P0543;
 glob412z := (3);
 Indent; P3070; Dindent;
};
{ (* doIf *)
 P1517; P1656;
 if (SY <> kthen) then synterr;
 P2641;
 if (SY = kelse) then P2641;
};
procedure doCase;
{
 P1517; Indent; P1656;
 if SY <> kof then  synterr;
 token;
 while SY <> kend do {
 P0543; getAtom;
 while ch <> ':' do P1646;
 P1544;
 glob412z := (glob347z - (8));
 Indent; P3070; Dindent;
 if (ch = ';') then token;
 };
 Dindent; token;
};
procedure P2742;
var l4var1z, l4var2z:integer;
{
 P0543; token;
 if curmode.f0 then {
   glob359z := 1;
   l4var2z := glob357z - 2;
   for l4var1z := glob347z to l4var2z do P1517;
   glob357z := 1;
 };
 token;
};
procedure P2766;
{
 if (SY = k0) then P2742;
 while (SY = k1) and (ch = '(') do {
 token; token;
 if (SY = k1) and (ch = ')') then {
   P1517; token;
 } else synterr;
 };
 if (SY = klast) then P1656
 else if (SY = kexit) then P2621
 else if (SY = kgoto) then P2632
 else if (ch <> ';') then {
   if (ch <> ':') then P0543;
   if (SY = kbegin) then P2454
   else if (SY = kif) then doIf
   else if (SY = kcase) then doCase
   else if (SY = kwhile) then doWhile
   else if (SY = krepeat) then doRepeat
   else if (SY = kfor) then doFor
   else if (SY = kwith) then doWith
   else if (SY = kselect) then doSelect;
 };
 if not F2442 then synterr;
};
{ (* P3070 *)
  P1517; token; P2766
};
{ (* P3077 *)
 token; P0543;
 if not (SY IN [kfortran,kextern,kforward]) then {
 if (SY = klabel) then doLabel;
 if (SY = kconst) then doConst;
 if (SY = ktype) then doType;
 if (SY = kvar) then doVar;
 while (SY IN [kfunct,kproced]) do {
   P0543;
 if (SY = kproced) then P2356 else P2405;
 };
 if (SY <> kbegin) then synterr;
 P0543;
 if (ch <> '(') then glob412z := 2;
 Indent;
 repeat P3070 until (SY = kend);
 Dindent;
 };
 token;
 if (ch <> '.') then { Dindent; token;}
 else P1405;
};
procedure init;
{
 keywrd1[kIF    ] := 'IF    ';
 keywrd1[kTHEN  ] := 'THEN  ';
 keywrd1[kELSE  ] := 'ELSE  ';
 keywrd1[kCASE  ] := 'CASE  ';
 keywrd1[kOF    ] := 'OF    ';
 keywrd1[kREPEAT] := 'REPEAT';
 keywrd1[kUNTIL ] := 'UNTIL ';
 keywrd1[kWHILE ] := 'WHILE ';
 keywrd1[kDO    ] := 'DO    ';
 keywrd1[kFOR   ] := 'FOR   ';
 keywrd1[kBEGIN ] := 'BEGIN ';
 keywrd1[kEND   ] := 'END   ';
 keywrd1[kWITH  ] := 'WITH  ';
 keywrd1[kSELECT] := 'SELECT';
 keywrd1[kGOTO  ] := 'GOTO  ';
 keywrd1[kEXIT  ] := 'EXIT  ';
 keywrd1[kCONST ] := 'CONST ';
 keywrd1[kVAR   ] := 'VAR   ';
 keywrd1[kTYPE  ] := 'TYPE  ';
 keywrd1[kRECORD] := 'RECORD';
 keywrd1[kLABEL ] := 'LABEL ';
 keywrd1[kARRAY ] := 'ARRAY ';
 keywrd1[kSET   ] := 'SET   ';
 keywrd1[kFILE  ] := 'FILE  ';
 keywrd1[kPACKED] := 'PACKED';
 keywrd1[kFUNCT] := 'FUNCTI';
 keywrd2[kFUNCT] := 'ON    ';
 keywrd1[kPROCED] := 'PROCED';
 keywrd2[kPROCED] := 'UR    ';
 keywrd1[kFORTRAN] := 'FORTRA';
 keywrd2[kFORTRAN] := 'N     ';
 keywrd1[kEXTERN] := 'EXTERN';
 keywrd2[kEXTERN] := 'AL    ';
 keywrd1[kFORWARD] := 'FORWAR';
 keywrd2[kFORWARD] := 'D     ';
 keywrd1[kPROGRAM] := 'PROGRA';
 keywrd2[kPROGRAM] := 'M     ';
 keywrd1[kLAST] := '      ';
 for glob494z := 9 to 12 do 
    unp[glob494z] := ' ';
 glob471z := 1;
 glob470z := 0;
 glob472z := false;
 setMode( 2, initMode );
 setMode( 4, initMode );
 glob488z := 50;
 atEOF := false;
 first := true;
};
procedure P3312;
label 3354;
var l2var1z, l2var2z:integer; mask, word: array[1..6] of char;
procedure P3250;
{
 printErr;
 writeln('ILL. SPECIFICATION. IGNORED.');
 GOTO 3354;
};
function readInt:integer;
var l3var1z:integer;
{
l3var1z := (0);
 while (isDigit (nextch)) do {
   l3var1z := l3var1z*10 + ord(nextch)-ord('0');
   getch (nextch );
 };
 readInt := l3var1z;
 while not eol and not isDigit (nextch) and (nextch <> '<') do
   getch (nextch );
};
{ (* P3312 *)
 glob347z := 0;
 glob346z := 0;
 glob348z := -73;
 inComment := false;
 glob469z := false;
 glob356z := true;
 comMeta := '/';
 meta := '_';
 glob349z := '_000';
 glob359z := 1;
 glob357z := 1;
 glob412z := 0;
 pos := 1;
 Indent;
 eol := true;
 errlnum := 1;
 for l2var1z := 73 to 80 do line[l2var1z] := '*';
 for l2var1z := 81 to 83 do line[l2var1z] := ' ';
 line[84] := '_012';
 longLines := false;
3354:
 while not eol do getch( nextch );
 getch( nextch );
 if atEOF then GOTO 3575;
 if (nextch = 'W') then {
   if glob472z then {
    writeln('0*** ILLEGAL W-SPECIFICATION. STOP. ***');
    halt
   } else {
     glob471z :=   readInt;
     glob471z :=   readInt;
     glob470z :=   readInt;
     goto 3354
   }
 };
(* 3403 *)
 if nextch = 'F' then {
   l2var1z := readInt;
   setMode(readInt, initMode);
   goto 3354
 };
 curmode := initMode;
 if nextch = 'R' then {
 l2var1z := readInt;
 l2var1z := readInt;
 glob487z := readInt * 2000B;
 word[1] := '*';
 mask[1] := '_377';
 word[2] := 'R';
 mask[2] := '_377';
 word[3] := 'E';
 mask[3] := '_377';
 word[4] := 'A';
 mask[4] := '_377';
 word[5] := 'D';
 mask[5] := '_377';
 word[6] := '_000';
 mask[6] := '_000';
 if (nextch = '<') then {
 l2var2z := 1;
 (read) {
 getch( word[l2var2z] );
 mask[l2var2z] := '_377';
 l2var2z := l2var2z + 1;
 if eol then P3250;
 if (word[l2var2z] <> '>') and (l2var2z <> 7) then goto read;
 };
 for l2var2z := l2var2z to 6 do {
   word[l2var2z] := '_000';
   mask[l2var2z] := '_000';
   }
 }; (* 3471 *)
 pck(word[1], glob272z);
 pck(mask[1], glob273z);
 while not eol do getch( nextch );
 glob489z := atEOF;
 atEOF := false;
 glob488z := l2var1z;
 getch( nextch );
 if atEOF then GOTO 3575;
 }; (* 3512 *)
 glob472z := true;
};
{
  rewrite(result);
  writeln(result, '*call *pascal', '_303');
  pasended(result);
  init;
  (loop) { (* 3525 *)
  P3312; token;
  if (errline[1] = '*') or (errline[1] = '+') then 
    P1405
  else {
   if SY <> kPROGRAM then synterr;
   P0543; token;
   if SY <> klast then synterr;
   write( ' ' );
   for glob494z := 1 to 8 do {
     if (unp[glob494z] = 'X') then write( 'X' )
     else write( unp[glob494z] );
   };
 if first then {
   first := false;
   write('                                        ');
   write('                                        ');
   write(boilerplate);
 };
 writeln;
 token;
 if ch = '(' then P1504;
 if ch <> ';' then synterr;
 P3077;
 };
3575:
 if not atEOF then goto loop;
 if not atEOF then goto loop;
  };
 write(result, '*READ OLD', '_307');
 pasended(result);
}.
