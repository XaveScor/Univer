program Vassilyev_3_22;

type
    Ttree = ^tree;
    tree = record
        left, right: Ttree;
        value: string;
    end;

var
    exp: Ttree;
    str: string;

function isDigit(chr: char): boolean;
begin
    isDigit := chr in ['0'..'9'];
end;

function isVar(chr: char): boolean;
begin
    isVar := chr in ['a'..'z', 'A'..'Z'];
end;

function isSign(chr: char): boolean;
begin
    isSign := chr in ['+', '-', '*', '/'];
end;

function isSignPlus(chr: char): boolean;
begin
    isSignPlus := chr in ['+', '-', '*', '/', '.'];
end;

function isNumOrVar(str: string): boolean;
var
    i: integer;
begin
    if length(str) = 1 then
        isNumOrVar := isVar(str[1]) or isDigit(str[1])
    else if length(str) > 1 then begin
        for i := 1 to length(str) do
            if not(isDigit(str[i])) then begin
                isNumOrVar := false;
                exit();
            end;
        isNumOrVar := true;
    end
    else
        isNumOrVar := false;
end;

function isOpenBracket(chr: char): boolean;
begin
    isOpenBracket := chr = '(';
end;

function isCloseBracket(chr: char): boolean;
begin
    isCloseBracket := chr = ')';
end;

procedure error(i: integer; str, exp: string);
var
    j: integer;
begin
    writeLn('Ошибка в ', i, ' символе. ', str);
    for j := 1 to length(exp) do 
        if i = j then
            write('_', exp[j], '_')
        else
            write(exp[j]);
end;

function isValid(str: string): boolean;
var
    i, open: integer;
    lastSymbol: char;
begin
    lastSymbol := '.';
    
    for i := 1 to length(str) do 
    begin
        if isOpenBracket(str[i]) then begin
            {Если скобка открылась перед цифрой или X без знака}
            if not (isSignPlus(lastSymbol) or isOpenBracket(lastSymbol)) then begin
                error(i, 'Перед скобкой может быть только знак операции или другая открывающая скобка.', str);
                isValid := false;
                exit();
            end;
            
            inc(open);
        end
        else if isCloseBracket(str[i]) then begin
            {Если скобка закрылась перед знаком}
            if open = 0 then begin
                error(i, 'Для закрывающей скобки нет открывающей.', str);
                isValid := false;
                exit();
            end;
            if isSign(lastSymbol) or isOpenBracket(lastSymbol) then begin
                error(i, 'Перед закрывающей скобкой не может быть знака операции или другой скобки.', str);
                isValid := false;
                exit();
            end;
            
            dec(open);
        end
        {number}
        else if isDigit(str[i]) then begin
            if not (isDigit(lastSymbol) or isSignPlus(lastSymbol) or isOpenBracket(lastSymbol)) then begin
                error(i, 'Неверный формат числа.', str);
                isValid := false;
                exit();
            end;
        end
        {var}
        else if isVar(str[i]) then begin
            if not (isSignPlus(lastSymbol) or isOpenBracket(lastSymbol)) then begin
                error(i, 'Неверный формат переменной.', str);
                isValid := false;
                exit();
            end;
        end
        {sign}
        else if not (isDigit(lastSymbol) or isVar(lastSymbol) or isCloseBracket(lastSymbol)) then begin
            error(i, 'Ошибка со знаком операции.', str);
            isValid := false;
            exit();
        end;
        
        lastSymbol := str[i];
    end;
    
    if open > 0 then begin
        write('Не хватает закрывающих скобок');
        isValid := false;
    end
    else
        isValid := true;
end;

function searchCloseBrecket(str: string; start: integer): integer;
var
    open, i: integer;
begin
    open := 1;
    for i := start to length(str) do begin
        if isOpenBracket(str[i]) then
            inc(open)
        else if isCloseBracket(str[i]) then
            dec(open);
        
        if open = 0 then begin
            searchCloseBrecket := i;
            exit();
        end;
    end;
    
    searchCloseBrecket := 0;
end;

function clear(str: string): string;
begin
    if searchCloseBrecket(str, 2) = length(str) then
        clear := copy(str, 2, length(str) - 2)
    else
        clear := str;
end;

function strToTree(str: string): Ttree;
var
    exp: Ttree;
    i, saved_position: integer;
    first_op: boolean;
begin
    first_op := false;
    new(exp);
    
    str := clear(str);
    
    i := 1;
    if not (isNumOrVar(str)) then begin
        while i <= length(str) do 
        begin
            case str[i] of
                '(': i := searchCloseBrecket(str, i+1);
                '+', '-': 
                    begin
                        exp^.left := strToTree(copy(str, 1, i - 1));
                        exp^.right := strToTree(copy(str, i + 1, length(str) - i));
                        exp^.value := str[i];
                        first_op := true;
                        break;
                    end;
                '*', '/':
                saved_position := i;
            end;
            
            inc(i);
        end;
        
        if not (first_op) then begin
            exp^.left := strToTree(copy(str, 1, saved_position - 1));
            exp^.right := strToTree(copy(str, saved_position + 1, length(str) - saved_position));
            exp^.value := str[saved_position];
        end;
    end
    else
        exp^.value := str;
    
    strToTree := exp;
end;

procedure printTreePost(exp: Ttree);
begin
    if (exp^.left = nil) and (exp^.right = nil) then
        write(exp^.value)
    else begin
        write('(');
        printTreePost(exp^.left);
        printTreePost(exp^.right);
        write(exp^.value);
        write(')');
    end;
end;

begin
    while true do 
    begin
        write('Введите выражение в нормальном виде или "quit", чтобы завершить программу.');
        repeat
            writeLn();
            readLn(str);
            if str = 'quit' then
                halt();
        until isValid(str);
        
        exp := strToTree(str);
        writeLn('Выражение в постфиксной форме:');
        printTreePost(exp);
        writeLn();
        writeLn('---------------------------------------------------------------');
    end;
end.