#!/usr/bin/env perl
undef $/;

$prog = <>;
$prog =~ s/\n /;/g;

$/=chr(10);

# Normalizing offsets

$prog =~ s/,;/,0;/g;

# Recognizing "convert to Boolean" sequences (before normalizing labels)
$prog =~ s@,UZA,([^;]+);,XTA,0;,UJ,([^;]+);\1:1,XTA,8;\2:@isUZACond;@g;
$prog =~ s@,U1A,([^;]+);,XTA,0;,UJ,([^;]+);\1:1,XTA,8;\2:@isU1ACond;@g;
$prog =~ s@,UZA,([^;]+);1,XTA,8;,UJ,([^;]+);\1:,XTA,0;\2:@isU1ACond;@g;
$prog =~ s@,U1A,([^;]+);1,XTA,8;,UJ,([^;]+);\1:,XTA,0;\2:@isUZACond;@g;

# Normalising labels

$prog =~ s/;([^:']+:)/;\1,BSS,;/g;

# Now BSS is the only case with no "offset"

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

$prog =~ s@,BSS,;15,ATX,0;15,UTM,-(\d+);14,VJM,P/(\d) *;15,UTM,(\d+);@": Level $2 procedure with ".($1-3)." parameters and ".($3-$1+2)." locals (or a func with ".($1-4)." parameters);"@eg;

$prog =~ s@,BSS,;,NTR,7; :,BSS,;13,MTJ,(\d);@: Level \1 procedure with no frame;@g;

# Converting shortcuts to standard subroutine calls

$prog =~ s@13,VTM,([^;]+);,UJ,([^;]+);@13,VJM,\2;,UJ,\1;@g;


# Converting global variables addressed via index register 1
# avoiding register-register intructions.

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

# Also
$prog =~ s@=74000@NIL@g;

# Known globals

if (open(GLOBALS, "globals.txt")) {
    while (<GLOBALS>) {
        chop;
        my ($offset, $name) = split;
        $prog =~ s@glob${offset}z@$name@g || print STDERR "Global $offset not found\n";
    }
    close(GLOBALS);
} else {
    print STDERR "File globals.txt not found, no names replaced\n";
}
# Recognizing known subroutine names

if (open(ROUTINES, "routines.txt")) {
    while (<ROUTINES>) {
        chop;
        my ($offset, $name) = split;
        my $suffix = length($offset) == 5 ? '' : 'B';
        $prog =~ s@\*${offset}$suffix@$name@g || print STDERR "Offset $offset not found\n";
    }
    close(ROUTINES);
} else {
    print STDERR "File routines.txt not found, no labels replaced\n";
}

# Converting local variables avoiding insns accessing registers
# (with M in their names)
# TODO: at level N, higher-numbered registers can be used as scratch.
# This should be recognized and conversion suppressed.

$prog =~ s@;([2-6]),([^M][^M][^M]),(\d+)@";,$2,l$1var".($3-3)."z"@eg;

# Converting indirect addressing

while ($prog =~ s@;,WTC,([^;]+);([^;]+)@;\2\[\1\]@g) { }

$prog =~ s@;,UTC,([^;]+);([^;]+)@;\2+(\1)@g;

# Reading the address of a variable
$prog =~ s@14,VTM,([^;]+);,ITA,14@,XTA,&\1@g;

# Recognizing a variety of write routines

$prog =~ s@10,VTM,(\d+);(12,VTM,.OUTPUT.;)?13,VJM,P/6A *@writeAlfa\1@g;
$prog =~ s@(12,VTM,.OUTPUT.;)?13,VJM,P/7A *@writeString@g;
$prog =~ s@(12,VTM,.OUTPUT.;)?13,VJM,P/WI *@writeInt@g;
$prog =~ s@(12,VTM,.OUTPUT.;)?13,VJM,P/CW *@writeChar@g;
$prog =~ s@(12,VTM,.OUTPUT.;)?13,VJM,P/WC *@writeCharWide@g;

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

$prog =~ s@,NTR,0;,AVX,0@toReal@g;

# Converting common conditional branches

$prog =~ s@;(\d+)?,AAX,([^;]+);,UZA,@;\1,AAX,\2;ifnot @g;
$prog =~ s@;(\d+)?,AEX,([^;]+);,UZA,@;\1,CEQ,\2;ifgoto @g;
$prog =~ s@;(\d+)?,A-X,([^;]+);,UZA,@;\1,CGE,\2;ifgoto @g;
$prog =~ s@;(\d+)?,X-A,([^;]+);,UZA,@;\1,CLE,\2;ifgoto @g;

$prog =~ s@;(\d+)?,AAX,([^;]+);,U1A,@;\1,AAX,\2;ifgoto @g;
$prog =~ s@;(\d+)?,AEX,([^;]+);,U1A,@;\1,CNE,\2;ifgoto @g;
$prog =~ s@;(\d+)?,A-X,([^;]+);,U1A,@;\1,CLT,\2;ifgoto @g;
$prog =~ s@;(\d+)?,X-A,([^;]+);,U1A,@;\1,CGT,\2;ifgoto @g;

$prog =~ s@;(\d+)?,AAX,([^;]+);isUZACond@;\1,AAX,\2;toNotl@g;
$prog =~ s@;(\d+)?,AEX,([^;]+);isUZACond@;\1,CEQ,\2;toBool@g;
$prog =~ s@;(\d+)?,A-X,([^;]+);isUZACond@;\1,CGE,\2;toBool@g;
$prog =~ s@;(\d+)?,X-A,([^;]+);isUZACond@;\1,CLE,\2;toBool@g;

$prog =~ s@;(\d+)?,AAX,([^;]+);isU1ACond@;\1,AAX,\2;toBool@g;
$prog =~ s@;(\d+)?,AEX,([^;]+);isU1ACond@;\1,CNE,\2;toBool@g;
$prog =~ s@;(\d+)?,A-X,([^;]+);isU1ACond@;\1,CLT,\2;toBool@g;
$prog =~ s@;(\d+)?,X-A,([^;]+);isU1ACond@;\1,CGT,\2;toBool@g;

$prog =~ s@;(\d+)?,XTA,([^;]+);,UZA,@;\1,XTA,\2;,CEQ,0;ifgoto @g;
$prog =~ s@;(\d+)?,XTA,([^;]+);,U1A,@;\1,XTA,\2;,CNE,0;ifgoto @g;

$prog =~ s@;CALL P/IN *;,UZA,@;CALL P/IN;ifnot @g;
$prog =~ s@;CALL P/IN *;,U1A,@;CALL P/IN;ifgoto @g;

$prog =~ s@;(eo[^;]+);,UZA,@;\1;ifnot @g;
$prog =~ s@;(eo[^;]+);,U1A,@;\1;ifgoto @g;

$prog =~ s@;(\d+)?,XTA,([^;]+);isUZACond@;\1,XTA,\2;,CEQ,0;toBool@g;
$prog =~ s@;(\d+)?,XTA,([^;]+);isU1ACond@;\1,XTA,\2;,CNE,0;toBool@g;

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

    if (@stack && $line =~ m@CALL P/MI@) {
        $stack[$#stack] = "mulFix($stack[$#stack])";
        ++$from;
        next;
    }
    if (@stack && $line eq ',YTA,64') {
        $stack[$#stack] = "nonNeg($stack[$#stack])";
        ++$from;
        next;
    }
    if (@stack && $line =~ m@CALL P/SS@) {
        $stack[$#stack] = "toSet($stack[$#stack])";
        ++$from;
        next;
    }
    if (@stack && $line =~ m@CALL P/TR@) {
        $stack[$#stack] = "trunc($stack[$#stack])";
        ++$from;
        next;
    }
    if (@stack && $line =~ m/^to(...l)$/) {
        # toBool, toReal
        $stack[$#stack] = "to$1($stack[$#stack])";
        ++$from;
        next;
    }
    if ($line =~ /^eo[lf]/) {
        if (@stack) { $stack[$#stack] = $line; }
        else { $stack[0] = $line; }
        ++$from;
        next;
    }
    if (@stack >= 2 && $line =~ m@CALL P/IN@) {
        $stack[$#stack-1] = "($stack[$#stack] IN $stack[$#stack-1])";
        --$#stack;
        ++$from;
        next;
    }
    if (@stack >= 2 && $line =~ m@CALL P/PI@) {
        $stack[$#stack-1] = "toRange($stack[$#stack-1]..$stack[$#stack])";
        --$#stack;
        ++$from;
        next;
    }
    if (@stack >= 2 && $line =~ m@CALL P/DI@) {
        $stack[$#stack-1] = "($stack[$#stack-1] DIV $stack[$#stack])";
        --$#stack;
        ++$from;
        next;
    }
    if (@stack >= 2 && $line =~ m@CALL P/IS@) {
        $stack[$#stack-1] = "($stack[$#stack-1] /int/ $stack[$#stack])";
        --$#stack;
        ++$from;
        next;
    }
    if (@stack >= 2 && $line =~ m@CALL P/MD@) {
        $stack[$#stack-1] = "($stack[$#stack-1] MOD $stack[$#stack])";
        --$#stack;
        ++$from;
        next;
    }
    if (@stack && $line =~ m@,AVX,int\(-1\)@) {
        $stack[$#stack] = "neg($stack[$#stack])";
        ++$from;
        next;
    }
    if (@stack && $line =~ m@,AMX,0@) {
        $stack[$#stack] = "abs($stack[$#stack])";
        ++$from;
        next;
    }
    if (@stack && $line =~ m@,ACX,0@) {
        $stack[$#stack] = "card($stack[$#stack])";
        ++$from;
        next;
    }
    if (@stack && $line =~ m@,ANX,int\(0\)@) {
        $stack[$#stack] = "ffs($stack[$#stack])";
        ++$from;
        next;
    }
    if (@stack && $line =~ m@,ATI,(\d+)@) {
        $stack[$#stack] = "{R$1=$stack[$#stack]}";
        ++$from;
        next;
    }

    if (@stack && ($line =~ /CALL / || $line =~ /^write/) ) {
        # This is not always correct; some values are put on the stack
        # to be consumed after the return from a subroutine.
        push @to, "$line( ".join(', ', @stack)." )";
        ++$from;
        @stack = ();
        next;
    }
    if (@stack >= 2 && $line =~ m@15,A([-/EROA+*])X,0?$@) {
        $op = $1;
        $op =~ tr/EROA/^$|&/;
        $stack[$#stack-1] = "($stack[$#stack] $op $stack[$#stack-1])";
        --$#stack;
        ++$from;
        next;
    }

    if (@stack >= 2 && $line =~ m@15,C(..),0?$@) {
        $op = $1;
        $stack[$#stack-1] = "($stack[$#stack] $op $stack[$#stack-1])";
        --$#stack;
        ++$from;
        next;
    } elsif (@stack && $line =~ m@^,C(..),(.*)@) {
        $op = $1;
        $stack[$#stack] = "($stack[$#stack] $op $2)";
        ++$from;
        next;
    } elsif (@stack && $line =~/^ifgoto (.*)/) {
        push @to, "if $stack[$#stack] goto $1";
        # If there was just one element on the stack, consider it consumed
        @stack = () if @stack == 1;
        ++$from;
        next;
    } elsif (@stack && $line =~/^ifnot (.*)/) {
        push @to, "if not $stack[$#stack] goto $1";
        # If there was just one element on the stack, consider it consumed
        @stack = () if @stack == 1;
        ++$from;
        next;
    }
    if ($line !~ /,[ASX].[ASX],/ || (@stack && $line =~ /:/)) {
        dumpStack() if @stack;
        push @to, $ops[$from++];
        next;
    }
    if ($line eq '15,XTA,3') {
        if (@stack) { $stack[$#stack] = 'FUNCRET'; }
        else { $stack[0] = 'FUNCRET'; }
        ++$from;
    } elsif ($line =~ /^,XTA,(.*)/) {
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

# Removing stack corrections after calls
$prog =~ s@15,UTM,[34];@@g;

#Restoring line feeds

$prog =~ s/;/\n /g;

print $prog;



