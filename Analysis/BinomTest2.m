function [h,p] = BinomTest2(x1, x2, tail, alpha)
    if nargin < 3
        tail = 'both';
    end
    if nargin < 4
        alpha = 0.05;
    end
    % Assert that both x1 and x2 are column vectors
    if ~(size(x1,2) == 1 && size(x1,1) > 1)
        if (size(x1,1) == 1 && size(x1,2) > 1)
            x1 = x1';
        elseif all(size(x1) > 1)
            error('X1 must be a vector')
        end
    end

    if ~(size(x2,2) == 1 && size(x2,1) > 1)
        if (size(x2,1) == 1 && size(x2,2) > 1)
            x2 = x2';
        elseif all(size(x2) > 1)
            error('X2 must be a vector')
        end
    end

    % Remove NaNs
    if any(isnan(x1))
        x1 = x1(~isnan(x1));
    end
    if any(isnan(x2))
        x2 = x2(~isnan(x2));
    end

    % Assert logical
    if ~isa(x1, "logical")
        x1 = logical(x1);
    end
    if ~isa(x2, "logical")
        x2 = logical(x2);
    end

    % Counts - total
    x1_count = numel(x1);
    x2_count = numel(x2);
    % Counts - true
    nx1_true = sum(x1);
    nx2_true = sum(x2);
    % Ratio
    x1_ratio = nx1_true / x1_count;
    x2_ratio = nx2_true / x2_count;
    h_shared = (nx1_true + nx2_true) / (x1_count + x2_count);
    if h_shared == 1
        h = false;
        p = 1;
        return
    end

    % Success rate
    s = h_shared*(1-h_shared)*(1/x1_count + 1/x2_count);
    % Convert to z-score
    z = (x1_ratio - x2_ratio) / sqrt(s);
    switch lower(tail)
        case 'left'
            p = normcdf(z);
        case 'right'
            p = 1 - normcdf(z);
        case 'both'
            p = (1 - normcdf(abs(z)))/2;
    end

    if p < alpha
        h = true;
    else
        h = false;
    end
end