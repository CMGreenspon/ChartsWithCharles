function p_str = pStr(p, n)
    if nargin == 1
        n = 2;
    end
    
    if p < 10^-n
        p_str = ['p < 0.', repmat('0', 1,n-1), '1'];
    else
        p_str = sprintf(['p = %0.', num2str(n), 'f'], p);
    end
end