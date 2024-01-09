function SigFun = GetSigmoid(num_coeffs)
    % Get anonymous sigmoid function handle
    if nargin == 0
        num_coeffs = 2;
    end

    switch num_coeffs
        case 1
            SigFun = @(c, x) 1./(1 + exp(-c(1) .* x));
        case 2 % Growth term, x-offset
            SigFun = @(c, x) 1./(1 + exp(-c(1) .* (x-c(2))));
        case 3 % Growth term, x-offset, y-max
            SigFun = @(c, x) c(3) .* (1./(1 + exp(-c(1) .* (x-c(2)))));
        case 4 % Growth term, x-offset, y-max, y-offset
            SigFun = @(c, x) c(3) .* (1./(1 + exp(-c(1) .* (x-c(2))))) + c(4);
    end
end