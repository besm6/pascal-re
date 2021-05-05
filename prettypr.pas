(*=p-,t-*)
program prettypr(output, input, result);
label 3575;
const boilerplate = '*** VERSION 25.02.82 ***';
type
    bool3=record indent, breakLines, expand: boolean end;
keyword=(knum, k1, kif, kthen, kelse, kcase, kof, krepeat, kuntil,
kwhile,kdo,kfor,kbegin, kend, kwith, kselect, kgoto, kexit, kconst,kvar,
ktype,krecord,klabel,karray,kset,kfile,kpacked,kfunct,kproced, kfortran,
kextern, kforward, kprogram, kident);
var result:text;
line:array [1..84] of char;
inpline:array [1..80] of char;
unused1:array[204..261] of char;
inppos, inplnum:integer;
unused2:array[264..270] of char;
longLines:boolean;
dummy6, dummy7:alfa;
forming:array[1..72] of char;
margSaved, margRight, margLeft:integer;
checkQuote:char;
initMode,curmode:bool3;
wasSpace:boolean;
neededPos, indAmount, curLinePos:integer;
atStart:boolean;
stack:array [1..50] of integer;
stackpos, offset:integer;
ch, nextch:char;
unp: array [1..12] of char;
pck1, pck2: alfa;
keywrd1:array [kif..kident] of alfa;
keywrd2:array [kfunct..kprogram] of alfa;
SY:keyword;
inComment, inQuoteOrComm:boolean;
dummy5, dummy4:integer; illSpec: boolean;
unused3:array [473..486] of char;
dummy3, dummy2:integer;
dummy1, atEOF, eol:boolean;
comMeta,meta:char;
idx:integer; first: boolean;

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
  0: { l.indent := false;
       l.breakLines := false;
     };
  1: l.indent := true;
  2: { l.indent := true;
       l.breakLines := true
     };
  3: l.expand := true;
  4: l.expand := false
  end
};
procedure outLine;
var i, nsp: integer; c: char;
procedure spaces;
(*line 170*) { 
  if nsp <> 0 then {
     write(result, chr(128+nsp)); nsp := 0
  }
};
(*line 172, outLine*) {
 for i := 73 to 83 do line[i] := ' ';
 i := 1; nsp := 0;
 repeat
   c := line[i];
   if (c  = ' ') then nsp := nsp + 1
   else {
     spaces; write(result, c);
   };
   i := i + 1;
 until i >= 84;
 spaces;
 writeLN(result); PASENDED(RESULT);
};
procedure printErr;
var l2var1z:integer;
(*line 183*) {
 write( ' ' );
 for l2var1z := 1 to inppos do 
    write( inpline[l2var1z] );
 write( '<--' );
 for l2var1z := inppos + 1 to 80 do
    write( ' ' );
 write(' ***LINE', inplnum:4, '*** ');
};
procedure finishLine;
var l2var1z:integer; done:boolean; len:integer;
procedure P0203;
var p, r, s:integer;
{
  if curmode.breakLines and (72 - margLeft + 1 < curLinePos) then {
     curLinePos := 72 - margLeft + 1;
     if neededPos < curLinePos then curLinePos := neededPos;
  };
  r := curLinePos - 1;
  for p := 1 to r do {
    line[p] := ' ';
  };
  s := curLinePos + margLeft - 1;
  for p := curLinePos to s do {
     line[p] := forming[p-curLinePos+1];
  };
  for p := curLinePos + margLeft to 72 do 
     line[p] := ' ';
  outLine;
  curLinePos := indAmount;
  neededPos := curLinePos;
  inplnum := inplnum + 1;
};
procedure badLiteral;
{
 if not inComment then {
   printErr;
   writeln('SYNT. UNIT OVER EOLN');
 }
};
procedure decrByMargin(var a:integer);
var i:integer;
{
 i := a - margLeft;
 if i > 0 then
    a := i
 else a := 0;
};

{ (* finishLine *)
 if margLeft > 0 then {
   if inQuoteOrComm and (margLeft = margRight) then badLiteral;
   P0203;
   repeat 
     done := true;
     if (margLeft < margRight) and
      (forming[margLeft+1] = ' ') then {
      margLeft := margLeft + 1;
      done := false;
     }
   until done;
   len := margRight - margLeft;
   for l2var1z := 1 to len do {
     forming[l2var1z] := forming[margLeft+l2var1z];
   };
   decrByMargin( margRight );
   decrByMargin( margSaved );
   margLeft := -73;
   atStart := true;
 }
};

procedure WriteACharacter;
var i:integer;
{
 if (margRight <= 0) and (ch = ' ') and curmode.indent then exit;
 margRight := margRight + 1;
 forming[margRight] := ch;
 (L0357) if 72 - curLinePos < margRight then {
   if curmode.breakLines then {
   if (0 < margSaved) and (margSaved < margLeft) then
    margLeft := margSaved;
   if 50 - neededPos < margLeft then {
    finishLine;
    goto L0357;
   };
   if 1 < curLinePos then {
    curLinePos := curLinePos - 1;
    goto L0357;
   };
 if margLeft <= 0 then {
   if not inComment then {
     printErr;
     writeln('TOO LONG SYNT. UNIT');
   };
   margLeft := margRight;
 };
 finishLine;
} else {
 for i := 1 to inppos do 
   forming[i] := inpline[i];
 margRight := inppos;
 margLeft := margRight;
 curLinePos := 1;
 }
 }
};
procedure getch(var out:char);
var i, l2var2z: integer;
{
  if atEOF then {
    writeln('0***** EOF BEFORE END OF PROGRAM');
    GOTO 3575;
  };
  out := INPUT@;
 if eol then
 inppos := 1
else
 inppos := inppos + 1;

 eol := eoln(INPUT );
 atEOF := eof(INPUT );
if not atEOF then get(INPUT );

 if out = '''' then {
 if out = checkQuote then {
 out := '''';
 } else {
 checkQuote := out;
 out := '''';
 };
 } else {
 if eol then  out := ' ';
 };
 inpline[inppos] := out;
};
procedure CopyACharacter;
var l2var1z:integer;
procedure P0470;
{
  if not curmode.breakLines and (margRight = 0) then {
   margRight := 1;
   forming[1] := ' ';
  };
  margLeft := margRight;
  finishLine;
};
{ (* CopyACharacter *)
if longLines then {
 if eol then {
   P0470;
   getch( nextch );
 };
 } else  if 72 < inppos then {
   line[73] := nextch;
   for l2var1z := 74 to 80 do
     getch( line[l2var1z] );
   P0470;
   repeat  getch( nextch ) until eol;
   getch( nextch );
 };
 ch := nextch;
 WriteACharacter;
 getch( nextch );
};
procedure optNewLine;
{
if (curmode.breakLines and not atStart) then finishLine
};
procedure Indent;
var i: integer;
{
  i := neededPos + margRight - offset;
 if 50 >= i then {
   indAmount := i;
 } else {
   indAmount := 50;
 };
 stack[stackpos] := indAmount;
 stackpos := stackpos + 1;
 offset := 0;
};
procedure Dindent;
{
 stackpos := stackpos - 1;
 indAmount := stack[stackpos-1];
 if atStart then {
 neededPos := indAmount;
 curLinePos := neededPos;
 }
};
procedure P0605;
{
if 0 < margRight then {
 margRight := margRight - 1;
 if margRight < margLeft then  margLeft := margRight;
}
};
procedure token;
label 1322;
var l2var1z:boolean;
procedure P0617;
{
if margRight = 0 then {
 printErr;
 writeln('F3 OR =U- ERROR');
 } else 
   P0605;
};
procedure doBegin;
{
if curmode.expand and (ch = '(') then {
 P0617; P0617;
 ch := 'B'; WriteACharacter;
 ch := 'E'; WriteACharacter;
 ch := 'G'; WriteACharacter;
 ch := 'I'; WriteACharacter;
 ch := 'N'; WriteACharacter;
 ch := ' '; WriteACharacter;
 }
};
procedure doEnd;
{
if curmode.expand and (ch = ')') then {
 P0617; P0617;
 ch := ' '; WriteACharacter;
 ch := 'E'; WriteACharacter;
 ch := 'N'; WriteACharacter;
 ch := 'D'; WriteACharacter;
 optNewLine;
 margLeft := margRight;
}
};
procedure matchKeyword;
var done:boolean;
{
pck(unp[1], pck1);
pck(unp[7], pck2);
repeat
SY := succ(SY);
 done := keywrd1[SY] = pck1;
 if done and (ord(SY) >= 27) then 
  done := keywrd2[SY] = pck2;
until done or (SY = kident);
};
procedure getIdent;
var i:integer;
{
if ord(ch) = 88 then ch := 'X';
 unp[1] := ch;
 for i := 2 to 8 do 
    unp[i] := ' ';
 i := 1;
 while isLetter (nextch) or isDigit (nextch) do {
   CopyACharacter;
   if i < 8 then {
     i := i + 1;
     if ord(ch) = 88 then  ch := 'X';
     unp[i] := ch;
   }
 }
};
procedure doComment;
var l3var1z:integer; good:boolean;
procedure getAttr(var l4arg1z:integer; l4arg2z: char);
{
 CopyACharacter;
 if (ch >= '0') and (ch <= l4arg2z) then {
  l4arg1z := ord(ch) - ord('0');
  good := true;
 }
};
procedure getFlag(var l4arg1z:boolean);
{
 CopyACharacter;
 if (ch = '-') or (ch = '+') then {
 l4arg1z := ch = '+';
 good := true;
}
};
{ (* doComment *) 
 inQuoteOrComm := true; inComment := true;
 CopyACharacter; CopyACharacter;
 if (ch = comMeta) or (ch = '=') then repeat
 CopyACharacter;
 good := false;
 case (ch) of
 'F': {
   getAttr(l3var1z, '4');
   if (good) then setMode(l3var1z, curmode)
   else if (ch = 'S') then {
   good := true;
   curmode := initMode;
   }
 };
 'U': {
   getFlag( longLines );
   longLines := not longLines;
   if longLines then {
     setMode (2, curmode );
     P0617;
     ch := '+';
     WriteACharacter;
   }
 };
 'A': {
   getAttr(l3var1z, '3' );
   printErr;
   writeln('PSEUDOCOMM. A', ch);
 };
 'J': {
   CopyACharacter;
   meta := ch;
   good := true;
 };
 'B','C','E','I','K','L','M','N',
 'P','R','S','T','Y','Z','Г': {
   CopyACharacter;
   good := true;
 }
 end;
 if good then CopyACharacter
 else {
   printErr;
   writeln('ERROR IN PSEUDOCOMMENT');
 };
 until ch <> ',';
 repeat while ch <> '*' do CopyACharacter;
    CopyACharacter until ch = ')';
 inQuoteOrComm := false;
 inComment := false;
 margLeft := margRight;
 atStart := false;
 l2var1z := true;
};
procedure CopyANumber;
{
 while isDigit (nextch) do CopyACharacter;
 if isLetter (nextch) or (nextch = '.') then  CopyACharacter;
 SY := knum;
};
procedure doChar;
{
 inQuoteOrComm := true;
 (loop) repeat
 CopyACharacter;
 if (ch = '''') and (nextch = '''') then {
   CopyACharacter;
   ch := ' ';
   if (nextch = ']') or (nextch = ';') then exit loop;
 }
 until ch = '''';
 checkQuote := '_000';
 inQuoteOrComm := false;
};
{ (* token *)
 atStart := false;
 margLeft := margRight;
 l2var1z := true;
 while l2var1z do {
 CopyACharacter;
 l2var1z := ch = ' ';
 if l2var1z and curmode.indent then {
 if wasSpace then 
    P0605
  else
   wasSpace := true;
 } else if (ch = '(') and (nextch = '*') then {
   doComment;
 } else {
   SY := k1;
   if isLetter( ch) then {
   1322:
    getIdent;
    matchKeyword;
   } else if ch = meta then {
     CopyACharacter;
     if isLetter( ch) then goto 1322;
     if ch = '(' then {
       SY := kbegin;
       doBegin;
     } else if ch = ')' then {
       SY := kend;
       doEnd; (q) exit q;
     }; 
   }  else if isDigit( ch) then CopyANumber
     else if (ch = '''') then { doChar; (q) exit q }
 };
}; (* while *)
 wasSpace := false;
 if ch = ';' then {
 margLeft := margRight;
 margSaved := margRight;
 } else if (SY = kend) and (ch <> ')') then {
   optNewLine;
   margLeft := margRight;
 } else if ch = ',' then {
   margLeft := margRight;
 }
};
procedure terminate;
var l2var1z:integer;
function atEOL:boolean;
{
 if longLines then atEOL := eol else
 if inppos > 72 then atEOL := true else atEOL := false;
};
{ (* terminate *)
 setMode(0, curmode );
 curLinePos := 1;
 margLeft := margRight;
 while not atEOL do {
   margLeft := margRight;
   CopyACharacter;
 };
 if longLines then {
   finishLine;
 } else {
 line[73] := nextch;
 for l2var1z := 74 to 80 do 
   getch( line[l2var1z] );
 finishLine;
 repeat getch(nextch) until eol;
 }
};
procedure synterr;
var l2var1z:keyword; l2var2z:boolean;
{
 printErr;
 writeln(' SYNT. ERROR ');
 setMode(0, curmode );
 comMeta := '_012';
 stackpos := 1;
 curLinePos := 1;
 neededPos := 1;
 offset := margRight;
 Indent;
 repeat
   l2var1z := SY;
   token;
   l2var2z := (l2var1z = kend) and (ch = '.') and (nextch <> '.');
 until l2var2z;
 terminate;
 GOTO 3575;
};
procedure toParen;
{
 Indent;
 repeat token until ch = ')';
 token;
 Dindent;
};
procedure run;
procedure addSpace;
var tmp: char;
{
 if curmode.indent then {
   tmp := ch;
   ch := ' ';
   WriteACharacter;
   ch := tmp;
   wasSpace := true;
 }
};
procedure tabulate;
{
 if (0 < margRight) and curmode.indent then 
 while margRight < 8 do addSpace;

};
procedure alignItem;
var done:boolean;
{
if curmode.indent then {
repeat
 P0605;
 if 0 < margRight then 
   done := forming[margRight] <> ' '
 else
   done := true;
 until done;
 tabulate;
 WriteACharacter;
 }
};
procedure getDigits;
{
  token;
  if SY <> knum then synterr;
};
procedure getNumber;
{
 if (ch = '.') and isDigit(nextch) then
   getDigits;
 if ch = 'E' then {
   if nextch IN ['+','-'] then  token;
   getDigits;
 };
 if ch <> '.' then token;
};
procedure getAtom;
{
 if ch IN ['+','-'] then token;
 if SY = knum then {
   getNumber;
 } else {
   if not (SY IN [k1,kident]) then synterr;
   token;
 }
};
procedure spacify;
{
 addSpace; token; getAtom
};
procedure doExpression;
{
 Indent;
 repeat
   token;
 until (ch = ';') or (SY IN [kthen,kelse,kof,kuntil,kdo,kend]);
 Dindent;
};
procedure toColon;
{
repeat token until ch = ':'; alignItem
};
procedure doTypeDecl;
procedure doRangeType;
{
 if ch = '(' then {
 toParen;
 } else {
   getAtom;
   if (ch = '.') and (nextch = '.') then {
     token; token; getAtom;
   }
 }
};
procedure doPointer; { token; token };
procedure doArray; {
  repeat token until SY = kof;
  doTypeDecl
};
procedure doFile; { doArray };
procedure doSet; { doArray };
procedure doRecord;
procedure doFields(fixed:boolean);
procedure doRecCase;
{
 addSpace;  optNewLine;
 offset := 4;
 Indent;  doExpression;
 if SY <> kof then synterr;
 repeat token until ch <> ';';
 while (SY <> kend) and (ch <> ')') do {
 optNewLine;
 getAtom;
 while ch <> ':' do  spacify;
 alignItem;
 addSpace;
 offset := margRight - 10;
 Indent;
 token;
 if ch <> '(' then synterr;
 Indent;
 addSpace;
 doFields (false);
 Dindent;
 if ch <> ')' then synterr;
 repeat token until ch <> ';';
 Dindent;
 };
 Dindent;
};
{ (* doFields *)
 if fixed then offset := 5;
 Indent; token;
 while SY = kident do {
   if fixed then  optNewLine;
   fixed := true;
   repeat token until ch = ':';
   alignItem;
   doTypeDecl;
   while ch = ';' do token;
 };
 Dindent;
 if SY = kcase then doRecCase;
};
{ (* doRecord *)
 doFields(true);
 if SY <> kend then synterr;
 token;
};
{ (* 2120 *)
 addSpace;  Indent;  token;
 if SY = kpacked then token;
 if (ch = '^') or (ch = '_026') or (ch = '@') then doPointer
 else if SY = karray then doArray
 else if SY = kfile then doFile
 else if SY = kset then doSet
 else if SY = krecord then doRecord
 else doRangeType;
 Dindent;
};
procedure doLabel;
{
 addSpace; Indent;
 repeat token until ch = ';';
 token; optNewLine; Dindent;
};
procedure doConst;
{
 addSpace; Indent; token;
 if (SY <> kident) then synterr;
 repeat 
 tabulate; token;
 if (ch <> '=') then synterr;
 spacify;
 if (ch <> ';') then synterr;
 addSpace; token;
 until (SY <> kident);
 optNewLine; Dindent;
};
procedure doType;
{
 addSpace; addSpace; Indent; token;
 if (SY <> kident) then synterr;
 repeat
 tabulate; token;
 if (ch <> '=') then synterr;
 doTypeDecl;
 if (ch <> ';') then synterr;
 addSpace; token;
 until (SY <> kident);
 optNewLine; Dindent;
};
procedure doVar;
{
 addSpace; addSpace; addSpace; Indent; token;
 if (SY <> kident) then synterr;
repeat
 token;
 while (ch <> ':') do token;
 alignItem; doTypeDecl;
 if (ch <> ';') then synterr;
 addSpace; token;
 until (SY <> kident);
 optNewLine; Dindent;
};
procedure doArgs;
{
 Indent;
 repeat 
   token;
   if (ch = ':') or (ch = ';') then addSpace;
 until (ch = ')');
 token; Dindent;
};
procedure doProc;
{
 offset := 8;
 Indent; token;
 if (SY <> kident) and (SY <> kexit) then synterr;
 token;
 if (ch = '(') then doArgs;
 if (ch <> ';') then synterr;
 run;
};
procedure doFunc;
{
 offset := 7;
 Indent; token;
 if (SY <> kident) then synterr;
 token;
 if (ch = '(') then doArgs;
 if (ch <> ':') then synterr;
 addSpace; token; token;
 if (ch <> ';') then synterr;
 run;
};
procedure doStatement;
function atStmtEnd:boolean;
{
  atStmtEnd := (SY in [kelse,kuntil,kend]) or (ch = ';');
};
procedure doBlock;
{
 if (ch <> '(') then offset := 2;
 Indent;
 repeat doStatement until SY = kend;
 Dindent;
 token;
};
procedure doWhile;
{
 offset := 4;
 Indent; doExpression;
 if (SY <> kdo) then  synterr;
 doStatement; Dindent;
};
procedure doRepeat;
{
 offset := 5;
 Indent;
 repeat doStatement until SY = kuntil;
 Dindent; doExpression;
};
procedure doFor;
{
 offset := 2;
 Indent; doExpression;
 if SY <> kdo then synterr;
 doStatement; Dindent;
};
procedure doWith;
{
 offset := 3;
 Indent; doExpression;
 if SY <> kdo then synterr;
 doStatement; Dindent;
};
procedure doSelect;
{
 offset := 5;
 Indent; token;
 while (SY <> kend) do {
 optNewLine; toColon;
 offset := margRight - 8;
 Indent; doStatement; Dindent;
 if (ch = ';') then token;
 };
 Dindent; token;
};
procedure doExit;
{
 token;
 if (SY = kident) then token;
};
procedure doGoto;
{
  token; token;
};
procedure doIf;
procedure doBranch;
{
 optNewLine;
 offset := 3;
 Indent; doStatement; Dindent;
};
{ (* doIf *)
 addSpace; doExpression;
 if SY <> kthen then synterr;
 doBranch;
 if SY = kelse then doBranch;
};
procedure doCase;
{
 addSpace; Indent; doExpression;
 if SY <> kof then  synterr;
 token;
 while SY <> kend do {
 optNewLine; getAtom;
 while ch <> ':' do spacify;
 alignItem;
 offset := margRight - 8;
 Indent; doStatement; Dindent;
 if ch = ';' then token;
 };
 Dindent; token;
};
procedure doGotoTarget;
var i, upto:integer;
{
 optNewLine; token;
 if curmode.indent then {
   curLinePos := 1;
   upto := neededPos - 2;
   for i := margRight to upto do addSpace;
   neededPos := 1;
 };
 token;
};
procedure doStmt;
{
 if (SY = knum) then doGotoTarget;
 while (SY = k1) and (ch = '(') do {
 token; token;
 if (SY = k1) and (ch = ')') then {
   addSpace; token;
 } else synterr;
 };
 if (SY = kident) then doExpression
 else if SY = kexit then doExit
 else if SY = kgoto then doGoto
 else if ch <> ';' then {
   if ch <> ':' then optNewLine;
   if SY = kbegin then doBlock
   else if SY = kif then doIf
   else if SY = kcase then doCase
   else if SY = kwhile then doWhile
   else if SY = krepeat then doRepeat
   else if SY = kfor then doFor
   else if SY = kwith then doWith
   else if SY = kselect then doSelect;
 };
 if not atStmtEnd then synterr;
};
{ (* doStatement *)
  addSpace; token; doStmt
};
{ (* run *)
 token; optNewLine;
 if not (SY IN [kfortran,kextern,kforward]) then {
 if SY = klabel then doLabel;
 if SY = kconst then doConst;
 if SY = ktype then doType;
 if SY = kvar then doVar;
 while SY IN [kfunct,kproced] do {
   optNewLine;
 if SY = kproced then doProc else doFunc;
 };
 if SY <> kbegin then synterr;
 optNewLine;
 if ch <> '(' then offset := 2;
 Indent;
 repeat doStatement until SY = kend;
 Dindent;
 };
 token;
 if (ch <> '.') then { Dindent; token;}
 else terminate;
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
 keywrd1[kident] := '      ';
 for idx := 9 to 12 do unp[idx] := ' ';
 dummy4 := 1;
 dummy5 := 0;
 illSpec := false;
 setMode( 2, initMode );
 setMode( 4, initMode );
 dummy2 := 50;
 atEOF := false;
 first := true;
};
procedure readSpec;
label 3354;
var l2var1z, l2var2z:integer; mask, word: array[1..6] of char;
procedure P3250;
{
 printErr;
 writeln('ILL. SPECIFICATION. IGNORED.');
 GOTO 3354;
};
function readInt:integer;
var v:integer;
{
v := 0;
 while isDigit (nextch) do {
   v := v*10 + ord(nextch)-ord('0');
   getch (nextch );
 };
 readInt := v;
 while not eol and not isDigit (nextch) and (nextch <> '<') do
   getch (nextch );
};
{ (* readSpec *)
 margRight := 0;
 margSaved := 0;
 margLeft := -73;
 inComment := false;
 inQuoteOrComm := false;
 wasSpace := true;
 comMeta := '/';
 meta := '_';
 checkQuote := '_000';
 curLinePos := 1;
 neededPos := 1;
 offset := 0;
 stackpos := 1;
 Indent;
 eol := true;
 inplnum := 1;
 for l2var1z := 73 to 80 do line[l2var1z] := '*';
 for l2var1z := 81 to 83 do line[l2var1z] := ' ';
 line[84] := '_012';
 longLines := false;
3354:
 while not eol do getch( nextch );
 getch( nextch );
 if atEOF then GOTO 3575;
 if (nextch = 'W') then {
   if illSpec then {
    writeln('0*** ILLEGAL W-SPECIFICATION. STOP. ***');
    halt
   } else {
     dummy4 :=   readInt;
     dummy4 :=   readInt;
     dummy5 :=   readInt;
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
 dummy3 := readInt * 2000B;
 word[1]:='*';mask[1]:='_377';
 word[2]:='R';mask[2]:='_377';
 word[3]:='E';mask[3]:='_377';
 word[4]:='A';mask[4]:='_377';
 word[5]:='D';mask[5]:='_377';
 word[6]:='_000';mask[6]:='_000';
 if nextch = '<' then {
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
 pck(word[1], dummy6);
 pck(mask[1], dummy7);
 while not eol do getch( nextch );
 dummy1 := atEOF;
 atEOF := false;
 dummy2 := l2var1z;
 getch( nextch );
 if atEOF then GOTO 3575;
 }; (* 3512 *)
 illSpec := true;
};
{
  rewrite(result);
  writeln(result, '*call *pascal', '_303');
  pasended(result);
  init;
  (loop) { (* 3525 *)
  readSpec; token;
  if (inpline[1] = '*') or (inpline[1] = '+') then 
    terminate
  else {
   if SY <> kPROGRAM then synterr;
   optNewLine; token;
   if SY <> kident then synterr;
   write( ' ' );
   for idx := 1 to 8 do {
     if (unp[idx] = 'X') then write( 'X' )
     else write( unp[idx] );
   };
 if first then {
   first := false;
   write('                                        ');
   write('                                        ');
   write(boilerplate);
 };
 writeln;
 token;
 if ch = '(' then toParen;
 if ch <> ';' then synterr;
 run;
 };
3575:
 if not atEOF then goto loop;
 if not atEOF then goto loop;
  };
 write(result, '*READ OLD', '_307');
 pasended(result);
}.
