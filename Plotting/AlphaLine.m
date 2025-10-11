function AlphaLine(x, y, color, options)
    % Produces a line plot with the error boundary represented by a shaded area of the same color
    % AlphaLine(x [double], y[double, cell], color[double], options)
    % AlphaLine(x, y, color, 'options.edge_alpha', 0.2, 'options.error_alpha', 0.2, 'options.error_type', 'SEM')
    % Only supports a single line at a time; this reduces ambiguity in matrix dimensions.
    % If both are the size of x and the ration is ambiguous then ensure format.
    %
    % Required inputs:
    % x {mustBeNumeric, mustBeVector}
    % y {mustBeMatrix}
    % 
    % Optional inputs:
    % color {mustBeNumeric} = [.6 .6 .6];
    %
    % Varargin inputs:
    % line_width (1,1) {mustBeInteger} = 1;
    % error_alpha (1,1) {mustBeFloat} = 0.1;
    % edge_alpha (1,1) {mustBeFloat} = 0.1;
    % error_type {mustBeMember(options.error_type, ["STD", "SEM", "Percentile"])} = 'STD';
    % percentiles {mustBeNumeric, mustBeVector} = [25, 75];
    % ignore_nan {mustBeMember(options.ignore_nan, [0, 1, 2])} = 2;
    % interpolate_nan {mustBeNumericOrLogical} = 1;
    % line_style {mustBeMember(options.line_style, ["--", "-", ":"])} = '-';
    % edge_style {mustBeMember(options.edge_style, ["--", "-", ":"])} = '-';
    % parent = gca;
    
    arguments
        x {mustBeNumeric, mustBeVector}
        y {mustBeMatrix}
        color (1,3) {mustBeNumeric, mustBeVector} = [.6 .6 .6];
        options.line_width {mustBeInteger, mustBeScalarOrEmpty} = 1;
        options.error_alpha {mustBeFloat, mustBeScalarOrEmpty} = 0.1;
        options.edge_alpha {mustBeFloat, mustBeScalarOrEmpty} = 0.1;
        options.error_type {mustBeMember(options.error_type, ["STD", "SEM", "Percentile"])} = 'STD';
        options.percentiles {mustBeNumeric, mustBeVector} = [25, 75];
        options.ignore_nan {mustBeMember(options.ignore_nan, [0, 1, 2])} = 2;
        options.interpolate_nan {mustBeNumericOrLogical} = 1;
        options.line_style {mustBeMember(options.line_style, ["--", "-", ":"])} = '-';
        options.edge_style {mustBeMember(options.edge_style, ["--", "-", ":"])} = '-';
        options.parent = gca;
    end
    
    % Convert x to row vector (necessary for fill function)
    if size(x,2) > size(x,1); x = x'; end
    
    % Ensure y is the correct orientation
    if size(y,1) ~= length(x)
        if all(size(y) ~= length(x))
            error('size(y) does not match length(x).')
        elseif size(y,2) == length(x)
            y = y';
        end
    end

    % If given a cell array then convert to a padded matrix
    if isa(y, "cell")
        max_y = max(cellfun(@length, y));
        y_new = NaN(length(x), max_y);
        for i = 1:length(x)
            y_new(i,1:length(y{i})) = y{i};
        end
        y = y_new;
    end
    
    % Nan checking
    nan_idx = all(isnan(y),2);
    if all(nan_idx)
        warning('Y only contains NaNs.')
        return
    elseif ~isempty(nan_idx)
        % Check at the beginning
        nan_1_idx = find(~nan_idx, 1, 'first');
        if ~isempty(nan_1_idx)
            x = x(nan_1_idx:end, :);
            y = y(nan_1_idx:end, :);
            nan_idx = all(isnan(y),2);
        end

        % Check at the end
        nan_end_idx = find(~all(isnan(y),2), 1, 'last');
        if ~isempty(nan_1_idx)
            x = x(1:nan_end_idx, :);
            y = y(1:nan_end_idx, :);
            nan_idx = all(isnan(y),2);
        end
        
        % Check for sequential NaNs
        filt_idx = ones([length(x),1]);
        for i = 1:length(x)
            if nan_idx(i) && nan_idx(i+1)
                filt_idx(i+1) = 0;
            end
        end
        x = x(logical(filt_idx));
        y = y(logical(filt_idx),:);
    end
    
    % Check color input
    if all(size(color) ~= [1,3], 2)
        if all(size(color) == [1,3],2)
            color = color';
        elseif any(size(color) > 3)
            error('Only 3 values [RGB] may be given for the color.')
        end
    end
    if any(color > 1); color = color ./ 255; end
    
    % Enture parent is held on
    hold(options.parent, 'on')
    
    % Compute mean
    if strcmpi(options.error_type, 'Percentile')
        y_central = median(y, 2, 'omitnan');
    else
        y_central = mean(y, 2, 'omitnan');
    end
    
    % Compute error
    if strcmpi(options.error_type, 'STD')
        y_error = std(y,1,2, 'omitnan');
        y2 = [y_central+y_error; flipud(y_central-y_error)];
    elseif strcmpi(options.error_type, 'SEM')
        y_error = std(y,1,2, 'omitnan') ./ sqrt(size(y,2));
        y2 = [y_central+y_error; flipud(y_central-y_error)];
    elseif strcmpi(options.error_type, 'Percentile')
        y_p1 = prctile(y, options.percentiles(1),2);
        y_p2 = prctile(y, options.percentiles(2),2);
        y2 = [y_p1; flipud(y_p2)];
    end
    
    % Check for NaN breaks
    if any(isnan(y_central))
       if options.ignore_nan == 0
           warning('NaNs in Y-array break the fill function. Explore the "options.ignore_nan" option.') 
           PlotAlphaLine(x, y_central, y2)
       elseif options.ignore_nan == 1 % Ignore completely
           x2 = x(~isnan(y_central));
           y2_central = y_central(~isnan(y_central));
           y2_error = y2(~isnan(y2));
           PlotAlphaLine(x2, y2_central, y2_error)
       elseif options.ignore_nan == 2 % Make a separate line for each section
           nan_idx = find(isnan(y_central));
           num_plot_sections = length(nan_idx) + 1;
           % Error bounds
           y_temp = [y2(1:length(y2)/2), flipud(y2(length(y2)/2+1:end))];
           for n = 1:num_plot_sections
               if n == 1
                   x2 = x(1:nan_idx(n)-1);
                   y2_central = y_central(1:nan_idx(n)-1);
                   y2_error = y_temp(1:nan_idx(n)-1, :);
                   y2_error = [y2_error(:,1); flipud(y2_error(:,2))];
               elseif n == num_plot_sections
                   x2 = x(nan_idx(n-1)+1:end);
                   y2_central = y_central(nan_idx(n-1)+1:end);
                   y2_error = y_temp(nan_idx(n-1)+1:end, :);
                   y2_error = [y2_error(:,1); flipud(y2_error(:,2))];
               else
                   x2 = x(nan_idx(n-1)+1:nan_idx(n)-1);
                   y2_central = y_central(nan_idx(n-1)+1:nan_idx(n)-1);
                   y2_error = y_temp(nan_idx(n-1)+1:nan_idx(n)-1, :);
                   y2_error = [y2_error(:,1); flipud(y2_error(:,2))];
               end
               PlotAlphaLine(x2, y2_central, y2_error)
               if options.interpolate_nan && n < num_plot_sections
                   if strcmp(options.line_style, '--')
                       LineStyle2 = ':';
                   else
                       LineStyle2 = '--';
                   end
                  plot([x(nan_idx(n)-1), x(nan_idx(n)+1)], [y_central(nan_idx(n)-1), y_central(nan_idx(n)+1)],...
                      'color', color, 'LineStyle', LineStyle2, 'Parent', options.parent)
               end
           end
       end
    else
        PlotAlphaLine(x, y_central, y2)
    end
    
    function PlotAlphaLine(x2, y2_central, y2_error)
        % Error
        fill([x2; flipud(x2)], y2_error, color, 'EdgeColor', color, 'FaceAlpha',...
            options.error_alpha, 'EdgeAlpha', options.edge_alpha, 'LineStyle', ...
            options.edge_style, 'Parent', options.parent)
        % Mean
        plot(x2, y2_central, 'color', color, 'LineWidth', options.line_width, 'LineStyle',...
            options.line_style, 'Parent', options.parent)
    end
end