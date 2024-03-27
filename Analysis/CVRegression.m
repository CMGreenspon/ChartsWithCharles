function fit_metric = CVRegression(X, Y, NumSubX, NumPerms, error_metric)
    if size(X,1) ~= size(Y,1)
        error('size(X,1) ~= size(Y,1)')
    end
    warning('off','MATLAB:rankDeficientMatrix')
    fit_metric = zeros(NumPerms,1);
    ridx = 1:length(Y);
    for p = 1:NumPerms
        % Grab a random assortment of cells
        x_sub_idx = randperm(size(X,2));
        perm_pop = X(:, x_sub_idx(1:NumSubX));
        % Make fold
        [rough_pred] = deal(zeros([length(Y),1]));
        for f = 1:length(Y)
            % Indices
            out_fold_idx = ridx ~= f;
            in_fold_idx = ridx == f;
            % Regress on the in-fold
            B = Y(out_fold_idx)' / [perm_pop(out_fold_idx,:), ones(length(Y)-1,1)]';
            % Predict on the out-fold
            rough_pred(f) = B * [perm_pop(in_fold_idx,:),1]';
        end

        if strcmpi(error_metric, 'residual_variance')
            fit_metric(p) = ResidualVariance2(y, rough_pred);
        elseif strcmpi(error_metric, 'corr')
            r = corrcoef(rough_pred, Y);
            fit_metric(p) = r(1,2)^2;
        elseif strcmpi(error_metric, 'mae')
            fit_metric(p) = median(abs(rough_pred-Y));
        else
            error('ErrorMetric must be: "residual_variance", "corr", "mae".')
        end
    end
    warning('on','MATLAB:rankDeficientMatrix')
end