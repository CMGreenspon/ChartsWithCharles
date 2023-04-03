function SymphonicBeeSwarm(x, y, Color, PointSize, varargin)
warning('This function is now deprecated, use Swarm instead')
    % Produces a distribution of points akin to a beeswarm, violin, or box and whisker
    % SymphonicBeeSwarm(x, y, color, point_size, varargin)
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

    % Set default values
    CenterMethod = 'mean';
    CenterMethodDefined = 0;
    CenterWidth = .3;
    CenterThickness = 2;
    DistributionMethod = 'KernelDensity';
    DistributionWidth = .25;
    BackgroundType = 'none';
    BackgroundWidth = .3;
    MarkerFaceAlpha = .5;
    MarkerEdgeAlpha = 1;
    BackgroundFaceAlpha = .25;
    BackgroundEdgeAlpha = .5;
    BackgroundEdgeThickness = 1;
    BoxPercentiles = [5,25,75,95];
    Parent = gca;
    MaxPoints = 100;
    NormalityWarning = true;
    YLimits = [];
    MarkerType = "o";
    Hash = false;
    HashAngle = 45;
    HashSpacing = 0.1;
    % Check varargin
    ParseVarargin()

    % Check color input
    if all(size(Color) == [1,3])
        BackgroundColor = Color;
        Color = repmat(Color, [length(y),1]);
    elseif all(size(Color) == [3,1])
        Color = Color';
        Color = repmat(Color, [length(y),1]);
    elseif size(Color,2) ~= 3 || size(Color,1) ~= length(y)
        error('Color must be a matrix of length(y) x 3')
    else
        BackgroundColor = [.6 .6 .6];
    end
    CenterColor = BackgroundColor;
    
    if any(Color > 1); Color = Color ./ 255; end
    
    if all(size(y) > 2)
        error('Y must be a vector')
    elseif size(y,2) > 1 && size(y,1) == 1
        y = y';
    end
    
    % Remove NaN and Inf
    if any(isnan(y) | y==Inf)
        yidx = isnan(y) | y==Inf;
        Color = Color(~yidx, :);
        y = y(~yidx);
    end

    % Check if any values of y remain
    if isempty(y)
        warning('All values of y are inf or nan')
        return
    end    
    hold(Parent, 'on')
    
    % In the case of box and whisker 
    if strcmpi(BackgroundType, 'Box')
       % Check if the center was actually declared
       if ~any(strcmpi([varargin{1,:}], 'CenterMethod'))
           CenterMethod = 'median'; % If not then change default
       end
       % Also check if center width was declared
       if ~any(strcmpi(varargin(1,:), 'CenterWidth'))
           CenterWidth = DistributionWidth / 3;
       end
    end

    % Compute the mean
    if strcmpi(CenterMethod, 'mean')
        y_central = mean(y,'omitnan');
        if length(y) >= 4
            h = lillietest(y, 'alpha', .01);
            if h && CenterMethodDefined && NormalityWarning
                warning('Mean CenterMethod is used but data is not normal')
            elseif h && ~CenterMethodDefined
                CenterMethod = 'median';
                y_central = median(y,'omitnan');
            end
        end
    elseif strcmpi(CenterMethod, 'median')
        y_central = median(y,'omitnan');
    elseif ~strcmpi(CenterMethod, 'none')
        error('%s is an unrecognized CenterMethod.', CenterMethod)
    end

    % Check if we are limiting the distribution - must happen after stats are computed
    if ~isempty(YLimits)
        y(y < min(YLimits)) = min(YLimits);
        y(y > max(YLimits)) = max(YLimits);
    end
 
    % Get distribution
    if length(y) < 5 && ~strcmpi(DistributionMethod, 'none')
        warning('Too few y-values for a distribution')
        DistributionMethod = 'None';
        if strcmpi(BackgroundType, 'Violin')
            BackgroundType = 'Box';
        end
    end

    if strcmpi(DistributionMethod, 'Histogram')
        [bin_prop, bin_edges, ~] = histcounts(y, 'BinMethod', 'sturges');
        bin_centers = bin_edges(1:end-1) + (range(bin_edges(1:2))/2); %#ok<NASGU> 
        bin_prop = (bin_prop ./ max(bin_prop)) * DistributionWidth * 0.75;
        bin_prop = smoothdata(bin_prop, 'Gaussian', 3);
        
    elseif strcmpi(DistributionMethod, 'KernelDensity')
        % Low res for swarm
        [bin_prop, eval_points] = ksdensity(y, 'NumPoints', round(sqrt(length(y))));
        bin_prop = (bin_prop ./ max(bin_prop)) * DistributionWidth * 0.75;
        % Convert eval points to bin edges
        bin_edges = [eval_points - diff(eval_points(1:2))/2, eval_points(end) + diff(eval_points(1:2))/2];
    elseif ~strcmpi(DistributionMethod, 'None')
        error('%s is an unrecognized distribution method.', DistributionMethod)
    end
    
    % Background - could case/switch but strcmpi is slightly more flexible
    if strcmpi(BackgroundType, 'Bar')
        if strcmpi(CenterMethod, 'none')
            error('Cannot use CenterMethod == "none" with bar')
        end
        % Simple bar to the central value
        patch([x-BackgroundWidth, x-BackgroundWidth, x+BackgroundWidth, x+BackgroundWidth],...
              [0, y_central, y_central, 0], BackgroundColor, 'FaceAlpha', BackgroundFaceAlpha, 'EdgeColor', 'none', 'Parent', Parent)
        % Have to manually place lines because Matlab is silly
        plot([x-BackgroundWidth, x-BackgroundWidth, x+BackgroundWidth, x+BackgroundWidth],...
             [0, y_central, y_central, 0], 'LineWidth', BackgroundEdgeThickness, 'Color', BackgroundColor, 'Parent', Parent)
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
            plot([x,x], [y_central, ub], 'Color' , BackgroundColor, 'LineWidth', 1, 'Parent', Parent)
            plot([x-CenterWidth/3, x+CenterWidth/3], [ub, ub], 'Color' , BackgroundColor, 'LineWidth', 1, 'Parent', Parent)
            plot([x,x], [y_central, lb], 'Color' , BackgroundColor, 'LineWidth', 1, 'Parent', Parent)
            plot([x-CenterWidth/3, x+CenterWidth/3], [lb, lb], 'Color' , BackgroundColor, 'LineWidth', 1, 'Parent', Parent)
        end
    elseif strcmpi(BackgroundType, 'Violin')
        % Get rid of top and bottom 5%
        if length(BoxPercentiles) == 4
            lb = BoxPercentiles(1); ub = BoxPercentiles(4);
        elseif length(BoxPercentiles) == 2
            lb = BoxPercentiles(1); ub = BoxPercentiles(2);
        else 
            error('Only 2 or 4 percentiles may be assigned to "KernelDensity" when "MaxPoints" = 0')
        end
        
        y_trunc = y(y >= prctile(y, lb) & y <= prctile(y, ub));
        [violin_x, violin_y] = ksdensity(y_trunc, 'NumPoints', 100);
        violin_x = (violin_x ./ max(violin_x)) * BackgroundWidth; 
        % Scales
        proportional_bins = violin_x(lb:ub);
        bin_centers = violin_y(lb:ub);
        % Get a nicer KS distribution with more points
        fill([proportional_bins, fliplr(-proportional_bins)] + x, [bin_centers, fliplr(bin_centers)],...
             BackgroundColor, 'EdgeColor', BackgroundColor, 'FaceAlpha', BackgroundFaceAlpha,...
             'EdgeAlpha', BackgroundEdgeAlpha, 'LineWidth',...
             BackgroundEdgeThickness, 'Parent', Parent)
        % Make the centerwidth the width of the violin at the correct location
        if ~any(strcmpi(varargin(1,:), 'CenterWidth')) && ~strcmpi(CenterMethod, 'none')
            [~,c_idx] = min(abs(bin_centers - y_central));
            CenterWidth = proportional_bins(c_idx);
        end
    elseif strcmpi(BackgroundType, 'Box')
        bw_y = prctile(y, BoxPercentiles);
        % Make the box
        patch([x-BackgroundWidth, x-BackgroundWidth, x+BackgroundWidth, x+BackgroundWidth],...
              [bw_y(2), bw_y(3), bw_y(3), bw_y(2)], BackgroundColor, 'FaceAlpha', BackgroundFaceAlpha,...
              'EdgeAlpha', BackgroundEdgeAlpha, 'EdgeColor', BackgroundColor, 'LineWidth',...
              BackgroundEdgeThickness, 'Parent', Parent)
        % Whiskers
        plot([x,x], [bw_y(3), bw_y(4)], 'Color' , BackgroundColor, 'LineWidth', 1, 'Parent', Parent)
        plot([x-CenterWidth, x+CenterWidth], [bw_y(4), bw_y(4)], 'Color' , BackgroundColor, 'LineWidth', 1, 'Parent', Parent)
        plot([x,x], [bw_y(1), bw_y(2)], 'Color' , BackgroundColor, 'LineWidth', 1, 'Parent', Parent)
        plot([x-CenterWidth, x+CenterWidth], [bw_y(1), bw_y(1)], 'Color' , BackgroundColor, 'LineWidth', 1, 'Parent', Parent)
        % Thinner center line if points only
        if MaxPoints == 0
            plot([x-BackgroundWidth, x+BackgroundWidth],...
                [y_central, y_central], 'Color' , BackgroundColor, 'LineWidth', CenterThickness-1, 'Parent', Parent)
        else
            CenterWidth = BackgroundWidth;
        end
    elseif strcmpi(BackgroundType, 'none') == 0
        error('%s is an unrecognized BackgroundType.', BackgroundType)
    end  

    % Hashing
    if Hash && (strcmpi(BackgroundType, 'Box') || strcmpi(BackgroundType, 'Bar'))
        if strcmpi(BackgroundType, 'Box')
            yrange = bw_y([2,3]);
        elseif strcmpi(BackgroundType, 'Bar')
            yrange = sort([0 y_central]);
        end
        hash_height = tan(deg2rad(HashAngle)) * BackgroundWidth;
        y_init = yrange(1) - hash_height + range(yrange) * HashSpacing;
        [hash_x, hash_y] = deal([]);
        while y_init < yrange(2)
            y_term = y_init + hash_height;
            if y_init < yrange(1)
                hash_x = [hash_x; 
                    x+BackgroundWidth - ((y_term - yrange(1)) / tan(deg2rad(HashAngle)))*2; ...
                    x+BackgroundWidth; NaN];
                hash_y = [hash_y; yrange(1); y_term; NaN];
            elseif y_term > yrange(2)
                hash_x = [hash_x; x-BackgroundWidth;...
                    x-BackgroundWidth + ((yrange(2) - y_init) / tan(deg2rad(HashAngle)))*2; NaN];
                hash_y = [hash_y; y_init; yrange(2); NaN];
            else
                hash_x = [hash_x; x-BackgroundWidth; x+ BackgroundWidth; NaN];
                hash_y = [hash_y; y_init; y_term; NaN];
            end
            y_init = y_init + range(yrange) * HashSpacing;
        end
        plot(hash_x, hash_y, 'Color', BackgroundColor, 'LineWidth', CenterThickness-1)
    end
    
    % The point swarm
    if MaxPoints > 0 && PointSize > 0
        if strcmpi(DistributionMethod, 'Histogram') || strcmpi(DistributionMethod, 'KernelDensity')
            % Allocate x values to each bin
            [bin_y, bin_x, bin_c] = deal(cell([length(bin_prop),1]));
            for b = 1:length(bin_prop)
                bin_y{b} = y(y > bin_edges(b) & y <= bin_edges(b+1));
                bin_c{b} = Color(y > bin_edges(b) & y <= bin_edges(b+1),:);
                if b == 1 && any(y == bin_edges(b)) % Make sure the first edge doesn't get skipped
                    bin_y{b} = [bin_y{b}; y(y==b)];
                    bin_c{b} = [bin_c{b}; Color(y==b,:)];
                end
                temp_x = linspace(-bin_prop(b), bin_prop(b), length(bin_y{b}))';
                bin_x{b} = temp_x(randperm(length(temp_x)));
            end

            scatter_x = vertcat(bin_x{:});
            scatter_y = vertcat(bin_y{:});
            scatter_c = vertcat(bin_c{:});
        else
            scatter_x = zeros(size(y));
            scatter_y = y;
            scatter_c = Color;
        end
        
        % Subsample
        if MaxPoints < length(scatter_x)
            rand_idx = randperm(length(scatter_x));
            scatter_x = scatter_x(rand_idx(1:MaxPoints));
            scatter_y = scatter_y(rand_idx(1:MaxPoints));
            scatter_c = scatter_c(rand_idx(1:MaxPoints),:);
        end

        scatter(scatter_x+x, scatter_y, PointSize, scatter_c , MarkerType, "filled",'MarkerEdgeColor','flat',...
            'MarkerFaceAlpha', MarkerFaceAlpha, 'MarkerEdgeAlpha', MarkerEdgeAlpha, 'Parent', Parent);
    end
    
    % Center line on top if desired
    if isnumeric(CenterColor) && ~strcmpi(BackgroundType, 'Bar') && ~strcmpi(CenterMethod, 'none')
        plot([x-CenterWidth, x+CenterWidth], [y_central, y_central],...
            'Color', CenterColor, 'LineWidth', CenterThickness, 'Parent', Parent)
    end
    
    % Function for parsing varagin (just at end for tidiness)
    function ParseVarargin()
        if ~isempty(varargin)
            nargin = ceil(length(varargin)/2);
            varargin = reshape(varargin, [2, nargin]);
            for n = 1:nargin
                if strcmpi(varargin{1,n},'CenterMethod')
                    CenterMethod = varargin{2,n};
                    CenterMethodDefined = 1;
                elseif strcmpi(varargin{1,n},'BackgroundColor')
                    BackgroundColor = varargin{2,n};
                elseif strcmpi(varargin{1,n},'CenterColor')
                    CenterColor = varargin{2,n};
                elseif strcmpi(varargin{1,n},'CenterWidth')
                    CenterWidth = varargin{2,n};
                elseif strcmpi(varargin{1,n},'CenterThickness')
                    CenterThickness = varargin{2,n};
                elseif strcmpi(varargin{1,n},'BackgroundType')
                    BackgroundType = varargin{2,n};
                elseif strcmpi(varargin{1,n},'BackgroundWidth')
                    BackgroundWidth = varargin{2,n};
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
                elseif strcmpi(varargin{1,n},'Parent')
                    Parent = varargin{2,n};
                elseif strcmpi(varargin{1,n},'NormalityWarning')
                    NormalityWarning = varargin{2,n};
                elseif strcmpi(varargin{1,n},'YLimits')
                    YLimits = varargin{2,n};
                elseif strcmpi(varargin{1,n},'MarkerType')
                    MarkerType = varargin{2,n};
                elseif strcmpi(varargin{1,n},'Hash')
                    Hash = varargin{2,n};
                elseif strcmpi(varargin{1,n},'HashAngle')
                    HashAngle = varargin{2,n};
                elseif strcmpi(varargin{1,n},'HashSpacing')
                    HashSpacing = varargin{2,n};
                else
                    error('%s is an unrecognized input.', varargin{1,n})
                end
            end
        end
    end
end