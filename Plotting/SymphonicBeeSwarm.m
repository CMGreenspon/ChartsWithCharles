function SymphonicBeeSwarm(x, y, color, point_size, varargin)
    % Produces a distribution of points akin to a beeswarm, violin, or box and whisker
    % SymphonicBeeswarm(x, y, color, point_size, varargin)
    % Only supports a single group at a time as this reduces ambiguity in matrix dimensions.
    % X must be a single value while Y must be a vector
    % Color must be an RGB triplet (0-1 and 0-255 are both supported)
    % point_size refers to the scatter plot point size and must be an integer [default = 20]
    % Optional inputs include (default listed first): 
    % - 'CenterMethod' ['mean', 'median', 'none']: plots a line at the vlaue (will test for normality if mean is chosen)
    % - 'CenterColor' [same as color]: allows manaul selection the center line color
    % - 'CenterWidth' [.3] The x spread of the center line x-CenterWidth:x+CenterWidth
    % - 'BackgroundType' ['none', 'violin', 'bar', 'box']: background style
    % - 'DistributionMethod' ['Histogram', 'KernelDensity']: method of computing scatter distribution
    % - 'DistributionWidth' [.3] similar to center width
    % - 'BoxPercentiles' [5,25,75,95]: the 4 percentiles of the B&W plot
    % - 'BackroundFaceAlpha' [.1], 'BackroundEdgeAlpha' [.4]
    % - 'MarkerFaceAlpha' [.2], 'MarkerEdgeAlpha' [.4]
    % - 'MaxPoints' [100]: prevents over dense scattering

    % Check x,y inputs
    if all(size(x) ~= [1,1])
        error('X must be a single value')
    end
    
    if all(size(y) > 2)
        error('Y must be a vector')
    end
    
    % Check color input
    if all(size(color) == [1,3], 2) == 0
        if all(size(color) == [1,3],2)
            color = color';
        elseif any(size(color) > 3)
            error('Only 3 values [RGB] may be given for the color.')
        elseif size(color,2) == 3 && size(color,2) ~= 1
            error('Only one color may be given.')
        end
    end
    if any(color > 1); color = color ./ 255; end

    % Set default values
    CenterMethod = 'mean';
    CenterColor = color;
    CenterWidth = .3;
    DistributionMethod = 'KernelDensity';
    DistributionWidth = .3;
    BackgroundType = 'none';
    MarkerFaceAlpha = .2;
    MarkerEdgeAlpha = .4;
    BackroundFaceAlpha = .1;
    BackroundEdgeAlpha = .4;
    BoxPercentiles = [5,25,75,95];
    MaxPoints = 100;
    
    % Check varargin
    if isempty(varargin) == 0
        nargin = ceil(length(varargin)/2);
        varargin = reshape(varargin, [2, nargin]);
        for n = 1:nargin
            if strcmpi(varargin{1,n},'CenterMethod')
                CenterMethod = varargin{2,n};
            elseif strcmpi(varargin{1,n},'CenterColor')
                CenterColor = varargin{2,n};
            elseif strcmpi(varargin{1,n},'CenterWidth')
                CenterWidth = varargin{2,n};
            elseif strcmpi(varargin{1,n},'BackgroundType')
                BackgroundType = varargin{2,n};
            elseif strcmpi(varargin{1,n},'BackroundFaceAlpha')
                BackroundFaceAlpha = varargin{2,n};
            elseif strcmpi(varargin{1,n},'BackroundEdgeAlpha')
                BackroundEdgeAlpha = varargin{2,n};
            elseif strcmpi(varargin{1,n},'MarkerFaceAlpha')
                MarkerFaceAlpha = varargin{2,n};
            elseif strcmpi(varargin{1,n},'MarkerEdgeAlpha')
                MarkerEdgeAlpha = varargin{2,n};
            elseif strcmpi(varargin{1,n},'BoxPercentiles')
                BoxPercentiles = varargin{2,n};
            elseif strcmpi(varargin{1,n},'DistributionMethod')
                DistributionMethod = varargin{2,n};
            elseif strcmpi(varargin{1,n},'DistributionWidth')
                DistributionWidth = varargin{2,n};
            elseif strcmpi(varargin{1,n},'MaxPoints')
                MaxPoints = varargin{2,n};
            else
                error('%s is an unrecognized input.', varargin{1,n})
            end
        end
    end
    
    % Compute the mean
    if strcmpi(CenterMethod, 'mean')
        y_central = mean(y,'omitnan');
        h = lillietest(y, 'alpha', .01);
        if h
            warning('Mean CenterMethod is used but data is not normal')
        end
    elseif strcmpi(CenterMethod, 'median')
        y_central = median(y,'omitnan');
    elseif strcmpi(CenterMethod, 'none') == 0
        error('%s is an unrecognized CenterMethod.', CenterMethod)
    end
 
    % Get distribution
    if strcmpi(DistributionMethod, 'Histogram')
        [bin_prop, bin_edges, ~] = histcounts(y, 'BinMethod', 'sturges');
        proportional_bins = (bin_prop ./ max(bin_prop)) * DistributionWidth;
        
    elseif strcmpi(DistributionMethod, 'KernelDensity')
        [bin_prop, bin_points] = ksdensity(y, 'NumPoints', round(sqrt(length(y))));
        bin_edges = bin_points - (range(bin_points(1:2))/2);
        bin_edges = [bin_edges, bin_points(end) + (range(bin_points(1:2))/2)];
        proportional_bins = (bin_prop ./ max(bin_prop)) * DistributionWidth;
        
    else
        error('%s is an unrecognized distribution method.', DistributionMethod)
    end
    
    % Background
    hold on
    if strcmpi(BackgroundType, 'Bar')
        % Simple bar to the central value
        patch([x-DistributionWidth*1.1, x-DistributionWidth*1.1, x+DistributionWidth*1.1, x+DistributionWidth*1.1],...
              [0, y_central, y_central, 0], color, 'FaceAlpha', BackroundFaceAlpha,...
              'EdgeAlpha', BackroundEdgeAlpha, 'EdgeColor', color)
    elseif strcmpi(BackgroundType, 'Violin')
        % Get a nicer KS distribution with more points
        [violin_x, violin_y] = ksdensity(y);
        violin_x = (violin_x ./ max(violin_x)) * DistributionWidth * 1.25; 
        fill([violin_x, fliplr(-violin_x)] + x, [violin_y, fliplr(violin_y)],...
             color, 'EdgeColor', color, 'FaceAlpha', BackroundFaceAlpha, 'EdgeAlpha', BackroundEdgeAlpha)
    elseif strcmpi(BackgroundType, 'Box')
        y_50 = median(y,'omitnan');
        bw_y = prctile(y, BoxPercentiles);
        % Make the box
        patch([x-DistributionWidth*1.1, x-DistributionWidth*1.1, x+DistributionWidth*1.1, x+DistributionWidth*1.1],...
              [bw_y(2), bw_y(3), bw_y(3), bw_y(2)], color, 'FaceAlpha', BackroundFaceAlpha,...
              'EdgeAlpha', BackroundEdgeAlpha, 'EdgeColor', color)
        % Center line
        plot([x-DistributionWidth*1.1, x+DistributionWidth*1.1], [y_central, y_central], 'Color' , color, 'LineWidth', 1)
        % Whiskers
        plot([x,x], [bw_y(3), bw_y(4)], 'Color' , color, 'LineWidth', 1)
        plot([x-CenterWidth, x+CenterWidth], [bw_y(4), bw_y(4)], 'Color' , color, 'LineWidth', 1)
        plot([x,x], [bw_y(1), bw_y(2)], 'Color' , color, 'LineWidth', 1)
        plot([x-CenterWidth, x+CenterWidth], [bw_y(1), bw_y(1)], 'Color' , color, 'LineWidth', 1)
    elseif strcmpi(BackgroundType, 'none') == 0
        error('%s is an unrecognized BackgroundType.', BackgroundType)
    end    
    
    % The point swarm
    % Allocate x values to each bin
    [bin_y, bin_x] = deal(cell([length(bin_prop),1]));
    for b = 1:length(bin_prop)
        bin_y{b} = y(y > bin_edges(b) & y < bin_edges(b+1));
        temp_x = linspace(-proportional_bins(b), proportional_bins(b), length(bin_y{b}))';
        bin_x{b} = temp_x(randperm(length(temp_x)));
    end
    scatter_x = vertcat(bin_x{:});
    scatter_y = vertcat(bin_y{:});
    % Subsample
    if MaxPoints < length(scatter_x)
        rand_idx = randperm(length(scatter_x));
        scatter_x = scatter_x(rand_idx(1:MaxPoints));
        scatter_y = scatter_y(rand_idx(1:MaxPoints));
    end
    
    scatter(scatter_x+x, scatter_y, point_size, 'MarkerFaceColor', color, 'MarkerEdgeColor', color,...
        'MarkerFaceAlpha', MarkerFaceAlpha, 'MarkerEdgeAlpha', MarkerEdgeAlpha);
    
    % Center line on top if desired
    if isnumeric(CenterColor)
        plot([x-CenterWidth, x+CenterWidth], [y_central, y_central], 'Color' , CenterColor, 'LineWidth', 2)
    end
end