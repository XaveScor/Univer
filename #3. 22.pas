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
    if chr in ['0'..'9'] then
        isDigit := true
    else
        isDigit := false;
end;

function isVar(chr: char): boolean;
begin
    if chr in ['a'..'z', 'A'..'Z'] then
        isVar := true
    else
        isVar := false;
end;

function isSign(chr: char): boolean;
begin
    if chr in ['+', '-', '*', '/'] then
        isSign := true
    else
        isSign := false;
end;

function isSignPlus(chr: char): boolean;
begin
    if chr in ['+', '-', '*', '/', '.'] then
        isSignPlus := true
    else
        isSignPlus := false;
end;

function isNumOrVar(str: string): boolean;
var
    i: integer;
begin
    if length(str) = 1 then
        if isVar(str[1]) or isDigit(str[1]) then
            isNumOrVar := true
    else if length(str) > 1 then begin
        for i := 1 to length(str) do
            if isDigit(str[i]) then begin
                isNumOrVar := false;
                exit();
            end;
        isNumOrVar := true;
    end
    else
        isNumOrVar := false;
end;

procedure error(i: integer; str, exp: string);
var
	j: integer;
begin
	writeLn('Ошибка в ',i,' символе. ',str);
	for j := 1 to length(exp) do 
		if i = j then
			write('_',exp[j],'_')
		else
			write(exp[j]);
end;

function isValid(str: string): boolean;
var
    i, open, open_position: integer;
    isOpened: boolean;
    substr: string;
    lastSymbol: char;
begin
    isOpened := false;
    lastSymbol := '.';
    
    for i := 1 to length(str) do begin
        if isOpened then
            substr := substr + str[i];
        
        if str[i] = '(' then begin
            {Если скобка открылась перед цифрой или X без знака}
            if not(isSignPlus(lastSymbol) or (lastSymbol = '(')) then begin
            	error(i, 'Перед скобкой может быть только знак операции или другая открывающая скобка.', str);
                isValid := false;
                exit();
            end;
            
            inc(open);
            isOpened := true;
        end
        else if str[i] = ')' then begin
            {Если скобка закрылась перед знаком}
            if open = 0 then begin
            	error(i, 'Для закрывающей скобки нет открывающей.', str);
                isValid := false;
                exit();
            end;
            if isSign(lastSymbol) or (lastSymbol = '(') then begin
                error(i, 'Перед закрывающей скобкой не может быть знака операции или другой скобки.', str);
                isValid := false;
                exit();
            end;
            
            dec(open);
        end
        {number or var}
        else begin
            if isDigit(str[i]) then begin
                if not(isDigit(lastSymbol) or isSignPlus(lastSymbol) or (lastSymbol = '(')) then begin
                    error(i, 'Неверный формат числа.', str);
                    isValid := false;
                    exit();
                end;
             end
             else if isVar(str[i]) then begin
                if not(isSignPlus(lastSymbol) or (lastSymbol = '(')) then begin
                    error(i, 'Неверный формат переменной.', str);
                    isValid := false;
                    exit();
                end;
             end
             else if isSignPlus(str[i]) then begin
                if not(isDigit(lastSymbol) or isVar(lastSymbol) or (lastSymbol = ')')) then begin
                    error(i, 'Ошибка со знаком операции.', str);
                    isValid := false;
                    exit();
                end;
             end
             else begin
                error(i, 'Ваша формула не прошла валидацию. Введите формулу в верном формате.', str);
                isValid := false;
                exit();
             end;
        end;
        
        if isOpened and (open = 0) then begin    
            delete(substr, length(substr), 1); {Удаляем последнюю скобку}
            if not(isValid(substr)) then begin
                error(i, 'Неверный баланс скобок.', str);
                isValid := false;
                exit();
            end;
            substr := '';
            isOpened := false;
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

function clear(str: string): string;
var	
	open, i: integer;
begin
	while str[1] = '(' do begin
    	open := 1;
        for i := 2 to length(str) do begin
            if str[i] = '(' then
                inc(open)
            else if str[i] = ')' then
                dec(open);
            if open = 0 then begin
                if i = length(str) then
                    str := copy(str, 2, length(str) - 2)
                else
                    break;
            end;        
        end;
    end;
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
    if not(isNumOrVar(str)) then begin
        while i <= length(str) do begin
            case str[i] of
                '(': while str[i + 1] <> ')' do inc(i);
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
        
        if not(first_op) then begin
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
    write('Введите выражение в нормальном виде или "q", чтобы завершить программу.');
    repeat
    	writeLn();
        readLn(str);
        if str = 'q' then
        	halt();
    until isValid(str);
    
    exp := strToTree(str);
    
    printTreePost(exp);
end.