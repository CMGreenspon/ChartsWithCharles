function [x,y] = GetAxisPosition(ax, xp, yp)
    warning("Use TEXT(X,Y,str,'sc')")
    return
    % Compute x-position
    if strcmp(ax().XScale, 'linear')
        x = ax().XLim(1) + range(ax().XLim) * (xp/100);
    elseif strcmp(ax().XScale, 'log')
        x = exp(log(ax().XLim(1)) + range(log(ax().XLim)) * (xp/100));
    end
    
    % Compute y-position
    if strcmp(ax().YScale, 'linear')
        y = ax().YLim(1) + range(ax().YLim) * (yp/100);
    elseif strcmp(ax().YScale, 'log')
        y = exp(log(ax().YLim(1)) + range(log(ax().YLim)) * (yp/100));
    end
end