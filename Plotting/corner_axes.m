function corner_axes(axis_handle, location, proportion, options)
    arguments
        axis_handle
        location = [1 1 1] % Which side of the axis the plot should be
        proportion {mustBeFloat} = 0.1
        options.line_width = 1
        options.line_color = 'k'
    end

    if ~isa(axis_handle, 'matlab.graphics.axis.Axes')
        error("axis_handle must be an axis handle...")
    end

    if ~all(location == 1 | location == 0)
        error("location must equal 0 or 1")
    end
    
    % get limits
    xl = axis_handle.XLim;
    yl = axis_handle.YLim;
    zl = axis_handle.ZLim;

    % get values
    xv = get_value(xl, location(1));
    yv = get_value(yl, location(2));
    zv = get_value(zl, location(3));

    % Plot them
    plot3([xv(1), xv(1), xv(end)], [yv(2), yv(1), yv(1)], [zv(1), zv(1), zv(1)], ...
        'Color', options.line_color, 'LineWidth', options.line_width)
    plot3([xv(1), xv(1)], [yv(1), yv(1)], [zv(1), zv(2)], ...
        'Color', options.line_color, 'LineWidth', options.line_width)

    function value = get_value(limits, side)
        if side
            value = [limits(end), limits(end) - (diff(limits) * proportion)];
        else
            value = [limits(1), limits(1) + (diff(limits) * proportion)];
        end
    end
end