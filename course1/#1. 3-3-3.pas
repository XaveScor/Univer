program Vassilyev1_3_3_3;
type
    func = function (x: real):real;
const
    EPS1                  = 1e-6;
    EPS                   = 1e-3;
    DERIVATIVE_EPS        = 1e-4;
    LEFT_MARGIN           = 0.1;
    RIGHT_MARGIN          = 4;
    N_BASE_INTEGRAL       = 30;
    DERIVATIVE_DELTA_BASE = 1;

var
    roots: array[1..3] of real;
    square, square1, square2, square3: real;
{$F+}

function f1(x:real):real;
begin
    f1 := exp(-x)+3;
end;

function f2(x:real):real;
begin
    f2 := 2*x-2;
end;

function f3(x:real):real;
begin
    f3 := 1/x;
end;

function derivative(f:func; x:real):real;
var
    delta, last_derivative, current_derivative, valueOfX: real;
begin
    delta := 10*DERIVATIVE_DELTA_BASE;
    current_derivative := 0;
    valueOfX := f(x);
    repeat
        last_derivative := current_derivative;
        delta:= delta / 10;
        current_derivative := ( f(x + delta) - valueOfX )/ delta;
    until abs(last_derivative - current_derivative) <= DERIVATIVE_EPS;
    derivative := current_derivative;
end;

function root(f, g:func):real;
var
    x, Fx, Fx_dx: real;
begin
        x := LEFT_MARGIN;
        repeat
            Fx := f(x) - g(x);
            Fx_dx := derivative(f, x) - derivative(g, x);
            x := x - Fx/Fx_dx;
        until abs(Fx) <= EPS1;
        root := x
end;

function integral(f:func; a, b: real):real;
var
    h, s, x, i, i_last:real;
    n: integer;
begin
    n := N_BASE_INTEGRAL;
    i := -5000; { magic number:) repeat, min 2 itterations}
    repeat
        i_last := i;
        h := (b-a)/(n*2);
        s := 0;
        x := a + h;
        while x<b do begin
            s := s + 4*f(x);
            x := x + h;
            s := s + 2*f(x);
            x := x + h;
        end;
        i := (h/3)*(s + f(a) - f(b));
    until abs(i-i_last) < EPS;
    integral := i;
end;

begin
    roots[1] := root(f1, f2);
    roots[2] := root(f2, f3);
    roots[3] := root(f1, f3);

    writeLn('f2 f1 intersects at point x = ',roots[1]);
    writeLn('f3 f2 intersects at point x = ',roots[2]);
    writeLn('f1 f3 intersects at point x = ',roots[3]);
                    
    square1 := integral(f1, roots[3], roots[1]);
    square2 := integral(f2, roots[1], roots[2]);
    square3 := integral(f3, roots[2], roots[3]);
    square := abs(square1 + square2 + square3);
                    
    writeLn('square shapes = ', square);
             
end.
