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
    elseif contains(lower(direction), 'horz')
        imagesc(ones(size(y)), y, y)
    end

    set(gca, 'XTick', [], 'YTick', ticks, 'YDir', 'normal')
end