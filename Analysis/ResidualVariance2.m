function r2 = ResidualVariance2(y, y_pred, num_predictors)
    res_error = sum((y_pred - y) .^ 2); % Residuals around model fit
    tot_error = sum((y - mean(y)) .^ 2); % Residuals around mean
    rel_error = (res_error / tot_error); % Error ratio
    if nargin == 2 % Ordinary
        r2 = 1 - rel_error;
    else % Adjusted
        adj = (length(y_pred) - 1) / (length(y_pred) - num_predictors);
        r2 = 1 - (adj * rel_error); % 
    end
end