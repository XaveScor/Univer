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

function isNumOrParam(str: string): boolean;
var
    i: integer;
begin
    isNumOrParam := true;
    if length(str) > 1 then
        for i := 1 to length(str) do
            if (str[i] < '0') or (str[i] > '9') then begin
                isNumOrParam := false;
                break;
            end;
end;

function strToTree(str: string): Ttree;
var
    exp: Ttree;
    i, open, saved_position: integer;
    first_op: boolean;
begin
    first_op := false;
    new(exp);
    
    open := 1;
    if str[1] = '(' then
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
    
    i := 1;
    if not(isNumOrParam(str)) then begin
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


procedure pprintTreePost(exp: Ttree);
begin
    if (exp^.left = nil) and (exp^.right = nil) then
        write(exp^.value)
    else begin
        write('(');
        pprintTreePost(exp^.left);
        pprintTreePost(exp^.right);
        write(exp^.value);
        write(')');
  end;
end;

procedure printTreePost(exp: Ttree);
begin
    if (exp^.left = nil) and (exp^.right = nil) then
        write(exp^.value)
    else begin
        pprintTreePost(exp^.left);
        pprintTreePost(exp^.right);
        write(exp^.value);
  end;
end;

begin
    writeLn('¬ведите выражение в нормальном виде');
    readLn(str);
    
    exp := strToTree(str);
    
    //write(exp^.value);
    printTreePost(exp);
end.