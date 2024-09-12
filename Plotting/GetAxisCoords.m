function [ax_size, ax_val] = GetAxisCoords(num_plots, margin, border)
    if nargin < 3
        border = 0.1;
    end
    if nargin < 2
        margin = 0.1;
    end

    remainder = (1 - border * 2) - (margin * (num_plots - 1));
    ax_size = remainder / num_plots;
    ax_val = zeros(num_plots, 1);
    ax_val(1) = border;
    for i = 2:num_plots
        ax_val(i) = ax_val(i-1) + ax_size + margin;
    end
end