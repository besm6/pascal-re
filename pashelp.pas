(*=s8,p-,t-,y+*)
(*=d8,p+*)
program pashelp(
    input, 
    cod 1100000B, output,
    filkat 2210000B,
    (*=s1*)flgex,
    isoptext,
    entry(*=s0*)
);
label 9999;
const 
    errBadPrintMode = 0;
    errNoSubName = 1;
    errNoSecondParam = 2;
    errNoExtFile = 3;
    errEmptyList = 4;
    errConstTooMany = 5;
    errFilesTooMany = 6;
    errUsage = 7;
    errNoPeriod = 8;
    errBadParam = 9;
    errPagesTooMany = 10;
    errBadBuffer = 11;
type 
    MH = SET OF 0..47;
    word = record case integer of 
        0: (i: integer);
        1: (c: char);
        2: (m: MH)
    end;
    REC = array [0..1] of MH;
    kat = array [0..1000] of REC;
    token = (charPeriod, charOther, octNumber, decNumber, textName);
    ECMA = 0..63;
    code = array [0..100] of word;
var
    entry: array[0:0] of word;
    cod: file of char;
    isoptext: packed array['*'..'_177'] of ECMA;
    flgex: integer;
    curToken: token;
    numValue, temp, idx, count, parnum, charCnt: integer;
    lastChar, prevChar, printMode, curChar, command, savedName: char;
    nameValue: char;
    fileBind, pasContr, runData, bufferBind: code;
    inputCopy: text;
    filkat: file of kat;

procedure pasisocd; external;
procedure pasmon2; external;
function paslist:integer; fortran;

function getch:char;
var c:char;
{ (loop) {
    c := input@; get(input);
    charCnt := charCnt + 1;
    if ((prevChar <> ' ') or (c <> ' ')) and (72 >= charCnt) then
        write(inputCopy, c);
    prevChar := c;
    getch := c;
    if eoln(input) then {
        charCnt := 0; goto loop
    };
    if charCnt > 72 then
        goto loop;
} };

procedure printErr(err:integer);
{
    write(' ОШИБКА:');
    case err of 
    errBadPrintMode:
        write(' PEЖИM ПEЧATИ - ЭTO ЦEЛOE OT 0 ДO 3');
    errNoSubName:
        write(' HET ИMEHИ БУДУЩEЙ ПП');
    errNoSecondParam:
        write(' HET BTOPOГO ПAPAMETPA');
    errNoExtFile:
        write(' HET AДPECA BHEШHEГO ФAЙЛA ИЛИ OH HEПPABИЛEH');
    errEmptyList:
        write(' CПИCOK TEKCTOBЫX KOHCTAHT ПУCTOЙ');
    errConstTooMany:
        write(' TEKCTOBЫX KOHCTAHT БOЛЬШE 50');
    errFilesTooMany:
        write(' PASHELP CBЯЗЫBAET HE БOЛEE 4 ФAЙЛOB');
    errUsage: { 
        writeln(' ПEPBЫM УПPABЛЯЮЩИM CИMBOЛOM ДЛЯ PASHELP');
        writeln('    ДOЛЖHЫ БЫTЬ P ИЛИ R  ИЛИ T');
    };
    errNoPeriod:
        write(' ЛИБO HET TOЧKИ, ЛИБO HET ИMEHИ ФAЙЛA');
    errBadParam:
        write(' HET ', parnum:0, ' ПAPAMETPA ИЛИ HEПP. TИП ПAPAM');
    errPagesTooMany:
        write(' CЛИШKOM MHOГO ЛИCTOB');
    errBadBuffer:
        write(' HEПP 3-Й ПAP. (HAЧ CЛOBO OБMEHA)');
    end;
    writeln;
    goto 9999;
};
procedure saveCode(var arg:code; count: integer);
{ 
    rewrite(cod); rewrite(cod); rewrite(cod);
    for temp := 0 to count do 
        write(cod, arg[temp].c); 
    pasmon2;
};

procedure checkEnd;
{
    if curToken<>charPeriod then
        printErr(errNoPeriod)
};

function readToEnd : boolean;
var
    dummy:integer;
    string:array[1..20] of char;
    zero: integer;
    curName: packed array[0..7] of ecma;

function isDigit:boolean;
{
    isDigit:=(curChar>='0') and ('9'>=curChar)
};

function isText : boolean;
{
    isText := (curChar = '*') or (curChar = '/') or isDigit
        or ((curChar >= 'A') and (curChar <= 'Z'))
        or ((curChar >= chr(140B)) and (curChar <= chr(176B)));
};

{ (* readToEnd *)
    readToEnd := false;
    while ((curChar = ' ') or eoln(input)) do curChar := getch;
    if (isDigit) then {
        numValue := 0;
        count := 0;
        temp := 10;
        curToken := decNumber;
 
        while (isDigit) do {
            count := count + 1;
            string[count] := curChar;
            curChar :=   getch;
        };
 
        if curChar = 'B' then {
            temp := 8;
            curToken := octNumber;
            curChar := getch;
        };
        for idx to count do 
            numValue := temp * numValue + ord(string[idx]) - 48;
    } else if isText then {
        curToken := textName;
        numValue := 0;
        zero := 0C;
        curName := ;
        while isText do {
            if numValue <> 8 then {
                curName[numValue] := ISOPTEXT[curChar];
                numValue := numValue + 1;
            };
            curChar :=   getch;
        };
        curName := curName;
        nameValue := ;
    } else if curChar = '.' then {
        curToken := charPeriod;
        readToEnd := true;
    } else {
        curToken := charOther;
        lastChar := curChar;
        curChar :=   getch;
    };
    parnum := parnum + 1;
};

function makeDescr: char;
{
    if (curToken = decNumber) and 
    ((numValue = 50) or (numValue = 51)) then {
        makeDescr := chr(numValue * 1000B + 200B);
    } else {
        if (curToken  = decNumber) and (numValue = 0) then
            makeDescr := chr(0)
        else if (curToken  = octNumber) and
                (numValue >= 01100000B) and
                (1743671743B >= numValue) then
            makeDescr := chr(numValue * 1000B + 400B)
        else
            printErr(errNoExtFile);
    }
};

function getDescr: char;
{
    if readToEnd then
        printErr(errNoExtFile);
    getDescr := makeDescr
};

function getPrintMode: boolean;
{
    printMode := chr(numValue);
    getPrintMode := (curToken = decNumber) and
        (numValue >= 0) and (numValue <= 3);
};

procedure genRun;
label 1;
var dummy, offset: integer;
{
    if readToEnd or (curToken <> textName) then
        printErr(errNoSubName);

    runData[34].c := nameValue;
    if readToEnd then
        printErr(errNoSecondParam);
    if (curToken = charOther) and (lastChar = '+') then {
        dummy := 62000000000000C;
        runData[16] := ;
        if readToEnd then
            goto 1;
    };
   
    if (getPrintMode) then { 
        runData[18].c := printMode;
        if readToEnd then
            goto 1;
    };
    offset := 19;
    while (curToken = textName) do {
        if offset >= 27 then
            printErr(errFilesTooMany);
        runData[offset].c := nameValue;
        offset := offset + 1;
        runData[offset].c := getDescr;
        offset := offset + 1;
        if (readToEnd) then
            goto 1;
    };
1:
    if (curToken <> charPeriod) then
        printErr(errNoPeriod);
    saveCode(runData, 35);
};

procedure pasCtrl;
{
    if readToEnd then
        writeln(' PASCONTR BE USUAL')
    else {
        if getPrintMode then
            pasContr[16].c := printMode
        else
            printErr(errBadPrintMode);
        if readToEnd then
            printErr(errNoSecondParam);
        if curToken IN [octNumber,decNumber] then {
            numValue := numValue;
            pasContr[17] := ;
        };
        pasContr[15].c := getDescr;
    };
    saveCode(pasContr, 24);
};

(* using pasContr array as a code buffer *)
procedure genConst;
var i:integer;
{
    if readToEnd or (curToken <> textName) then
        printErr(errNoSubName);
    savedName := nameValue;
    i := 10;
    while not readToEnd do {
        if curToken <> textName then
            printErr(errEmptyList);
        pasContr[i].c := nameValue;
        i := i + 1;
        if 50 < i then
            printErr(errConstTooMany);
    };
    if i = 10 then
        printErr(errNoSubName);
    pasContr[i].i := 0C;
    for count to 9 do
        pasContr[count].i := 0C;
    pasContr[7].c := chr(i - 9);
    i := i + 1;
    pasContr[i].c := savedName;
    saveCode(pasContr, i);
};

procedure Remove;
var
    i, j:integer; 
    name, mask2, mask3, time, pslash, pas, pro, cur, zero:MH;
    catalog:kat;
{ 
    catalog := filkat@;
    rewrite(filkat);
    zero := [];
    i := 6017000000000000C(*"P/      "*);
    pslash := ;
    i := 6041630000000000C(*"PAS     "*);
    pas := ;
    i := 6062570000000000C(*"PRO     "*);
    pro := ;
    i := 6451554500000000C(*"TIME    "*);
    time := ;
    j := 1;
    i := 1;
    (loop) {
        name := catalog[i][0];
        cur := ;
        mask2 := cur * [0..11];
        mask3 := cur * [0..17];
        if cur = zero then {
            catalog[j] := catalog[i];
            filkat@  := catalog;
            put(filkat);
            writeln(' YБPAHO ', i-j:0);
            exit loop;
        };
        if (cur = time) or
           (mask2 = pslash) or
           (mask3 = pas) then {
           i := i + 1;
        } else {
           catalog[j] := catalog[i];
           i := i + 1;
           j := j + 1;
        };
        goto loop
    }
};

procedure bindBuffers;
var i, j: integer;
procedure getOctal;
{ 
    if readToEnd or (curToken <> octNumber) then
        printErr (errBadParam)
}; 
{ (* bindBuffers *)
    for i to 3 do {
        getOctal;
        bufferBind[i+10].c := chr(numValue);
    };
    i := ord(bufferBind[11].c);
    if i = 0 then 
        bufferBind[22].i := 40000000C
    else 
        bufferBind[22].c := chr(2000B * i + 401167400000B);

    if i > 5 then
        printErr(errPagesTooMany);
    i := ord(bufferBind[13].c);
    if i > 270020B then
        printErr(errBadBuffer);
    if PASLIST <> 0 then {
        writeln(' PAGES=', bufferBind[11]:1 oct, 
                'B.DRUMS=', bufferBind[12]:3 oct,
                'B.INITIAL DRUM=', bufferBind[13]:6 oct, 'B');
    };
    saveCode(bufferBind, 30);
};

procedure bindFiles;
label 1;
var
    length, avail, start:integer;
    work1, work2:MH;
{
    avail := 25;
    while not readToEnd and (curToken = textName) do {
        savedName := nameValue;
        start := 15;
        while start <> avail do {
            if fileBind[start].c = savedName then
                goto 1;
            (compat) start := start + 2;
        };
        avail := avail + 2;
1:
        fileBind[start].c := savedName;
        fileBind[start+1].c := getDescr;
    }; (* while *)
    fileBind[avail].i := 0C;
    length := avail + 1;
    start := avail + (-14);
    fileBind[8].c := chr(start);
    besm(360100B-36);
    work1 := ;
    command := fileBind[90].c;
    work2 := ;
    work2 := work2 + work1;
    fileBind[length] := ;
    length := length + 1;
    fileBind[length] := fileBind[94];
    if start < 15 then
        start := 15;
    fileBind[length+1].c := chr(ord(fileBind[91].c)+start);
    fileBind[length+2] := fileBind[92];
    fileBind[length+3] := fileBind[93];
    checkEnd;
    saveCode(fileBind, length + 3);
};

procedure notImpl;
{
    writeln(' ПOKA HE PEAЛИЗOBAHO');
    printErr(errUsage);
};

{
    pasisocd;
    charCnt := 0;
    parnum := 0;
    while input@ = ' ' do
        get(input);
    command :=   getch;
    curChar :=   getch;
    if command = 'D' then bindBuffers
    else if command = 'Y' then Remove
    else if command = 'P' then pasCtrl
    else if command = 'R' then genRun
    else if command = 'O' then notImpl
    else if command = 'F' then bindFiles
    else if command = 'T' then genConst
    else (q) {
        printErr(errUsage);
        exit q
    };
    if PASLIST <> 0 then {
9999:
        reset(inputCopy);
        write(' ');
        while not eof(inputCopy) do {
            write(inputCopy@);
            get(inputCopy)
        };
        writeln;
    };
}
.data 
 fileBind := 1C, 2C, 0C, 0C, 1C, 5C, 0C, 0C, 11C, 1C,
 7247400102200000C,
 7010000066600000C,
 412000302740004C,
 7010000167000000C,
 7250000203040001C,
 1257656460656412C(*"*OUTPUT*"*),
 63200C,
 1251566065641200C(*"*INPUT* "*),
 62200C,
 6041635156606564C(*"PASINPUT"*),
 62200C,
 1262456365546412C(*"*RESULT*"*),
 27270000400C,
 1243505154441200C(*"*CHILD* "*),
 27100000400C, 0C:20;

 fileBind[90] := 400200014001C,
  400367000000C,
  41000005C,
  6041634570466412C(*"PASEXFT*"*),
  6017424570460000C(*"P/BEXF  "*);

prevChar := '1';

 pasContr := 1C,3C,0C:2,3C,4C,0C,4C,0C:2,
 7244000470100002C,
 227400300000000C,
 7010000302274001C,
 303074002C,
 6041635156606564C(*"PASINPUT"*),
 62200C,
 3C,
 0,
 6041634357566462C(*"PASCONTR"*),
 400567000022C,
 400663000000C,
 400467000001C,
 6247457060576264C(*"RGEXPORT"*),
 6041635156465762C(*"PASINFOR"*),
 6017634564457046C(*"P/SETEXF"*);

 ENTRY   := [], [8,32];
 runData := 1C, 3C, 0C:2, 3C, 10C, 0C, 12C, 0C:2,
  7244001070100000C,
  0227400100000000C,
  6444001272500001C,
  7010000002640006C,
  6717400202200000C,
  7250000203040003C,
  220000002200000C,
  5044001503074003C,
  2C, 0C:9,
  6062574762415500C(*"PROGRAM "*),
  400467000001C,
  400563000000C,
  400663000000C,
  6247457060576264C(*"RGEXPORT"*),
  6017634564457046C(*"P/SETEXF"*),
  0C;

 bufferBind := 1C,10C,0C:2,4C,1C,0C:2,3C:2,
 4647400573000000C,
 1C,
 20C,
 250000C,
 1400600014001C,
 1400700014003C,
 1401000014002C,
 6017604147456300C(*"P/PAGES "*),
 401267000001C,
 401467000001C,
 401367000001C,
 40004000C,
 0C,
 41000003C,
 41000001C,
 41000002C,
 6017465162600000C(*"P/FIRP  "*),
 6041634462655512C(*"PASDRUM*"*),
 6041636041475612C(*"PASPAGN*"*),
 6041634462561200C(*"PASDRN* "*);
 flgex := 2C;
end
