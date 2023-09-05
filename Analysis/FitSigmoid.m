function [SigmoidFun, coeffs, rnorm, residuals, jnd, warn] = FitSigmoid(x, y, varargin)
    % Simple weighted sigmoid fitting function
    NumCoeffs = 2; % By default we assume there is a slope and x-offset term
    % Coefficients Growth term, x-offset, y-max, y-offset
    Constraints = zeros(4,2); % [NumCoeffs x 2] (low, high)
    CoeffInit = zeros(4,1);
    PlotFit = false;
    ShowWarnings = true;
    opts = optimset('Display','off'); % Disable reporting for lsqcurvefit

    % Assert that x is a row vector
    if size(x,2) == 1 && size(x,1) > 1
        x = x';
    elseif all(size(x) > 1)
        error('X must be a vector')
    end
    
    % Ensure that y has the same rotation as x
    if size(y,2) == 1 && size(y,1) > 1 || size(y,1) == size(x,2) && size(y,2) > 1
        y = y';
    elseif ~size(y,2) == size(x,2)
        error('Y must have one dimension equal to the length of x')
    end
    y_mean = mean(y, 1, 'omitnan');

    % Determine weighting
    if isa(y, "logical") || all(y == 0 | y == 1)
        num_obs = ones(size(x)); % Weight points equally
    elseif isa(y, "double")
        num_obs = sum(~isnan(y),1); % Weight points based on number of obs
    end
    % Add constraints to model + the start point
    if NumCoeffs < 4 % Y-offset
        Constraints(4,:) = [0,0];
        CoeffInit(4) = 0;
    else
        CoeffInit(4) = min(y, 'all') + range(y, 'all') / 2;
        Constraints(4,:) = CoeffInit(4) + [-range(y, 'all'), range(y, 'all')];
    end
    if NumCoeffs < 3 % Multiplier
        Constraints(3,:) = [1,1];
        CoeffInit(3) = 1;
    else
        CoeffInit(3) = range(y, 'all');
        Constraints(3,:) = [CoeffInit(3)/2, CoeffInit(3)*2];
    end % Offset
    if NumCoeffs < 2
        Constraints(2,:) = [0,0];
        CoeffInit(2) = 0;
    else
        CoeffInit(2) = mean(x);
        Constraints(2,:) = [min(x)-range(x)*0.5, max(x)+range(x)*0.5];
    end
    Constraints(1,:) = [0 1];

    % Try to find the slope
    if any(y_mean <= 0.25) && any(y_mean >= 0.75)
        y25 = x(find(y_mean <= 0.25, 1, "first"));
        y75 = x(find(y_mean >= 0.75, 1, "last"));
    elseif sum(y_mean >= 0.25 & y_mean <= 0.75) == 1 % Estimate
        y2575 = x(y_mean >= 0.25 & y_mean <= 0.75);
        y25 = y2575 - diff(x(1:2)) / 2;
        y75 = y2575 + diff(x(1:2)) / 2;
    else
        y25 = x(2);
        y75 = x(end-1);
    end
    CoeffInit(1) = 1.7 / ((1/norminv(.75)) * ((y75 - y25) / 2));

    % Check if vararg contains other constraints or initalizations
    ParseVarargin();

    % Create the weighted sigmoid - this is a slightly different form for
    % optimization so does not use the GetSigmoid functio
    SigmoidFun = @(c) (c(3) .* (1./(1 + exp(-c(1) .* (x-c(2)))))) + c(4);
    SigmoidCostFun = @(c) sqrt(num_obs) .* (SigmoidFun(c) - y_mean);

    [coeffs, rnorm, residuals] = lsqnonlin(SigmoidCostFun, CoeffInit, Constraints(:,1), Constraints(:,2), opts);
    % Check if hit constraint boundary
    warn = false;
    for c = 1:size(Constraints,1)
        if Constraints(c,1) == Constraints(c,2)
            continue
        end
        c_idx = abs(coeffs(c) - Constraints(c,:)) < 1e-3;
        if any(c_idx)
            if c_idx(1)
                b = 'lower';
            else
                b = 'upper';
            end
            if ShowWarnings
                warning('Coefficient %d has hit %s constraint boundary.', c, b)
            end
            warn = true;
        end
    end

    % Compute JND
    jnd = ((log(1/.75 - 1)/-coeffs(1)) - (log(1/.25 - 1)/-coeffs(1))) / 2;
    
    coeffs = coeffs(1:NumCoeffs);
    SigmoidFun = GetSigmoid(NumCoeffs);
    if PlotFit
        figure; hold on
        scatter(x, y_mean)
        plot(linspace(min(x), max(x)), SigmoidFun(coeffs, linspace(min(x), max(x))))
    end

function ParseVarargin()
    if ~isempty(varargin)
        nargin = ceil(length(varargin)/2);
        varargin = reshape(varargin, [2, nargin]);
        for n = 1:nargin
            if strcmpi(varargin{1,n},'PlotFit')
                PlotFit = varargin{2,n};  
            elseif strcmpi(varargin{1,n},'CoeffInit')
                for i = 1:length(varargin{2,n}) % Allow passing individual coeffs
                    if ~isnan(varargin{2,n}(i))
                        CoeffInit(i) = varargin{2,n}(i);
                    end
                end
            elseif strcmpi(varargin{1,n},'Constraints')
                for i = 1:size(varargin{2,n},1) % Allow passing < 4 coeffs
                    if ~all(isnan(varargin{2,n}(i,:))) % Allow skipping some too
                        Constraints(i,:) = varargin{2,n}(i,:);
                    end
                end
            elseif strcmpi(varargin{1,n},'NumCoeffs')
                NumCoeffs = varargin{2,n}; 
            elseif strcmpi(varargin{1,n},'ShowWarnings')
                ShowWarnings = varargin{2,n};
            else
                error('%s is an unrecognized input.', varargin{1,n})
            end
        end
    end
end

end