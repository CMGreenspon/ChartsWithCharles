function AddFigureLabels(h, label_offset, caps)
    if nargin == 1
        label_offset = [.05 .05]; % annotation margin
        caps = true;
    elseif nargin == 2
        caps = true;
    end

    if islogical(caps)
        if caps
            char_offset = 64;
        else
            char_offset = 96;
        end
    elseif isnumeric(caps)
        char_offset = caps;
    end

    if isa(h, 'matlab.graphics.axis.Axes')
        num_labels = length(h);
    elseif isa(h, 'matlab.ui.Figure')
        tl = false;
        if isa(h.Children(1), 'matlab.graphics.layout.TiledChartLayout')
            tl = true;
            num_labels = length(h.Children(1).Children);
        else
            num_labels = length(h.Children);
        end
    end
    
    if size(label_offset,1) == 1 && num_labels > 1
        label_offset = repmat(label_offset, num_labels,1);
    elseif size(label_offset,1) ~= num_labels
        error('%d offsets given for %d handles', size(label_offset,1), num_labels)
    end

    for i = 1:num_labels
        if any(isnan(label_offset(i,:))) % Purposeful skip (e.g. insets)
            continue
        end

        if isa(h, 'matlab.graphics.axis.Axes')
            ax_pos = h(i).Position;
        elseif isa(h, 'matlab.ui.Figure') && ~tl
            ax_pos = h.Children(num_labels-i+1).Position;
        elseif isa(h, 'matlab.ui.Figure') && tl
            ax_pos = h.Children(1).Children(num_labels-i+1).Position;
        end
        
        x1 = ax_pos(1) - label_offset(i,1);
        y1 = ax_pos(2) + ax_pos(4) - label_offset(i,2);

        % Ensure values in range
        if x1 < 0
            x1 = 0;
        elseif x1 > 1
            x1 = 1;
        end

        if y1 < 0
            y1 = 0;
        elseif y1 > 1
            y1 = 1;
        end 
        annotation("textbox", [x1 y1 .05 .05], 'String', char(char_offset+i), ...
            'VerticalAlignment','top', 'HorizontalAlignment','left', 'EdgeColor', 'none', 'FontWeight','bold')
    end
    shg;
end