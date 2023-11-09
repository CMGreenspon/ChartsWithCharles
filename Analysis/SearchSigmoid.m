function c_fit = SearchSigmoid(x, y, c0, ShowPlot)
    if nargin < 4
        ShowPlot = false;
    end
    SigFun = GetSigmoid(2);

    % Search optim
    SigmoidFun = @(c) 1./(1 + exp(-c(1) .* (x-c(2))));
    SigmoidCostFun = @(c) sum((SigmoidFun(c) - y).^2);
    [c_fit,f] = fminsearch(SigmoidCostFun, c0);

    if ShowPlot
        cr = abs(c_fit - c0) .* 2;
        num_points = 100;
        cmin = c0 + cr;
        cmax = c0 - cr;
        c1 = linspace(cmin(1), cmax(1), num_points);
        c2 = linspace(cmin(2), cmax(2), num_points);
        rnorm = NaN(num_points);
        for i = 1:num_points
            for j = 1:num_points
                y_pred = SigFun([c1(i), c2(j)], x);
                rnorm(i,j) = sum(sqrt((y_pred - y).^2));
            end
        end

        figure; 
        imagesc(c2, c1, rnorm)
        hold on
        scatter(c_fit(2), c_fit(1), 100, 'r', 'x', 'LineWidth', 2)
        ylabel('Scale')
        xlabel('Intercept')
        colorbar 
    end
end