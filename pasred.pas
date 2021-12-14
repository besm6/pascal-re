(*=p-,t-,s5,s8*)program noprog(output);
type arg=record 
   buflen, inplen: integer;
   dummy1, dummy2: integer;
   buf: record case integer of
        1: (w: array[1..26] of alfa);
        2: (c: packed array[1..140] of 0..255);
   end;
end;
procedure pasinp (var a, b: alfa); fortran;
(*=e+*)procedure pasred(var data:arg);
var i, dest, ch, words:integer;
    doit: boolean;
{   words := data.buflen div 6; i := 1;
    for i to words do data.buf.w[i] := '      ';
    PASINP(data.buf.w[1], data.buf.w[words]);
    i := 0; dest := 0; doit := true; while doit do {
        i := i + 1; ch := data.buf.c[i];
        if ch = 0177B then dest := 0
        else if ch = 010B then {
            if dest > 0 then dest := dest - 1;
        } else if ch = 030B then dest := dest + 1
        else if ch = 3 then { 
            data.inplen := dest;
            doit := false;
        } else if ch >= 040B then {
            if ch = 89 (* Y *) then ch := 117 (* У *)
            else if (ch - 96) IN [1,5,11,13,15,20] then
                ch := ch - 32
            else if (ch - 96) IN [8,14,18,19,23] then case ch of
                (* s *) 115: ch := ord('C');
                (* r *) 114: ch := ord('P');
                (* w *) 119: ch := ord('B');
                (* h *) 104: ch := ord('X');
                (* n *) 110: ch := ord('I');(*bug: must be ord('H')*)
                end; (q) exit q;
                dest := dest + 1; data.buf.c[dest] := ch;
                doit := i <> data.buflen;
        }
    } (* while *)
}; { }.
