(*=p-,t-,s8,y+*)
program noprog(output, pasddc, pasdds, rgexport, isoptext);
const boilerplate =' PASCAL-DEBUG 1.0 (25.02.82)';
errAfterSlash = 0;
errBadRequest = 1;
errNoOSIRBAC = 2;
errOnlyOneOSIRBAC = 3;
errWrongShashL = 5;
err89InOctal = 6;
errNoInteger = 7;
errNoName = 8;
errBadPrintType = 9;
errTooLarge = 10;
errManyPoints = 11;
errManyConds = 12;
errSystem = 16;
errStack = 18;
errBadSign = 19;
INFINITY = 76400B;
type
    bitset = set of 0..47;
    insn = packed record case integer of
	0: (reg: 0..15; flag: boolean);
	1: (reg1: 0..15; insn1: 0..377B; saddr: 0..7777B);
	2: (reg2: 0..15; insn2: 0..37B; laddr: 0..77777B)
    end;
    format = (fReal, fInt, fAlfa, fUnkn, fOct2, fBytes, fInsn);
    condmode = (lineRange, varValue, elapsedTime,
                stopAfter, inProc, idxValue, memValue);
    dbgMode = (dbgFreeRun, dbgInteractive, dbgStart, dbgCheck);
    formats = set of format;
    varAttrs = packed record
        flag: boolean;
        a: 0..3;
        descr:0..32767;
        dum:0..4095;
        fmt:format;
        data: 0..32767;
    end;
    rels = char; (* '<'..'>' yields more compact code *)
    word = record 
	case integer of
	0: (c:'_000'..'_077');
	1:(m: bitset);
	2:(i:integer);
	22:(r: real);
	23:(a: alfa);
        24:(b:boolean);
	3:(p:@word);
	32:(r2:@varDescr);
        4:(k: packed array [1..2] of insn) ;
        6:(pck:varAttrs)
    end;
    varDescr = record case integer of
        0: (next: @varDescr);
        1: (varname: bitset; attrs: varAttrs)
    end;
    regarray = record
        acc:integer;
        i14: char;
        idx: array[1..13] of @varDescr
    end;
    pointrec = record startCond, nConds: integer end;
    condrec = record
        where: integer; (* nesting level, static/dynamic/this *)
        case cmode: condmode of
            lineRange: (startLn, endLn: integer);
            varValue: (name: bitset (* rel, target *) );
            elapsedTime: (minTime: real);
            stopAfter: (count: integer);
            inProc: (procname: bitset);
            idxValue: (num: integer; rel: rels; target: word);
            memValue: (addr: word (* rel, target *) );
    end;
    redtype=record 
        buflen, inplen: integer;
        charcnt:integer; endl: boolean;
        buf: packed array[1..80] of char;
    end;

var pasddc: record 
	verbose: boolean;
        curline: integer;
        curproc: bitset;
        outFmt, inFmt: formats;
        source: integer;
        usedPoints: integer;
	points:array[1..20] of pointrec;
        usedConds:integer;
	conds:array[1..40] of condrec
	end; 
pasdds:dbgMode;
rgexport:integer;
isoptext: packed array ['*'..'_176'] of '_000'..'_077';
(*=e+*)procedure pasdd1; (*=e-*)
label 3474, 3477;
const statFrame = 0;
   thisFrame = 1;
   dynFrame = 2;
   noFrame = 3;
var 
    regs: @regarray; (* magically filled by the caller P/DD *)
    curpoint: integer;
    verbAddr, verbMatch: boolean;
    lineno, numlen: integer;
    ch: char;
    dbg:dbgMode;
    nesting: integer;
    frameptr: @varDescr;
    idx7: word;
    thisdescr: word;
    red: redtype;
    foundProc: word;
    foundDescr: word;
    foundFrame: @varDescr;
    foundUnused: array[1..2] of word;
    valptr: word;
    curcond, unused: condrec;
procedure PASTPR(text: bitset); external;
procedure PASPMD; external;
procedure PASISOCD; external;
procedure PASRED(var red:redtype); external;
function time:real;
var t:char; 
{
    besm(630004B); t:= ; time := ord(t) * 0.01999999999999;
};
procedure err(arg:integer);
var i:integer;
{
 writeln(' DEBUG  OШ=', arg:10);
 for i := 1 to red.inplen do write(red.buf[i]);
 writeln;
 writeln('!':red.charcnt);
 case arg of
 0: write('ПOCЛE / MOЖHO L  I  D  T  S');
 1: write('HEПP. ЗAПPOC');
 2: write(' HET O S I R B A C');
 3: write(' TOЛЬKO OДИH ИЗ O S I R B A C');
 5: write('HEПP.ЗAДAH /L');
 6: write('8 9 B BOCЬMEPИЧHOM');
 7: write('HET ЦEЛOГO');
 8: write('HET ИMEHИ');
 9: write('HEПP. TИП ПEЧATИ');
 10: write(' CЛИШKOM БOЛЬШOE ЧИCЛO');
 11: write('MHOГO TOЧEK');
 12: write('MHOГO YCЛOBИЙ');
 13: write('B ФAЙЛE ', PASDDC.source:10 oct, ' HEПP. ',
              lineno:1, ' CTP');
 14, 15, 17: write('B ФAЙЛE ', PASDDC.source:10 oct,
       ' HEПPABИЛЬHAЯ ', lineno:1, ' CTPOKA');
 16: write(' OШ.SYSTEM');
 18: write('HEПP.CTEK');
 19: write('HEПP.ЗHAK OTH.');
end;
goto 3477;
};

procedure checkRestart;
{
    if PASDDS=dbgInteractive then goto 3474; 
};

procedure nextChar;
{
 red.endl := red.charcnt >= red.inplen;
 if red.endl then {
    ch := '%';
 } else {
 red.charcnt := red.charcnt + 1;
 ch := red.buf[red.charcnt];
}
};
procedure skipSpaces;
{
 while ch = ' ' do nextChar;
};

procedure nextAndSkip;
{ 
    nextChar; skipSpaces
};
function isDigit: boolean;
{
     isDigit := ('0' <= ch) and (ch <= '9');
};

function isLetter: boolean;
{
    isLetter := ('A' <= ch) and (ch <= '_176');
};

function getDecimal : integer;
var ret: integer;
function isMeta: boolean;
{
    isMeta := true;
    case ch of
    '*': {
        ret := PASDDC.curline;
        nextAndSkip;
    };
    '$': {
        ret := INFINITY;
        nextAndSkip;
    };
    others: isMeta := false;
 end
};
{ (* getDecimal *)
    if (not isMeta) then {
        skipSpaces;
        if not isMeta then {
            if not isDigit then err(errNoInteger);
            ret := 0;
            while (isDigit) do {
                ret := 10 * ret + ord(ch) - ord('0');
                nextChar;
            }
        }
    };
    skipSpaces;
    getDecimal := ret;
};

function nextDecimal: integer;
{ 
    nextChar; nextDecimal := getDecimal
};
procedure getFormats(var ret:formats);
var fmt:formats;
{
    ret := [];
    skipSpaces;
    while not red.endl and (ch <> ' ') do {
        case ch of
        'O': fmt := [fOct2];
        'I': fmt := [fInt];
        'R': fmt := [fReal];
        'B': fmt := [fBytes];
        'A': fmt := [fAlfa];
        'C': fmt := [fInsn];
        others: err(errNoOSIRBAC);
        end;
        nextChar;
        ret := ret + fmt;
    }; (* while *)
    if ch = ' ' then nextChar;
};
function getName: set of 0..47; 
var curchar: word; ret: set of 0..47; i: integer;
{
    ret := [];
    i := 1;
    if not isLetter then err(errNoName);
    repeat
        curchar.c := ISOPTEXT[ch];
        nextChar;
        if i <= 8 then {
            i := i + 1;
            ret := ret;
            besm(360072B);
            ret := ;
            ret := ret + curchar.m;
        }
    until not isLetter and not isDigit;
    skipSpaces;
    getName := ret;
};

function getFrame(arg:integer):integer;
{
    if (arg = 7) or ((arg >= 1) and (arg <= nesting)) then {
        frameptr := regs@.idx[arg];
        getFrame := thisFrame;
    } else if arg = 0 then
        getFrame := statFrame
    else if arg = 20 then {
        frameptr := regs@.idx[7];
        getFrame := dynFrame;
    } else {
        getFrame := noFrame; (q) exit q
    }
};

function checkProc(ident: bitset; where:integer):boolean;
var matched:boolean; curlev:integer; curDescr: word;
function matchIdent:boolean;
{
    curDescr.i := frameptr@.attrs.descr;
    matchIdent := false;
    if curDescr.i <> 0 then {
        curDescr.p := ptr(curDescr.i);
        matchIdent := curDescr.p@.m = ident;
        if verbMatch then {
	    write(' '); PASTPR(curDescr.p@.m)
        };
    };
    if verbMatch then {
        writeln(' CTEK=', frameptr:5 oct );
    };
    checkRestart;
};

{ (* checkProc *)
     with regs@ do { (* useless with *)
         case getFrame(where) of
         statFrame: {
             curlev := nesting + 1;
             matched := false;
% *0534B:,BSS,;
             while (not matched) and (curlev > 1) do {
                 curlev := curlev - 1;
                 frameptr := regs@.idx[curlev];
                 matched :=  matchIdent;
             };
         };
         thisFrame: matched :=   matchIdent;
         dynFrame: (loop) {
             matched :=   matchIdent;
             if not matched then {
                 if frameptr = regs@.idx[1] then {
                     exit loop
                 } else {
                     frameptr := frameptr@.next;
                     goto loop; 
                 }; (q) exit q;
             }; (q) exit q;
         };
         noFrame: matched := false;
         end;
     }; (* with *)
     checkProc := matched;
     if matched then {
         foundDescr := curDescr;
         foundProc.r2 := frameptr;
     } else {
         foundProc.i := 0;
     }
};

procedure printWord(arg:word; fmts:formats);
var curfmt:format; i:integer; ch:char;
procedure printInsn(cmd:insn);
{
    write(cmd.reg:2 oct, ' ');
    if cmd.flag then
        write(cmd.insn2:2 oct, ' ', cmd.laddr:5 oct)
    else
        write(cmd.insn1:3 oct, ' ', cmd.saddr:4 oct);
    write(' ':2);
};
{ (* printWord *)
    with PASDDC do if fmts = [] then
	fmts := outFmt;
    for curfmt := fReal to fInsn do (loop) {
        if curfmt IN fmts then { 
            case curfmt of
                fUnkn, fOct2: write(arg.i:17 oct);
                fInt: write(arg.i:10);
                fReal: write(arg.r:14:4);
                fBytes: for i to 6 do
                    write(' ', arg.a[i]:3 oct); 
                fAlfa: {
                    write('''');
                    for i to 6 do {
	                ch := arg.a[i];
 	                if (ch < ' ') or (ch > '_177') then
		            ch := '&';
 	                    write(ch);
                    };
                    write('''');PASTPR(arg.m);write('''');
                };
                fInsn: {
                    printInsn(arg.k[1]);
                    printInsn(arg.k[2]);
                };
                others: exit loop
                end;
            write(' ');
        }
    }
};

function checkValue(ident: bitset; where:integer):boolean;
var
    ret: boolean;
    level: integer;
    curDescr, startDescr, addr: word;
function findIdent:boolean;
var ret: boolean; offset: integer; varname: bitset;
{
    startDescr.i := frameptr@.attrs.descr;
    ret := false;
    curDescr := startDescr;
    if (curDescr.i <> 0) then {
        if verbMatch and verbAddr then {
            write(' '); PASTPR(curDescr.p@.m);
            writeln(' CTP=', curDescr.r2@.attrs.data:5, 
                    ' CTEK=', frameptr:5 oct);
        };
        repeat 
            curDescr.i := curDescr.i + 2;
            varname := curDescr.r2@.varname;
            ret := varname = ident;
            if verbMatch and (varname <> [])
                and (verbAddr or
                (not verbAddr and ret)) then
                with curDescr.r2@.attrs do {
                    write(' ':7);
                    PASTPR (varname);
                    offset := data;
                    addr.i := ord(frameptr) + offset;
                    write(' OFF=', offset:5 oct, ' AДP=',
                          addr.i:5 oct);
                    if flag then {
                        (* typo here, addr must be dereferenced *)
                        write(' PTR=', addr.i:5 oct);
                        addr := addr.p@;
                    };
                    printWord(addr.p@, [fmt]);
                    writeLN;
                    checkRestart;
                }
        until ret or (varname = []);
    };
    findIdent := ret;
    if ret then {
        foundFrame := frameptr;
        foundUnused[1] := startDescr;
        foundUnused[2] := curDescr;
        valptr.i := ord(frameptr) + curDescr.r2@.attrs.data;
    }
};

{ (* checkValue *)
    if foundProc.i <> 0 then {
        frameptr := foundProc.r2;
        ret := findIdent;
        exit (* suspect *)
    };
    with regs@ do { }; (* useless *)
    case getFrame(where) of
    statFrame: {
        level := nesting + 1;
        ret := false;
        while not ret and (level > 1) do {
            level := level - 1;
            frameptr := regs@.idx[level];
            ret := findIdent;
        }
    };
    thisFrame:  ret :=   findIdent;
    dynFrame: (loop) {
        ret :=   findIdent;
        if not ret then {
            if frameptr = regs@.idx[1] then
                exit loop
            else {
                frameptr := frameptr@.next;
                goto loop;
            }
        } else exit loop;
    };
    noFrame: ret := false;
    end;
    checkValue := ret;
};

procedure allocConds(howmany: integer);
var cnt:integer;
{
with PASDDC do {
 if (usedPoints >= 20) then err(errManyPoints );
 usedPoints := usedPoints + 1;
 curpoint := ;
 cnt := usedConds;
 if cnt + howmany > 40 then err( errManyConds );
 with points[curpoint] do {
	startCond := cnt + 1; 
	nConds := howmany
 };
 usedConds := cnt + howmany;
};
};
procedure delPoint(arg:integer);
var condcnt, point, cond:integer; totPoints:integer;
pointptr: @pointrec; endCond:integer;
{
if arg <> 0 then with PASDDC do {
    condcnt := points[arg].startCond;
    totPoints := PASDDC.usedPoints;
    for point := arg + 1 to totPoints do {
        points[point-1] := points[point];
        pointptr := ref(points[point]); (* imitating buggy with *)
        endCond := pointptr@.startCond + pointptr@.nConds - 1;
        for cond := pointptr@.startCond to endCond do {
            conds[condcnt] := conds[cond];
            condcnt := condcnt + 1;
        }
    };
    usedPoints := usedPoints - 1;
    curpoint := 0;
    usedConds := condcnt - 1;
}
};
procedure getNesting;
var loc: integer;
{
    for loc := 1 to 6 do with regs@ do
        if (idx[loc] = idx[7]) then {
            nesting := loc;
            exit
        };
    err(errStack);
};
function stopNow: boolean;
label 1421;
var
    condidx: integer;
    endcond: integer;
    curval: integer;
    triggered: boolean;
    stop: boolean;
    curtime: real;
    unused1, unused2: char;
{
    with PASDDC, regs@ do {
        curpoint := usedPoints;
        stop := false;
        foundProc.i := 0;
        curtime := 0.0;
        verbMatch := false;
        while (curpoint > 0) and not stop do {
            with points[curpoint] do {
                 condidx := 1; (* should be startCond? *)
                 stop := true;
                 endcond := nConds + startCond;
            };
            while condidx < endcond do with conds[condidx] do {
                case cmode of
                lineRange: {
                    triggered := (startLn <= curline) and
                                 (curline <= endLn);
                };
                elapsedTime: {
                    if curtime = 0.0 then curtime := time;
                    triggered := curtime >= minTime;
                };
                idxValue: {
                    curval := ord(idx[num]);
1421:
                    case rel of
                    '<': triggered := curval < target.i;
                    '=': triggered := curval = target.i;
                    '>': {
                        triggered := curval > target.i;
                    };
                    end;  
                };
                varValue: {
                    triggered := checkValue(name, where);
                    if triggered then {
                        curval := valptr.p@.i;
                        goto 1421
                    }
                };
                inProc: triggered := checkProc(procname, where);
                memValue: {
                    curval := addr.p@.i;
                    goto 1421;
                };
                stopAfter: {
                    if count > 0 then count := count-1;
                    triggered := count = 0;
                };
                end;
                stop := stop and triggered;
                if not stop then condidx := endcond;
                condidx := condidx + 1;
            };
            if not stop then curpoint := curpoint - 1;
        };
    };
    stopNow := stop;
};
procedure zeroByte; { write('_000'); writeln };
procedure printPoint(arg:integer);
label 1604;
var curcond, endCond, minus1: integer;
{
    minus1 := -1;
    with PASDDC, points[arg] do {
        curcond := startCond;
        endCond := curcond + nConds;
        (loop) with conds[curcond] do {
            if where <> minus1 then {
                write('/L ', where:1, ', ');
            };
            case cmode of
            memValue: {
                write('/', addr:5 oct);
1604:                
                write(rel:2, ' ');
                printWord(target, [] );
            };
            idxValue: {
                write('/I ', num:2);
                goto 1604;
            };
            varValue: {
                PASTPR (name);
                goto 1604;
            };
            lineRange: {
                write(startLn:1, ':');
                if (endLn = INFINITY) then 
                    write( '_044' )
                else
                    write(endLn:1);
            };
            elapsedTime: write('/T ', time:1:21);
            inProc: {
                write('/P ');
                PASTPR (procname);
            };
            stopAfter:  write('/S ', count:1);
            end;
            curcond := curcond + 1;
            if curcond < endCond then {
                write(', ');
                goto loop;
            }
        }
    };
    (q) { writeln; exit q }
};
procedure whereAmI;
{
    with PASDDC, regs@ do {
        write(' .CTP =', curline:1);
        idx7.i := ord(idx[7]);
        thisdescr.i := idx7.r2@.attrs.descr;
        curproc := [];
        write(' ПP/ФYH=');
        if thisdescr.i <> 0 then {
            curproc := thisdescr.p@.m;
            PASTPR (curproc);
        } else {
            write(' БEЗ (*=P+ ');
        };
        if verbose then {
            write(' AДP=', idx[13]:5 oct, ' CYM=', acc:17 oct);
        }
    }
};
procedure printStatus; var i, fin: integer;
{
    whereAmI; writeln;
    writeln(' CПИCOK CTOП TOЧEK. NL=', PASDDC.curline:1);
    with PASDDC do ;
    fin := PASDDC.usedPoints;
    for i to fin do {
        write(' .', i:2, ' ');
        printPoint(i);
    }
};
procedure greeting; {
 whereAmI;
 case dbg of
      dbgCheck: printPoint(curpoint);
      dbgInteractive: write('WHAT=D');
 end;
 zeroByte;
};

procedure clearPoints; {
    with PASDDC do {
        verbose := true;
        usedPoints := 0;
        usedConds := 0;
        outFmt := [fInt, fOct2];
        inFmt := [fInt];
    }
};
procedure interact;
label 3030, 3075, 3121, 3222, 3256;
var
unused: word;
condno: integer;
ii: integer;
ident: bitset;
continue: boolean;
somename: bitset;
rangeStart, rangeEnd, modifier: integer;
modify: boolean;
ptr1: @pointrec;
ptr2: @condrec;
procedure printLineRange(source, startLine, endLine: integer);
var
    wordcnt, pos, i, unused: integer;
    line: record case boolean of
        false:(a:array[1..16] of alfa);
        true:(c:packed array[1..96] of char)
    end;
    unpackedLine: array[1..96] of char;
    f: file of alfa;
procedure readSrcLine;
var unused1, unused2: char;
{
    wordcnt := 0;
    repeat
        if eof(f) then err(13);
        if wordcnt = 16 then err(14);
        wordcnt := wordcnt + 1;
        line.a[wordcnt] := f@;
        get(f);
    until line.a[wordcnt][6] = '_012';
};
procedure expand;
var
    i, j, spaces, pos:integer;
    curch:char; charcnt:integer;
procedure putchar;
{
    if pos < 80 then {
        pos := pos + 1;
        unpackedLine[pos] := curch;
    } else if (pos <> 80) or (curch <> ' ') then 
        err(17);
};
{ (* expand, SC line 474 *) (q)exit q;
    pos := 0;
    charcnt := 6 * wordcnt;
    (loop) for i to charcnt do {
        curch := line.c[i];
        if curch > '_200' then {
            spaces := ord(curch) - 128;
            curch := ' ';
            for j to spaces do 
                putchar;
        } else {
            if curch = '_012' then exit loop;
            putchar;
        }
    };
    if pos <> 80 then err(15);
};
{ (*printLineRange *)
    reset(f, source);
    lineno := 1;
    repeat readSrcLine until line.c[1] <> '*';
    while (lineno <= endLine) do {
        if (lineno >= startLine) then {
            expand;
            write(lineno:4, ' ');
            for pos := 73 to 80 do
                write(unpackedLine[pos]);
            write(' ');
            (loop) for pos := 72 downto 1 do {
                if (unpackedLine[pos] <> ' ') then {
                    for i := 1 to pos do
                        write(unpackedLine[i]);
                    exit loop;
                }
            };
            writeLN;
            checkRestart;
        };
        readSrcLine;
        lineno := lineno + 1;
    };
};

function getOctal(limit:integer):integer;
var ret, digit: word;
    i, len, fill: integer;
{
    skipSpaces;
    if not isDigit then err(errNoInteger);
    len := 0;
    ret.i := 0C;
    while isDigit do {
        len := len + 1;
        ret := ret;
        besm(360075B); (* SHL 3 *)
        ret := ;
        digit.i := ord(ch);
        if ch > '7' then err(err89InOctal);
        if (len > 16) then err(errTooLarge);
        nextchar;
        ret.m := ret.m + digit.m * [45:47];
    };
    numlen := len;
    case ch of
    'T': {
        nextchar;
        fill := 16 - len;
        for i to fill do {
            ret := ret;
            besm(360075B); (* SHL 3 *)
            ret := ;
        }
    };
    'C': nextchar;
    others: {
         if ch = 'B' then nextchar;
         if ret.m * [0:6] <> [] then err(errTooLarge);
         ret.m := ret.m + [0,1,3];
         if (limit <> 0) and (ret.i > limit) then
             err(errTooLarge);
    }
    end;
    getOctal := ret.i;
    skipSpaces;
};
function nextOctal(limit:integer):integer;
{
    nextChar;
    nextOctal := getOctal(limit);
};
function getRelation: char;
{
    skipSpaces;
    if (ch = '<') or (ch = '=') or (ch = '>') then
        getRelation := ch
    else
        err(errBadSign);
    nextAndSkip;
};
procedure getLineRange(var arg:condrec);
var start, fin: integer;
{
    start := getDecimal;
    skipSpaces;
    case ch of
        ':': fin := nextDecimal;
        '+': fin := nextDecimal + start;
        others: fin := start;
    end;
    with arg do {
        startLn := start;
        endLn := fin;
        cmode := lineRange;
    }
};
function getWord:word;forward;
procedure displayRange;
var addr, value, unused: word;
{
    addr.i := rangeStart;
    writeln;
    if modifier <> 0 then {
        addr.i := ord(regs@.idx[modifier]) + addr.i;
    };
    if somename <> [] then {
        write(' ');
        PASTPR (somename);
    };
    repeat 
        write(' ', addr.i:5 oct, ': ');
        printWord (addr.p@, []);
        checkRestart;
        if modify then {
            write(':='); zeroByte;
            PASRED(red);
            red.charcnt := 0;
            nextchar;
            if not red.endl then {
                if ch = '.' then exit;
                value := getWord;
                addr.p@ := value;
            } else writeln;
        } else writeln;
        addr.i := addr.i + 1;
    until (rangeEnd < addr.i);
};
procedure readRange;
{
    somename := [];
    rangeStart := getOctal(77777B);
    if ch = '(' then {
        modifier :=   nextOctal(15);
        if ch = ')' then nextAndSkip;
    } else {
        modifier := 0;
    };
    case ch of
    '+': rangeEnd := nextOctal(100) + rangeStart;
    ':': rangeEnd := nextOctal( 00077777B );
    others: rangeEnd := rangeStart;
    end;
    modify := ch = '<';
};
function getWord;
var
fmts: formats;
ret: word;
curfmt: format;
function getReal:real;
var unused, ret:real; f: text; 
{
    while not red.endl do {
        write(f, ch);
        nextchar
    };
    write(f, ' ':5, '*');
    reset(f);
    read(f, ret);
    getReal := ret;
};
function getInsn:insn;
var ret:insn; op:integer;
{
    ret.reg := getOctal(15);
    op := getOctal (255);
    if numlen = 3 then {
        ret.insn1 := op;
        ret.saddr := getOctal(7777B);
    } else {
        ret.insn2 := op;
        ret.laddr := getOctal(77777B);
    };
    getInsn := ret;
};
{ (* getWord *)
    with PASDDC do fmts := inFmt;
    if isLetter then getFormats(fmts);
    (*=c-*)curfmt := chr(minel(fmts));(*=c+*)
    case curfmt of
    fOct2: ret.i := getOctal(0);
    fInt: ret.i :=  getDecimal;
    fAlfa: {
        for ii to 6 do {
            ret.a[ii] := ch;
            nextchar
        }
    };
    fBytes: {
        for ii to 6 do 
            ret.a[ii] := chr(getOctal(377B));
    };
    fReal: ret.r := getReal;
    fInsn: {
        ret.k[1] := getInsn;
        ret.k[2] := getInsn
    };
    others: err(errSystem);
    end;
    getWord := ret;
};
{ (* interact *)
    continue := false;
    verbMatch := false;
    repeat with regs@, PASDDC do {
        red.buflen := 80;
        write(' < '); zeroByte;
        PASRED(red);
        red.charcnt := 0;
        nextChar;
        if not red.endl then {
        if ch = '.' then {
            curcond.where := (7);
            condno := PASDDC.usedConds;
            (loop) {
                nextAndSkip;
                if isDigit then getLineRange(curcond)
                else if ch = '/' then {
                    nextAndSkip;
                    if isDigit then {
                        curcond.cmode := memValue;
                        curcond.addr.i := getOctal(77777B);
                        goto 3030;
                    } else { (* 2773 *) 
                        case ch of
                        'L': {
                            curcond.where := nextDecimal;
                            goto 3075;
                        };
                        'S': {
                            curcond.count := nextDecimal;
                            curcond.cmode := stopAfter;
                        };
                        'T': {
                            curcond.cmode := elapsedTime;
                            curcond.minTime := time + nextDecimal;
                        };
                        'P': {
                            curcond.cmode := inProc;
                            nextAndSkip;
                            curcond.procname := getName;
                            writeln(curcond.where:10);
                        };
                        'I': {
                            curcond.cmode := idxValue;
                            curcond.num := nextDecimal;
3030:
                            curcond.rel := getRelation;
                            curcond.target := getWord;
                        };
                        others: err(errAfterSlash);
                        end;
                    };
                } else { (* 3046 *)
                    if isLetter then {
                        curcond.cmode := varValue;
                        curcond.name := getName;
                        goto 3030;
                    } else (q) { err(errBadRequest); exit q }
                };
                condno := condno + 1;
                if condno > 40 then err(errManyPoints);
                PASDDC.conds[condno] := curcond;
                skipSpaces;
3075:
                if (ch = ',') and not red.endl then
                   goto loop;
            };
            if not red.endl then err(errBadRequest);
            if condno <> PASDDC.usedConds then
                allocConds(condno - PASDDC.usedConds);
        } else  (* 3111 *)
            if ch = ' ' then {
                nextAndSkip;
                if red.endl then printStatus;
                getNesting;
                curcond.where := nesting;
3121:
                skipSpaces;
                if red.endl then goto 3256;
                if isDigit then {
                    getLineRange(curcond);
                    printLineRange(PASDDC.source,
                           curcond.startLn, curcond.endLn);
                } else { (* 3135 *)
                    if ch = '/' then {
                        nextAndSkip;
                        case ch of
                        'L': curcond.where := nextDecimal;
                        'D': { PASPMD; nextChar };
                        'T': {
                            write(' TUSED=', time:12:22, ' SEC.');
                            nextchar;
                        };
                        'I': {
                            writeln; nextchar;
                            write(' /I  1.. 7=');
                            for ii := 1 to 15 do {
                                write(' ':2,
                                    regs@.idx[ii]:5 oct);
                                if (ii = 7) then {
                                    writeln; 
                                    write(' /I  8..15=');
                                };
                            };
                            writeln;
                        };
                        'P': {
                            nextAndSkip;
                            ident := getName;
                            verbMatch := true;
                            verbMatch:=checkProc(ident, curcond.where);
                            verbMatch := false;
                        };
                        'V': {
                            nextAndSkip;
3222:                       
                            foundProc.i := 0;
                            ident := getName;
                            verbMatch := true;
                            verbMatch:=checkValue(ident,curcond.where);
                            verbAddr := true;
                            verbMatch := false;
                        };
                        others: err(1);
                        end;
                    } else { (* 3247 *)
                        if isLetter then {
                            verbAddr := false;
                            goto 3222
                        };
                        err(1);
                    };
                };
                goto 3121; 3256:
            } else (* 3257 *)
                if ch = '-' then {
                nextAndSkip;
                case ch of
                '-': {
                    clearPoints;
                    writeln('  BCE . YДAЛEHЫ');
                };
                others: {
                    if isDigit then {
                        ii := getDecimal;
                        if PASDDC.usedPoints < ii then
                            err(errTooLarge);
                        delPoint(ii);
                    } else err(errBadPrintType); (* ??? *)
                };
                '+': {
                    delPoint(curpoint);
                    (q) exit q; (q) exit q; (* for address sync *)
                }    
                end;
            } else { (*3320*)
                if ch = 'O' then rgexport := getOctal(3)
                else if ch = 'U' then {
                    nextAndSkip;
                    PASDDC.verbose := ch = '+';
                } else if ch = 'F' then {
                    nextAndSkip;
                    PASDDC.source := getOctal(7777777777B);
                    writeln(' FILE=', PASDDC.source:10 oct);
                } else if isDigit then {
                    readRange; displayRange
                } else if ch = 'W' then {
                    nextchar;
                    getFormats(PASDDC.outFmt);
                } else if ch = 'R' then {
                    nextchar;
                    getFormats(PASDDC.inFmt);
                    if card(PASDDC.inFmt) <> 1 then {
                        err(errOnlyOneOSIRBAC);
                        PASDDC.inFmt := [fInt];
                    }
                } else if ch = '!' then {
                    if PASDDC.usedPoints = 0 then
                        PASDDS := dbgFreeRun;
                    continue := true;
                } else if ch = '@' then {
                    delPoint(curpoint);
                    allocConds(1);
                    continue := true;
                    ptr1 := ref(PASDDC.points[curpoint]);
                    ptr2 := ref(PASDDC.conds[ptr1@.startCond]);
                    ptr2@.where := 7;
                    ptr2@.cmode := lineRange;
                    ptr2@.startLn := PASDDC.curline + 1;
                    nextAndSkip;
                    if red.endl then
                        ii := INFINITY
                    else
                        ii := getDecimal;
                    ptr2@.endLn := ptr2@.startLn + ii;
                } else
                    err(errBadRequest);
            }
        }
    } until continue;
};

{ (* pasdd1 *)
    PASDDC.curline := ord(regs@.i14);
    dbg := PASDDS;
    curpoint := 0;
    getNesting;
    verbAddr := true;
    case dbg of
    dbgStart: {
        PASDDC.source := 30270000B;
        writeln(boilerplate);
        PASISOCD;
        clearPoints;
        goto 3474
    };
    dbgInteractive: {
3474: 
        greeting;
        PASDDS := dbgCheck;
3477:
        interact; 
    };
    dbgCheck: if stopNow then goto 3474;
    end;
};
{
pasdd1;
}.
