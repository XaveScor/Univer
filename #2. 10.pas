type
    date = record
        day, month, year: integer;
        visited: boolean;
    end;
    dates = array[1..100] of date;

var
    i, j: integer;
    nums: array[1..4] of integer;
    n: integer;
    arr: dates;
    sDate: string;
    ch: char;
    tempArr: array[0..1] of dates;
    num_compare, num_move: integer;
    num11, num12, num13, num14, num15, num21, num22, num23, num24, num25: integer;

function strToDate(sDate: string): date;
var
    sNum: string;
    i: integer;
    return: date;
begin
    sNum := '';
    
    for i := 1 to length(sDate) do 
    begin
        if (sDate[i] = '.') then begin
            if return.day = 0 then
                return.day := strToInt(sNum)
            else
                return.month := strToInt(sNum);
            sNum := '';
        end
        else
            sNum := sNum + sDate[i];
    end;
    return.year := strToInt(sNum);
    return.visited := false;
    
    strToDate := return;
end;

procedure clear();
begin
    num_compare := 0;
    num_move := 0;
    randomize;
end;

function intsToDate(day, month, year: integer): date;
var
    return: date;
begin
    return.day := day;
    return.month := month;
    return.year := year;
    return.visited := false;
    
    intsToDate := return;
end;

function dateToStr(el: date): string;
begin
    dateToStr := intToStr(el.day) + '.' + intToStr(el.month) + '.' + intToStr(el.year);
end;

function less(first, second: date): boolean;
begin
    if first.year <> second.year then
        less := first.year < second.year
    else if first.month <> second.month then
        less := first.month < second.month
    else
        less := first.day < second.day;
        
    inc(num_compare);
end;

procedure visit(var arr: dates; left, right: integer);
var
    i: integer;
begin
    for i := left to right do
        arr[i].visited := true;
end;

function visited(el: date): boolean;
begin
    visited := el.visited;
end;

function allVisited(arr: dates): boolean;
var
    i: integer;
begin
    for i := 1 to n do
        if not(visited(arr[i])) then begin
            allVisited := false;
            exit;
        end;
    allVisited := true
end;

function findMaxLeft(var arr: dates; var left, right: integer): boolean;
var
    i: integer;
    len, start, oldLen: integer;
begin
    if allVisited(arr) then begin
        findMaxLeft := false;
        exit;
    end;
    
    for i := 1 to n do
        if not(visited(arr[i])) then begin
            start := i;
            break;
        end;
    
    if start = n then begin
        left := n;
        right := n;
        visit(arr, n, n);
        exit;
    end;
    
    len := 1;
    oldLen := 0;
    for i := (start + 1) to n do
        if not(less(arr[i], arr[i - 1])) and not(visited(arr[i])) then
            inc(len)
        else begin
            if len > oldLen then begin
                left := i - len;
                right := i - 1;
                oldLen := len;
            end;
            len := 1;
        end;
        
    if len > oldLen then begin
        right := n;
        left := n - len + 1;
    end;
    
    findMaxLeft := true;
    visit(arr, left, right);
end;

function findMaxRight(var arr: dates; var left, right: integer): boolean;
var
    i: integer;
    len, start, oldLen: integer;
begin
    if allVisited(arr) then begin
        findMaxRight := false;
        exit;
    end;
    
    for i := n downto 1 do
        if not(visited(arr[i])) then begin
            start := i;
            break;
        end;
    
    if start = 1 then begin
        left := 1;
        right := 1;
        visit(arr, 1, 1);
        exit;
    end;
    
    len := 1;
    oldLen := 0;
    for i := (start - 1) downto 1 do
        if not(less(arr[i + 1], arr[i])) and not(visited(arr[i])) then
            inc(len)
        else begin
            if len > oldLen then begin
                left := i + 1;
                right := i + len;
                oldLen := len;
            end;
            len := 1;
        end;
        
    if len > oldLen then begin
        right := len;
        left := 1;
    end;
    
    findMaxRight := true;
    visit(arr, left, right);
end;

procedure copy(var from, _to: date);
begin
    _to := from;
    _to.visited := false;
    inc(num_move);
end;


procedure copySegmentLeft(var input, output:dates; startInput, _endInput, startOutput: integer);
var
    i: integer;
begin
    for i := startInput to _endInput do
        copy(input[i], output[startOutput + i - startInput]);
end;

procedure copySegmentRight(var input, output:dates; startInput, _endInput, startOutput: integer);
var
    i: integer;
    delta: integer;
begin
    delta := _endInput - startInput;
    for i := startInput to _endInput do
        copy(input[i], output[startOutput - delta + i - startInput]);
end;

procedure sortLeft(var input, output: dates;var startOutput: integer; firstLeft, firstRight, secondLeft, secondRight: integer);
var
    ittFirst, ittSecond: integer;
    lenFirst, lenSecond: integer;
    i: integer;
begin
    ittFirst := firstLeft;
    ittSecond := secondLeft;

    lenFirst := firstRight - firstLeft + 1;
    lenSecond := secondRight - secondLeft + 1;
    
    for i := startOutput to (startOutput + lenFirst + lenSecond - 1) do
        if ittFirst > firstRight then begin
            copySegmentLeft(input, output, ittSecond, secondRight, i);
            break;
        end
        else if ittSecond > secondRight then begin
            copySegmentLeft(input, output, ittFirst, FirstRight, i);
            break;
        end
        else if not(less(input[ittFirst], input[ittSecond])) then begin
            copy(input[ittSecond], output[i]);
            inc(ittSecond);
        end
        else begin
            copy(input[ittFirst], output[i]);
            inc(ittFirst);
        end;

    startOutput := startOutput + lenFirst + lenSecond;
end;

procedure sortRight(var input, output: dates;var startOutput: integer; firstLeft, firstRight, secondLeft, secondRight: integer);
var
    ittFirst, ittSecond: integer;
    lenFirst, lenSecond: integer;
    i: integer;
begin
    ittFirst := firstRight;
    ittSecond := secondRight;
    
    lenFirst := firstRight - firstLeft + 1;
    lenSecond := secondRight - secondLeft + 1;
    
    for i := startOutput downto (startOutput - lenFirst - lenSecond + 1) do
        if ittFirst < firstLeft then begin
            copySegmentRight(input, output, secondLeft, ittSecond, i);
            break;
        end
        else if ittSecond < secondLeft then begin
            copySegmentRight(input, output, firstLeft, ittFirst, i);
            break;
        end
        else if not(less(input[ittFirst], input[ittSecond])) then begin
            copy(input[ittFirst], output[i]);
            dec(ittFirst);
        end
        else begin
            copy(input[ittSecond], output[i]);
            dec(ittSecond);
        end;

    startOutput := startOutput - lenFirst - lenSecond;
end;

function sort(var input, output: dates): boolean;
var
    firstLeft, firstRight, secondLeft, secondRight: integer;
    outputLeft, outputRight: integer;
    isRightMargin, position: boolean;
begin
    position := true;
    
    sort := true;
    
    outputLeft := 1;
    outputRight := n;
        
    while findMaxLeft(input, firstLeft, firstRight) do begin
        if (firstLeft = 1) and (firstRight = n) then begin
            sort := false;
            exit;
        end;
        
        isRightMargin := findMaxRight(input, secondLeft, secondRight);
        
        if position then begin
            if isRightMargin then
                sortLeft(input, output, outputLeft, firstLeft, firstRight, secondLeft, secondRight)
            else
                copySegmentLeft(input, output, firstLeft, firstRight, outputLeft)
        end
        else
            if isRightMargin then
                sortRight(input, output, outputRight, firstLeft, firstRight, secondLeft, secondRight)
            else
                copySegmentRight(input, output, firstLeft, firstRight, outputRight);        
        position := not(position);
    end;
end;

procedure mergeSort(var arr: dates; n: integer);
var
    i, j: integer;
    from, _to: integer;
begin
    for i := 1 to n do
        tempArr[0][i] := arr[i];
    
    from := 0;
    _to := 1;
    i := 1;
    while sort(tempArr[from], tempArr[_to]) do 
    begin
        {writeLn('иттерация ', i);
        inc(i);
        for j := 1 to n do
            write(dateToStr(tempArr[_to][j]), ' ');
        writeLn;
        }from := (from + 1) mod 2;
        _to := (_to + 1) mod 2;
    end;
    
    for i := 1 to n do
        arr[i] := tempArr[_to][i];
end;

procedure readDates(n: integer; var arr: dates);
var
    i: integer;
begin
    for i := 1 to n do 
    begin
        sDate := '';
        if i <> n then
            repeat
                read(ch);
                sDate := concat(sDate, ch);
            until ch = ' '
        else
            read(sDate);
        arr[i] := strToDate(sDate);
    end;
end;

procedure printMargin();
begin
    writeLn('       -----------------------------------------------------------------');
end;

procedure printHead();
begin
    writeLn('                         Метод естественного слияния');
    printMargin();
    writeLn('       |  n |  параметр   |     номер последовательности   |  среднее  |');
    writeLn('       |    |             |     1    2    3    4    5      |  значение |');
    printMargin();
end;

procedure printLine(n, num11, num12, num13, num14, num15, num21, num22, num23, num24, num25: integer);
var
    sum, size: integer;
begin
    size := 5;
    sum := num11 + num12 + num13 + num14 + num15;
    writeLn('       |', n:3, ' |  сравнение  |  ', num11:size, num12:size, num13:size, num14:size, num15:size, '      |', (sum div 5):7, '   |');
    sum := num21 + num22 + num23 + num24 + num25;
    writeLn('       |    | перемещения |  ', num21:size, num22:size, num23:size, num24:size, num25:size, '      |', (sum div 5):7, '   |');
    printMargin();
end;

procedure getParams(var num1, num2: integer);
begin
    num1 := num_compare;
    num2 := num_move;
    clear();
end;

begin
    // read dates ************************************
    {readLn(n);
    readDates(n, arr);
    mergeSort(arr, n);
    }//end ********************************************        
    printHead();
    clear();
    
    nums[1] := 10;
    nums[2] := 20;
    nums[3] := 50;
    nums[4] := 100;
    
    for j := 1 to 4 do begin
        n := nums[j];
        for i := 1 to n do
            arr[i] := intsToDate(i,i,i);
        mergeSort(arr, n); 
        getParams(num11, num21);
        
        for i := n downto 1 do
            arr[n - i + 1] := intsToDate(i,i,i);
        mergeSort(arr, n);
        getParams(num12, num22);
        
        for i := 1 to n do
            if odd(i) then
                arr[i] := intsToDate(i,i,i)
            else
                arr[i] := intsToDate(10-i, 10-i, 10-i);
        mergeSort(arr, n);
        getParams(num13, num23);
        
        for i:= 1 to n do
            arr[i] := intsToDate(random(31) + 1, random(12) + 1, random(10000));
        mergeSort(arr, n);
        getParams(num14, num24);
        
        for i:= 1 to n do
            arr[i] := intsToDate(random(31) + 1, random(12) + 1, random(10000));
        mergeSort(arr, n);
        getParams(num15, num25);
        
        printLine(n, num11, num12, num13, num14, num15, num21, num22, num23, num24, num25);
    end;
    {n := nums[1];
    for i := n downto 1 do
            arr[n - i + 1] := intsToDate(i,i,i);
        mergeSort(arr, n);
        getParams(num12, num22);
    }//test();
end.