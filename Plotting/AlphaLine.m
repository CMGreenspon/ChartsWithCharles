function AlphaLine(x, y, color, varargin)
    % Produces a line plot with the error boundary represented by a shaded area of the same color
    % AlphaLine(x [double], y[double], color[double], varargin)
    % AlphaLine(x, y, color, 'EdgeAlpha', 0.2, 'FaceAlpha', 0.2, 'ErrorType', 'SEM')
    % Only supports a single line at a time; this reduces ambiguity in matrix dimensions.
    % X must be a vector while Y must be an array [x, repeat] where at least one dimension is the same
    % as the length of x. If both are the size of x and the ration is ambiguous then
    % ensure format.
    % Color must be an RGB triplet (0-1 and 0-255 are both supported)
    % Optional inputs include: 'EdgeAlpha' [default = 0.2], 'FaceAlpha' [default = 0.2],
    % 'ErrorType' [default = 'SEM', 'STD', and 'Percentile' is also available], 
    
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
    
    % Check color input
    if all(size(color) ~= [1,3], 2)
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
    ErrorType = 'SEM';
    Percentiles = [25, 75];
    
    valid_inputs = {'LineWidth', 'FaceAlpha', 'EdgeAlpha', 'ErrorType', 'Percentiles'};
    
    % Check varargin
    if length(varargin) > 0
        nargin = ceil(length(varargin)/2);
        varargin = reshape(varargin, [2, nargin]);
        for n = 1:nargin
            % Check if valid input
            if any(strcmp(varargin{1,n}, valid_inputs)) == 0
                error_str = sprintf('%s is an unrecognized input.', varargin{1,n});
                error(error_str)
            end
            % Evaluate input
            if ischar(varargin{2,n})
               eval_str = sprintf('%s = ''%s'';', varargin{1,n}, varargin{2,n});
               eval(eval_str)
            elseif isnumeric(varargin{2,n})
               if all(size(varargin{2,n}) == 1)
                  eval_str = sprintf('%s = %d;', varargin{1,n}, varargin{2,n});
               else
                  eval_str = [varargin{1,n}, ' = [', num2str(varargin{2,n}), '];'];
               end
               eval(eval_str)
            end
        end
    end
    
    % Compute mean
    if strcmp(ErrorType, 'Percentile')
        y_central = nanmedian(y,2);
    else
        y_central = nanmean(y,2);
    end
    
    % Compute error
    if strcmp(ErrorType, 'STD')
        y_error = nanstd(y,2);
    elseif strcmp(ErrorType, 'SEM')
        y_error = nanstd(y,1,2) ./ sqrt(size(y,2));
    elseif strcmp(ErrorType, 'Percentile')
        y_p1 = prctile(y, Percentiles(1),2);
        y_p2 = prctile(y, Percentiles(2),2);
    end
    
    hold on
    % Plot error
    if strcmp(ErrorType, 'Percentile')
        fill([x; flipud(x)], [y_p1; flipud(y_p2)], ...
             color, 'EdgeColor', color, 'FaceAlpha', FaceAlpha, 'EdgeAlpha', EdgeAlpha)
    else
        fill([x; flipud(x)], [y_central+y_error; flipud(y_central-y_error)], ...
             color, 'EdgeColor', color, 'FaceAlpha', FaceAlpha, 'EdgeAlpha', EdgeAlpha)
    end
    % Mean
    plot(x, y_central, 'color', color, 'LineWidth', LineWidth)
    
end