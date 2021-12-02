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
            elseif strcmpi(varargin{1,n},'Percentiles')
                Percentiles = varargin{2,n};
            else
                error('%s is an unrecognized input.', varargin{1,n})
            end
        end
    end
    
    
    % Compute mean
    if strcmp(ErrorType, 'Percentile')
        y_central = median(y,2,'omitnan');
    else
        y_central = mean(y,2,'omitnan');
    end
    
    % Compute error
    if strcmp(ErrorType, 'STD')
        y_error = std(y,1,2,'omitnan');
    elseif strcmp(ErrorType, 'SEM')
        y_error = std(y,1,2, 'omitnan') ./ sqrt(size(y,2));
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