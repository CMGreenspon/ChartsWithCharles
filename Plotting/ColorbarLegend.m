function cb = ColorbarLegend(fig, position, cmap, direction, ticks)
    if nargin < 4
        direction = 'vert';
    end
    if nargin < 5
        ticks = [0, 1];
    end

    cb = axes('Position', position, 'Parent', fig);
    y = linspace(min(ticks), max(ticks), size(cmap,1));

    if contains(lower(direction), 'vert')
        imagesc(ones(size(y)), y, y')
        set(gca, 'YTick', [min(y),max(y)], 'YTickLabels', ticks, 'XTick', [], 'YDir', 'normal', 'Colormap', cmap)
    elseif contains(lower(direction), 'horz')
        imagesc(ones(size(y)), y, y)
        set(gca, 'XTick', [min(y),max(y)], 'XTickLabels', ticks, 'YTick', [], 'YDir', 'normal', 'Colormap', cmap)
    end
    
end