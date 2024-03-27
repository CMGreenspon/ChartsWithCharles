function r2 = ResidualVariance2(y, y_pred)
    res_error = sum((y_pred - y) .^ 2); % Residuals around model fit
    tot_error = sum((y - mean(y)) .^ 2); % Residuals around mean
    r2 = 1 - (res_error / tot_error); % Relative variance
end