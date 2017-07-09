#!/usr/bin/env perl
undef $/;

$prog = <>;
$prog =~ s/\n /;/g;

# Normalising labels

$prog =~ s/;([^:']+:)/;\1,BSS,;/g;

# Recognizing subroutines

sub nopar {
my ($l, $n) = @_;
return $n==1 ? 
": Level $l procedure with no parameters and no locals;" :
": Level $l procedure with no parameters and ".($n-1)." locals (or a func with ".($n-2)." locals);";
}

$prog =~ s@,BSS,;14,VJM,P/(\d) *;15,UTM,(\d+);@nopar($1,$2)@eg;

$prog =~ s@,BSS,;15,ATX,3;14,VJM,P/(\d) *;15,UTM,(\d+);@": Level $1 procedure with 1 parameter and ".($2-2)." locals;"@eg;

$prog =~ s@,BSS,;15,ATX,4;14,VJM,P/(\d) *;15,UTM,(\d+);@": Level $1 function with 1 parameter and ".($2-3)." locals;"@eg;

$prog =~ s@,BSS,;15,ATX,;15,UTM,-(\d+);14,VJM,P/(\d) *;15,UTM,(\d+);@": Level $2 procedure with ".($1-3)." parameters and ".($3-$1+2)." locals (or a func with ".($1-4)." parameters);"@eg;

$prog =~ s@,BSS,;,NTR,7; :,BSS,;13,MTJ,(\d);@: Level \1 procedure with no frame;@g;

# Converting shortcuts to standard subroutine calls

$prog =~ s@13,VTM,([^;]+);,UJ,([^;]+);@13,VJM,\2;,UJ,\1;@g;


# Converting global variables addressed via index register 1

$prog =~ s@;1,([^M][^M][^M]),(\d+)@;,$1,glob$2z@g;

# Converting global variable references (block P/1D) in the data setting section

$prog =~ s@P/1D *\+(\d+)@glob\1z@g;

# Recognizing known pre-seeded constants in the global area

$prog =~ s@glob8z@e1@g;
$prog =~ s@glob9z@int(0)@g;
$prog =~ s@glob10z@multmask@g;
$prog =~ s@glob12z@e40to1@g;
$prog =~ s@glob15z@int(-1)@g;
$prog =~ s@glob17z@int(1)@g;
$prog =~ s@glob18z@p77777@g;
$prog =~ s@glob19z@half@g;
$prog =~ s@glob20z@vseed@g;

# Known globals

$prog =~ s@glob50z@inStringLit@g;
$prog =~ s@glob55z@SY@g;
$prog =~ s@glob65z@maxLineLen@g;
$prog =~ s@glob86z@CH@g;
$prog =~ s@glob66z@linePos@g;
$prog =~ s@glob74z@lineCnt@g;
$prog =~ s@glob89z@lineNesting@g;
$prog =~ s@glob598z@lineBufBase@g;
$prog =~ s@glob729z@errMapBase@g;
$prog =~ s@glob4761z@FCST@g;
$prog =~ s@glob58z@FcstCnt@g;
$prog =~ s@glob68z@errsInLine@g;
$prog =~ s@glob151z@litExternal@g;
$prog =~ s@glob152z@litForward@g;
$prog =~ s@glob153z@litFortran@g;
$prog =~ s@glob3650z@objBufBase@g;
$prog =~ s@glob78z@dynMemSize@g;
$prog =~ s@glob91z@objBufIdx@g;
$prog =~ s@glob96z@charEncoding@g;
$prog =~ s@glob99z@checkTypes@g;
$prog =~ s@glob108z@fuzzReals@g;
$prog =~ s@glob109z@fixMult@g;
$prog =~ s@glob80z@stmtName@g;
$prog =~ s@glob112z@allowCompat@g;
$prog =~ s@glob113z@checkFortran@g;
$prog =~ s@glob1477z@helperProcNameBase@g;
$prog =~ s@glob1378z@helperProcMapBase@g;
$prog =~ s@glob59z@symTabPos@g;
$prog =~ s@glob2470z@longSymTabBase@g;
$prog =~ s@glob2560z@longSymsBase@g;
$prog =~ s@glob1123z@symHashTabBase@g;
$prog =~ s@glob142z@hashMask@g;

#Recognizing known routines
$prog =~ s@\*0362B@putToSymTab@g;
$prog =~ s@\*0375B@allocExternal@g;
$prog =~ s@\*1046B@endOfLine@g;
$prog =~ s@\*1232B@nextCH@g;
$prog =~ s@\*1314B@parseComment@g;
$prog =~ s@\*1275B@readOptFlag@g;
$prog =~ s@\*1247B@readOptVal@g;
$prog =~ s@\*1377B@optionA@g;
$prog =~ s@\*1410B@optionB@g;
$prog =~ s@\*1402B@optionC@g;
$prog =~ s@\*1324B@optionD@g;
$prog =~ s@\*1335B@optionE@g;
$prog =~ s@\*1366B@optionF@g;
$prog =~ s@\*1413B@optionK@g;
$prog =~ s@\*1370B@optionL@g;
$prog =~ s@\*1406B@optionM@g;
$prog =~ s@\*1373B@optionP@g;
$prog =~ s@\*1404B@optionR@g;
$prog =~ s@\*1346B@optionS@g;
$prog =~ s@\*1375B@optionT@g;
$prog =~ s@\*1337B@optionU@g;
$prog =~ s@\*1333B@optionY@g;
$prog =~ s@\*1416B@optionZ@g;

$prog =~ s@\*0123B@printTextWord@g;
$prog =~ s@\*0207B@storeObjWord@g;
$prog =~ s@\*0223B@form1Insn@g;
$prog =~ s@\*0270B@form2Insn@g;
$prog =~ s@\*0277B@form3Insn@g;
$prog =~ s@\*0445B@toFCST@g;
$prog =~ s@\*1464B@inSymbol@g;
$prog =~ s@\*2476B@error@g;
$prog =~ s@\*2534B@skip@g;
$prog =~ s@\*2543B@test1@g;
$prog =~ s@\*2556B@errAndSkip@g;
$prog =~ s@\*24024@initOptions@g;
$prog =~ s@\*15220@forStatement@g;
$prog =~ s@\*15406@withStatement@g;
$prog =~ s@\*17157@writeProc@g;
$prog =~ s@\*17517@standProc@g;

# Converting local variables avoiding insns accessing registers
# (with M in their names)
# TODO: at level N, higher-numbered registers can be used as scratch.
# This should be recognized and conversion suppressed.

$prog =~ s@;([2-6]),([^M][^M][^M]),(\d+)@";,$2,l$1var".($3-3)."z"@eg;

# Converting indirect addressing

$prog =~ s@;,WTC,([^;]+);([^;]+)@;\2\[\1\]@g;
$prog =~ s@;,UTC,([^;]+);([^;]+)@;\2+(\1)@g;

# Reading the address of a variable
$prog =~ s@14,VTM,([^;]+);,ITA,14@,XTA,&\1@g;

# Recognizing a variety of write routines

$prog =~ s@12,VTM,.OUTPUT.;13,VJM,P/6A *@writeAlfa@g;
$prog =~ s@12,VTM,.OUTPUT.;13,VJM,P/7A *@writeString@g;

$prog =~ s@12,VTM,([^;]+);13,VJM,P/EO *@eof(\1)@g;
$prog =~ s@12,VTM,([^;]+);13,VJM,P/EL *@eoln(\1)@g;
$prog =~ s@12,VTM,([^;]+);13,VJM,P/GF *@get(\1)@g;
$prog =~ s@12,VTM,([^;]+);13,VJM,P/PF *@put(\1)@g;
$prog =~ s@12,VTM,([^;]+);13,VJM,P/RF *@reset(\1)@g;
$prog =~ s@12,VTM,([^;]+);13,VJM,P/TF *@rewrite(\1)@g;

# Converting NEW

$prog =~ s@14,VTM,(\d+);13,VJM,P/NW *;,ATX,([^;]+)@\2 := malloc(\1)@g;

# Converting calls (including scope-crossing calls)

$prog =~ s@13,VJM,([^;]+);13,VJM,P/\d\d@CALL \1@g;
$prog =~ s@13,VJM,([^;]+)(;7,MTJ,\d)?@CALL \1@g;

# Converting non-local GOTO

$prog =~ s@\d,MTJ,13;14,VTM,([^;]+);,UJ,P/RC *@GOTO \1@g;

$prog =~ s@,NTR,;,AVX,@toReal@g;

@ops = split /;/, $prog;

print "Got $#ops lines\n";

# Emulating a simple stack machine starting with XTA
# and ending with a non-recognized operation or a label. At that point the stack is
# dumped and reset.

$from = 0;
@stack = ();

@to = ();

sub dumpStack {
    push @to, '#' . join(' % ', @stack) if @stack;
    @stack = ();
}

while ($from <= $#ops) {
    my $line = $ops[$from];
    if (@stack && $line =~ m@13,VJM,P/MI@) {
        $stack[$#stack] = "mulFix($stack[$#stack])";
        ++$from;
        next;
    }
    if (@stack && $line eq 'toReal') {
        $stack[$#stack] = "toReal($stack[$#stack])";
        ++$from;
        next;
    }
    if (@stack >= 2 && $line =~ m@CALL P/IN@) {
        $stack[$#stack-1] = "($stack[$#stack] IN $stack[$#stack-1])";
        --$#stack;
        ++$from;
        next;
    }
    if (@stack && $line =~ /CALL /) {
        # This is not always correct; some values are put on the stack
        # to be consumed after the return from a subroutine.
        push @to, "$line( ".join(', ', @stack)." )";
        ++$from;
        @stack = ();
        next;
    }
    if (@stack >= 2 && $line =~ m@15,A([-/EROA+*])X,$@) {
        $op = $1;
        $op =~ tr/EROA/^$|&/;
        $stack[$#stack-1] = "($stack[$#stack] $op $stack[$#stack-1])";
        --$#stack;
        ++$from;
        next;
    }
    if ($line !~ /,[ASX].[ASX],/ || (@stack && $line =~ /:/)) {
        dumpStack() if @stack;
        push @to, $ops[$from++];
        next;
    }
    if ($line =~ /^,XTA,(.*)/) {
        if (@stack) { $stack[$#stack] = $1; }
        else { $stack[0] = $1; }
        ++$from;
    } elsif ($line =~ /15,XTA,$/) {
        ++$from;
        if (@stack) { --$#stack; }
        else { push @to, "!!! Popping empty stack at $from"; }
    } elsif (@stack && $line =~ m@^,A([-+*/EROA])X,(.*)@) {
        $op = $1;
        $op =~ tr/EROA/^$|&/;
        $stack[$#stack] = "($stack[$#stack] $op $2)";
        ++$from;
    } elsif (@stack && $line =~ m@^,X-A,(.*)@) {
        $stack[$#stack] = "($1 - $stack[$#stack])";
        ++$from;
    } elsif (@stack && $line =~/^,XTS,(.*)/) {
        $stack[++$#stack] = $1;
        ++$from;
    } elsif (@stack && $line =~ /^,ATX,(.*)/) {
        push @to, "$1 := $stack[$#stack]";
        # If there was just one element on the stack, consider it consumed
        @stack = () if @stack == 1;
        ++$from;
    } elsif (@stack && $line =~ /^,STX,(.*)/) {
        push @to, "$1 := $stack[$#stack--]";
        ++$from;
    } else {
        dumpStack() if @stack;
        push @to, $ops[$from++];
        next;
    }             
}

$prog = join ';', @to;

# Converting simple ops

$prog =~ s@,UJ,P/E *;@RETURN;@g;
$prog =~ s@,AVX,int\(-1\)@NEGATE@g;

#Restoring line feeds

$prog =~ s/;/\n /g;

print $prog;



