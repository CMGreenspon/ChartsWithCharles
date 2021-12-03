function SymphonicBeeSwarm(x, y, color, point_size, varargin)
    % Produces a distribution of points akin to a beeswarm, violin, or box and whisker
    % SymphonicBeeswarm(x, y, color, point_size, varargin)
    % Only supports a single group at a time as this reduces ambiguity in matrix dimensions.
    % X must be a single value while Y must be a vector
    % Color must be an RGB triplet (0-1 and 0-255 are both supported)
    % point_size refers to the scatter plot point size and must be an integer [default = 20]
    % Optional inputs include (default listed first): 
    % - 'CenterMethod' ['mean', 'median', 'none']: will test for normality if mean is chosen
    % - 'CenterColor' [same as color]
    % - 'Background' ['none', 'violin', 'bar', 'box']
    % - 'DistributionMethod' ['Histogram', 'KernelDensity']
    % - 'MarkerFaceAlpha' [.1], 'MarkerEdgeAlpha' [.4]
    % - 'BackroundFaceAlpha' [.1], 'BackroundEdgeAlpha' [.2]
    % - 'BoxPercentiles' [5,25,75,95]: the 4 percentiles of the B&W plot
    % - 'DistributionWidth' [.3]
    %%
    clf;
    hold on
    x = 1;
    y = randn([100,1]);
    color = [.6 .6 .6];
    
    % Check x,y inputs
    if all(size(x) ~= [1,1])
        error('X must be a single value')
    end
    
    if all(size(y) > 2)
        error('Y must be a vector')
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
    CenterMethod = 'mean';
    DistributionMethod = 'kerneldensity';
    DistributionWidth = .3;
    Background = 'none';
    MarkerFaceAlpha = .1;
    MarkerEdgeAlpha = .4;
    BackroundFaceAlpha = .2;
    BackroundEdgeAlpha = .4;
    BoxPercentiles = [5,25,75,95];
    
    % Check varargin
    if isempty(varargin) == 0
        nargin = ceil(length(varargin)/2);
        varargin = reshape(varargin, [2, nargin]);
        for n = 1:nargin
            if strcmpi(varargin{1,n},'CenterMethod')
                CenterMethod = varargin{2,n};
            elseif strcmpi(varargin{1,n},'Background')
                Background = varargin{2,n};
            elseif strcmpi(varargin{1,n},'MarkerFaceAlpha')
                MarkerFaceAlpha = varargin{2,n};
            elseif strcmpi(varargin{1,n},'MarkerEdgeAlpha')
                MarkerEdgeAlpha = varargin{2,n};
            elseif strcmpi(varargin{1,n},'BackroundFaceAlpha')
                BackroundFaceAlpha = varargin{2,n};
            elseif strcmpi(varargin{1,n},'BackroundEdgeAlpha')
                BackroundEdgeAlpha = varargin{2,n};
            elseif strcmpi(varargin{1,n},'BoxPercentiles')
                BoxPercentiles = varargin{2,n};
            elseif strcmpi(varargin{1,n},'DistributionMethod')
                DistributionMethod = varargin{2,n};
            elseif strcmpi(varargin{1,n},'DistributionWidth')
                DistributionWidth = varargin{2,n};
            else
                error('%s is an unrecognized input.', varargin{1,n})
            end
        end
    end
    %%
    cla
    % Make the plot
    % Compute the mean
    if strcmpi(CenterMethod, 'mean')
        y_central = mean(y,'omitnan');
    elseif strcmpi(CenterMethod, 'median')
        y_central = median(y,'omitnan');
    end
 
    % Get distribution
    if strcmpi(DistributionMethod, 'histogram')
        [bin_prop, bin_edges, ~] = histcounts(y, 'BinMethod', 'sturges');
        proportional_bins = (bin_prop ./ max(bin_prop)) * DistributionWidth;
        
    elseif strcmpi(DistributionMethod, 'kerneldensity')
        [bin_prop, bin_points] = ksdensity(y, 'NumPoints', round(sqrt(length(y))));
        bin_edges = bin_points - (range(bin_points(1:2))/2);
        bin_edges = [bin_edges, bin_points(end) + (range(bin_points(1:2))/2)];
        proportional_bins = (bin_prop ./ max(bin_prop)) * DistributionWidth;
        
    else
        error('%s is an unrecognized distribution method.', DistributionMethod)
    end

    % Allocate x values to each bin
    [bin_y, bin_x] = deal(cell([length(bin_prop),1]));
    for b = 1:length(bin_prop)
        bin_y{b} = y(y > bin_edges(b) & y < bin_edges(b+1));
        temp_x = linspace(-proportional_bins(b), proportional_bins(b), length(bin_y{b}))';
        bin_x{b} = temp_x(randperm(length(temp_x)));
    end
    scatter_x = vertcat(bin_x{:});
    scatter_y = vertcat(bin_y{:});
    
    scatter(scatter_x+x, scatter_y, point_size, 'MarkerFaceColor', color, 'MarkerEdgeColor', color,...
        'MarkerFaceAlpha', MarkerFaceAlpha, 'MarkerEdgeAlpha', MarkerEdgeAlpha);
    
    if strcmp(CenterMethod, 'none') == 0
        plot([x-DistributionWidth, x+DistributionWidth], [y_central, y_central], 'Color' , [0.2 0.2 0.2], 'LineWidth', 2)
    end
    
    %%
end