function [ax_size, ax_val] = GetAxisCoords(num_plots, margin, border, flip)
    arguments
        num_plots {mustBeInteger}
        margin {mustBeFloat} = 0.1;
        border {mustBeFloat} = 0.1;
        flip {mustBeNumericOrLogical} = false;
    end
    
    % Compute total space less border and margins
    remainder = (1 - border * 2) - (margin * (num_plots - 1));
    % Size per plot
    ax_size = remainder / num_plots;
    ax_val = zeros(num_plots, 1);
    % First plot starts at the border value
    ax_val(1) = border;

    if num_plots == 1
        return
    end
    
    % Increment subsequent plots by size plus margin
    for i = 2:num_plots
        ax_val(i) = ax_val(i-1) + ax_size + margin;
    end

    % For y-values
    if flip
        ax_val = flipud(ax_val);
    end
end