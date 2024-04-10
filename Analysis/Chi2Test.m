function [chi, p] = Chi2Test(observed, predicted)
    % Format inputs
    if size(observed, 2) > 1 && size(observed, 1) == 1 % Make row vector
        observed = observed';
    elseif all(size(observed) > 1)
        error('Inputs must be vectors.')
    end
    % Check predicted
    if nargin == 1 % Assume equal distribution
        predicted = repmat(sum(observed) / length(observed), 1, length(observed));
    else
        if size(predicted, 2) > 1 && size(predicted, 1) == 1 % Make row vector
            predicted = predicted';
        elseif all(size(predicted) > 1)
            error('Inputs must be vectors.')
        end
    end
    % Compute chi2 statistic: squared deviation from expected observations
    % normalized by the number of expected observations
    chi = sum(((observed - predicted).^2) ./ predicted);
    dof = length(observed) - 1; % Number of classes - 1
    p = chi2cdf(chi, dof, 'upper'); % Upper returns more accurate complementary p value
end