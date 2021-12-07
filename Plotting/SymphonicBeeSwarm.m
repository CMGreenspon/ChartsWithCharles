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
    % - 'CenterThickness' [2] Linewidth of the center line
    % - 'BackgroundType' ['none', 'violin', 'bar', 'box']: background style
    % - 'DistributionMethod' ['Histogram', 'KernelDensity']: method of computing scatter distribution
    % - 'DistributionWidth' [.3] similar to center width
    % - 'BoxPercentiles' [5,25,75,95]: the 4 percentiles of the B&W plot
    % - 'BackroundFaceAlpha' [.1], 'BackroundEdgeAlpha' [.4]
    % - 'MarkerFaceAlpha' [.2], 'MarkerEdgeAlpha' [.4]
    % - 'MaxPoints' [100]: prevents over dense scattering. If MaxPoints == 0 then many
    % plots revert to simple plots. In this case error bars (from Percentiles) are added to the
    % Bar version. If Percentiles are an array then those percentiles will be used,
    % otherwise both 'STD' and 'SEM' are available.

    % Check x,y inputs
    if all(size(x) ~= [1,1])
        error('X must be a single value')
    end
    
    if all(size(y) > 2)
        error('Y must be a vector')
    elseif size(y,2) > 1 && size(y,1) == 1
        y = y';
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
    CenterThickness = 2;
    DistributionMethod = 'KernelDensity';
    DistributionWidth = .3;
    BackgroundType = 'none';
    MarkerFaceAlpha = .2;
    MarkerEdgeAlpha = .4;
    BackgroundFaceAlpha = .1;
    BackgroundEdgeAlpha = .4;
    BackgroundEdgeThickness = 1;
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
            elseif strcmpi(varargin{1,n},'CenterThickness')
                CenterThickness = varargin{2,n};
            elseif strcmpi(varargin{1,n},'BackgroundType')
                BackgroundType = varargin{2,n};
            elseif strcmpi(varargin{1,n},'BackgroundFaceAlpha')
                BackgroundFaceAlpha = varargin{2,n};
            elseif strcmpi(varargin{1,n},'BackgroundEdgeAlpha')
                BackgroundEdgeAlpha = varargin{2,n};
            elseif strcmpi(varargin{1,n},'BackgroundEdgeThickness')
                BackgroundEdgeThickness = varargin{2,n};
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
    
    % In the case of box and whisker 
    if strcmpi(BackgroundType, 'Box')
       % Check if the center was actually declared
       if any(strcmpi(varargin(1,:), 'CenterMethod')) == 0
           CenterMethod = 'median'; % If not then change default
       end
       % Also check if center width was declared
       if any(strcmpi(varargin(1,:), 'CenterWidth')) == 0
           CenterWidth = DistributionWidth / 3;
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
              [0, y_central, y_central, 0], color, 'FaceAlpha', BackgroundFaceAlpha, 'EdgeColor', 'none')
        % Have to manually place lines because Matlab is silly
        plot([x-DistributionWidth*1.1, x-DistributionWidth*1.1, x+DistributionWidth*1.1, x+DistributionWidth*1.1],...
             [0, y_central, y_central, 0], 'LineWidth', BackgroundEdgeThickness, 'Color', color)
        if MaxPoints == 0 % Add error bars
            if isnumeric(BoxPercentiles)
               if length(BoxPercentiles) == 4
                   ub = prctile(y, BoxPercentiles(2));
                   lb = prctile(y, BoxPercentiles(3));
               elseif length(BoxPercentiles) == 2
                   ub = prctile(y, BoxPercentiles(1));
                   lb = prctile(y, BoxPercentiles(2));
               else
                   error('Only 2 or 4 percentiles may be assigned to "Bar" when "MaxPoints" = 0')
               end
            elseif ischar(BoxPercentiles)
               if strcmpi(BoxPercentiles, 'STD')
                   ub = y_central + std(y,1,'all', 'omitnan');
                   lb = y_central - std(y,1,'all', 'omitnan');
               elseif strcmpi(BoxPercentiles, 'SEM')
                   ub = y_central + std(y,1,'all', 'omitnan') / sqrt(length(y));
                   lb = y_central - std(y,1,'all', 'omitnan') / sqrt(length(y));
               end
            end
            % Whiskers
            plot([x,x], [y_central, ub], 'Color' , color, 'LineWidth', 1)
            plot([x-CenterWidth/3, x+CenterWidth/3], [ub, ub], 'Color' , color, 'LineWidth', 1)
            plot([x,x], [y_central, lb], 'Color' , color, 'LineWidth', 1)
            plot([x-CenterWidth/3, x+CenterWidth/3], [lb, lb], 'Color' , color, 'LineWidth', 1)
            CenterColor = 'none';
        end
    elseif strcmpi(BackgroundType, 'Violin')
        % Get a nicer KS distribution with more points
        [violin_x, violin_y] = ksdensity(y, 'NumPoints', 100);
        violin_x = (violin_x ./ max(violin_x)) * DistributionWidth * 1.25; 
        % Get rid of top and bottom 5%
        violin_x = violin_x(6:95);
        violin_y = violin_y(6:95);
        fill([violin_x, fliplr(-violin_x)] + x, [violin_y, fliplr(violin_y)],...
             color, 'EdgeColor', color, 'FaceAlpha', BackgroundFaceAlpha,...
             'EdgeAlpha', BackgroundEdgeAlpha, 'LineWidth', BackgroundEdgeThickness)
    elseif strcmpi(BackgroundType, 'Box')
        y_50 = median(y,'omitnan');
        bw_y = prctile(y, BoxPercentiles);
        % Make the box
        patch([x-DistributionWidth*1.1, x-DistributionWidth*1.1, x+DistributionWidth*1.1, x+DistributionWidth*1.1],...
              [bw_y(2), bw_y(3), bw_y(3), bw_y(2)], color, 'FaceAlpha', BackgroundFaceAlpha,...
              'EdgeAlpha', BackgroundEdgeAlpha, 'EdgeColor', color, 'LineWidth', BackgroundEdgeThickness)
        % Whiskers
        plot([x,x], [bw_y(3), bw_y(4)], 'Color' , color, 'LineWidth', 1)
        plot([x-CenterWidth, x+CenterWidth], [bw_y(4), bw_y(4)], 'Color' , color, 'LineWidth', 1)
        plot([x,x], [bw_y(1), bw_y(2)], 'Color' , color, 'LineWidth', 1)
        plot([x-CenterWidth, x+CenterWidth], [bw_y(1), bw_y(1)], 'Color' , color, 'LineWidth', 1)
        % Thinner center line if points only
        if MaxPoints == 0
            plot([x-DistributionWidth*1.1, x+DistributionWidth*1.1], [y_central, y_central], 'Color' , color, 'LineWidth', 1)
            CenterColor = 'none';
        else
            CenterWidth = DistributionWidth*1.1;
        end
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
        plot([x-CenterWidth, x+CenterWidth], [y_central, y_central], 'Color' , CenterColor, 'LineWidth', CenterThickness)
    end

end