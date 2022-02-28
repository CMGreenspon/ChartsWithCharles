function AlphaLine(x, y, color, varargin)
    % Produces a line plot with the error boundary represented by a shaded area of the same color
    % AlphaLine(x [double], y[double], color[double], varargin)
    % AlphaLine(x, y, color, 'EdgeAlpha', 0.2, 'FaceAlpha', 0.2, 'ErrorType', 'SEM')
    % Only supports a single line at a time; this reduces ambiguity in matrix dimensions.
    % X (independent variable) must be a vector while Y (dependent variable) must be an array [x, repeated observations]
    % If both are the size of x and the ration is ambiguous then ensure format.
    % Color must be an RGB triplet (0-1 and 0-255 are both supported)
    % Optional inputs include: 'EdgeAlpha' [default = 0.2], 'FaceAlpha' [default = 0.2],
    % 'ErrorType' [default = 'SEM', 'STD', and 'Percentile' is also available]. If
    % 'Percentile' is passed then the argument 'Percentiles', [p1, p2] becomes available
    % and the median will be plotted instead of the mean.
    % 'IgnoreNan' [0: will break, 1: pretend NaNs aren't there, 2: plot on either side of
    % NaN as individual plots] will produce a different plot each time (see plotting example)
    % 'PlotBetweenNaN' [true] will place a dashed line between sections if IgnoreNan == 2
    
    % Check size inputs
    if all(size(x) > 1)
        error('X must be a vector.')
    end
    % Convert x to row vector
    if size(x,2) > size(x,1); x = x'; end
    
    % Ensure y is the correct orientation
    if size(y,1) ~= length(x)
        if all(size(y) ~= length(x))
            error('size(y) does not match length(x).')
        elseif size(y,2) == length(x)
            y = y';
        end
    end
    
    % Nan checking
    nan_idx = all(isnan(y),2);
    if ~isempty(nan_idx)
        % Check for trailing NaNs
        if nan_idx(end) || nan_idx(1)
            warning('Removing trailing NaNs') 
        end
        if nan_idx(end)
            while nan_idx(end)
                x = x(1:end-1);
                y = y(1:end-1,:);
                nan_idx = all(isnan(y),2);
            end
        end
        if nan_idx(1)
            while nan_idx(1)
                x = x(2:end);
                y = y(2:end,:);
                nan_idx = all(isnan(y),2);
            end
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
    if exist('color', 'var') == 0
        color = [.6 .6 .6];
    elseif all(size(color) ~= [1,3], 2)
        if all(size(color) == [1,3],2)
            color = color';
        elseif any(size(color) > 3)
            error('Only 3 values [RGB] may be given for the color.')
        end
    end
    if any(color > 1); color = color ./ 255; end
    
    % Set default values
    LineWidth = 1;
    FaceAlpha = 0.1;
    EdgeAlpha = 0.1;
    ErrorType = 'STD';
    Percentiles = [25, 75];
    IgnoreNaN = 0;
    PlotBetweenNaN = 1;
    LineStyle = '-';
    Parent = gca;
    hold on
        
    % Check varargin
    if isempty(varargin) == 0
        nargin = ceil(length(varargin)/2);
        varargin = reshape(varargin, [2, nargin]);
        for n = 1:nargin
            if strcmpi(varargin{1,n},'LineWidth')
                LineWidth = varargin{2,n};
            elseif strcmpi(varargin{1,n},'FaceAlpha')
                FaceAlpha = varargin{2,n};
            elseif strcmpi(varargin{1,n},'EdgeAlpha')
                EdgeAlpha = varargin{2,n};
            elseif strcmpi(varargin{1,n},'ErrorType')
                ErrorType = varargin{2,n};
                % Make this call a little more flexible
                if strcmpi(ErrorType, 'Percentiles')
                   ErrorType = 'Percentile';
                end
            elseif strcmpi(varargin{1,n},'Percentiles')
                Percentiles = varargin{2,n};
            elseif strcmpi(varargin{1,n},'IgnoreNaN')
                IgnoreNaN = varargin{2,n};
            elseif strcmpi(varargin{1,n},'PlotBetweenNaN')
                PlotBetweenNaN = varargin{2,n};
            elseif strcmpi(varargin{1,n},'LineStyle')
                LineStyle = varargin{2,n};
            elseif strcmpi(varargin{1,n},'Parent')
                Parent = varargin{2,n};
            else
                error('%s is an unrecognized input.', varargin{1,n})
            end
        end
    end
    
    
    % Compute mean
    if strcmpi(ErrorType, 'Percentile')
        y_central = median(y,2,'omitnan');
    else
        y_central = mean(y,2,'omitnan');
    end
    
    % Compute error
    if strcmpi(ErrorType, 'STD')
        y_error = std(y,1,2,'omitnan');
        y2 = [y_central+y_error; flipud(y_central-y_error)];
    elseif strcmpi(ErrorType, 'SEM')
        y_error = std(y,1,2, 'omitnan') ./ sqrt(size(y,2));
        y2 = [y_central+y_error; flipud(y_central-y_error)];
    elseif strcmpi(ErrorType, 'Percentile')
        y_p1 = prctile(y, Percentiles(1),2);
        y_p2 = prctile(y, Percentiles(2),2);
        y2 = [y_p1; flipud(y_p2)];
    else
        error('%s is an unrecognized ErrorType.', ErrorType)
    end
    
    % Check for NaN breaks
    if any(isnan(y_central))
       if IgnoreNaN == 0
           warning('NaNs in Y-array break the fill function. Explore the "IgnoreNan" option.') 
           PlotAlphaLine(x, y_central, y2)
       elseif IgnoreNaN == 1 % Ignore completely
           x2 = x(~isnan(y_central));
           y2_central = y_central(~isnan(y_central));
           y2_error = y2(~isnan(y2));
           PlotAlphaLine(x2, y2_central, y2_error)
       elseif IgnoreNaN == 2 % Make a separate line for each section
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
               if PlotBetweenNaN && n < num_plot_sections
                   if strcmp(LineStyle, '--')
                       LineStyle2 = ':';
                   else
                       LineStyle2 = '--';
                   end
                  plot([x(nan_idx(n)-1), x(nan_idx(n)+1)], [y_central(nan_idx(n)-1), y_central(nan_idx(n)+1)],...
                      'color', color, 'LineStyle', LineStyle2, 'Parent', Parent)
               end
           end
       end
    else
        PlotAlphaLine(x, y_central, y2)
    end
    
    function PlotAlphaLine(x2, y2_central, y2_error)
        % Error
        fill([x2; flipud(x2)], y2_error, color, 'EdgeColor', color, 'FaceAlpha', FaceAlpha, 'EdgeAlpha', EdgeAlpha, 'Parent', Parent)
        % Mean
        plot(x2, y2_central, 'color', color, 'LineWidth', LineWidth, 'LineStyle', LineStyle, 'Parent', Parent)
    end
end