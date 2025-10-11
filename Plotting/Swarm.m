function Swarm(x, y, options)
    % Produces a distribution of points akin to a beeswarm, violin, or box and whisker
    % Swarm(x, y, options)
    % Only supports a single group at a time as this reduces ambiguity in matrix dimensions.
    arguments
        x {mustBeNumeric}
        y {mustBeNumeric}
        options.color {mustBeNumeric, mustBeVector} = [.6 .6 .6];
        options.center_method {mustBeText, mustBeMember(options.center_method, ...
            ["mean", "median"])} = 'mean';
        options.error_method {mustBeText, mustBeMember(options.error_method, ...
            ["percentiles", "STD", "SEM"])} = 'STD';
        options.center_line_width {mustBeNumeric, mustBeScalarOrEmpty} = 2;
        options.center_color = [];
        options.error_percentiles {mustBeNumeric, mustBeVector} = [5,25,75,95];
        options.error_whiskers {mustBeNumericOrLogical, mustBeScalarOrEmpty} = true;
        % Distribution options
        options.distribution_method {mustBeText, mustBeMember(options.distribution_method, ...
            ["Histogram", "KernelDensity", "None"])} = 'None';
        options.distribution_style {mustBeText, mustBeMember(options.distribution_style, ...
            ["None", "Box", "Bar", "Violin", "Stacks"])} = 'None';
        options.distribution_width {mustBeFloat, mustBeScalarOrEmpty} = .25;
        options.distribution_color = [];
        options.distribution_face_alpha {mustBeNumeric, mustBeScalarOrEmpty} = .3;
        options.distribution_line_width {mustBeNumeric, mustBeScalarOrEmpty} = 1;
        options.distribution_line_alpha {mustBeNumeric, mustBeScalarOrEmpty} = .75;
        options.distribution_whisker_ratio {mustBeNumeric, mustBeScalarOrEmpty} = .3;
        options.num_stacks {mustBeInteger, mustBeScalarOrEmpty} = 0; 
        % Swarm options
        options.swarm_marker_size {mustBeInteger, mustBeScalarOrEmpty} = 30;
        options.swarm_y_limits {mustBeNumeric, mustBeVector} = [-inf, inf];
        options.swarm_point_limit {mustBeInteger, mustBeScalarOrEmpty} = 100;
        options.swarm_face_alpha {mustBeNumeric, mustBeScalarOrEmpty} = .5; 
        options.swarm_edge_alpha {mustBeNumeric, mustBeScalarOrEmpty} = 1;
        options.swarm_marker_type {mustBeTextScalar} = 'o';
        options.swarm_marker_colors = [];
        options.swarm_width_ratio {mustBeNumeric, mustBeScalarOrEmpty} = 0.75;
        % Hashing options (box & bar only)
        options.hash_style {mustBeText, mustBeMember(options.hash_style, ...
            ["None", "\", "/", "#"])} = 'None';
        options.hash_angle {mustBeNumeric, mustBeScalarOrEmpty} = 45; 
        options.hash_density {mustBeNumeric, mustBeScalarOrEmpty} = 0.1;
        options.hash_offset {mustBeNumeric, mustBeScalarOrEmpty} = [];
        % Other
        options.parent = [];
        options.show_stats {mustBeNumericOrLogical} = false;
        options.group_name = num2str(x); % For outpur of center +/- error
        options.violin_sides {mustBeText, mustBeMember(options.violin_sides, ...
            ["Right", "Left", "Both"])} = 'Both';
    end
    
    % First check x & y for validity
    if isnumeric(x) && all(size(x) ~= [1,1])
        error('X must be a scalar of size [1,1].')
    end
    if all(size(y) > 2) || ~isnumeric(y)
        error('Y must be a numeric vector.')
    elseif size(y,2) > 1 && size(y,1) == 1
        y = y'; % Transpose
    end
    
    % Remove NaN and Inf
    yidx = isnan(y) | y == Inf | y == -Inf;
    if any(yidx)
        y = y(~yidx);
    end
    % Check if any values of y remain
    if isempty(y)
        warning('All values of y are inf or nan.')
        return
    end

    % Set default center and error methods - varargin can override
    if length(y) < 4
        h = true;
        warning('Fewer than 4 points means a distribution cannot be computed')
        options.distribution_style = 'None';
    else
        h = lillietest(y, 'alpha', .01);
    end
    if h && (~strcmpi(options.center_method, 'median') || ~strcmpi(options.error_method, 'percentiles'))
        warning('Data is not normally distributed but median center method and percentile error method are not selected')
    end
    
    % Get the parent axis and ensure held on
    if isempty(options.parent)
        options.parent = gca;
    end
    hold(options.parent, 'on')
    
    % Compute y_central
    if strcmpi(options.center_method, 'mean')
        y_central = mean(y);
    elseif strcmpi(options.center_method, 'median')
        y_central = median(y);
    end

    % Compute y_error
    if strcmpi(options.error_method, 'percentile')
        if length(options.error_percentiles) == 2
            y_error = prctile(y, options.error_percentiles);
            p = options.error_percentiles;
        elseif length(options.error_percentiles) == 4
            y_error = prctile(y, options.error_percentiles([2,3]));
            p = options.error_percentiles([2,3]);
        end
        stat_str = sprintf('Group "%s": Median (P(%d), P(%d)) = %0.2f (%0.2f, %0.2f)',...
            options.group_name, p(1), p(2), y_central, y_error(1), y_error(2));
    elseif strcmpi(options.error_method, 'STD')
        p = std(y);
        y_error = y_central + [p, -p];
        stat_str = sprintf('Group "%s": Mean %s %s = %0.2f %s %0.2f',...
            options.group_name, GetUnicodeChar('PlusMinus'), options.error_method, y_central, GetUnicodeChar('PlusMinus'), p);
    elseif strcmpi(options.error_method, 'SEM')
        p = std(y)/sqrt(length(y));
        y_error = y_central + [p, -p];
        stat_str = sprintf('Group "%s": Mean %s %s = %0.2f %s %0.2f',...
            options.group_name, GetUnicodeChar('PlusMinus'), options.error_method, y_central, GetUnicodeChar('PlusMinus'), p);
    end
    
    if options.show_stats
        disp(stat_str)
    end
    
    % Check color inputs
    if isempty(options.center_color)
        options.center_color = options.color;
    end
    if isempty(options.distribution_color)
        options.distribution_color = options.color;
    end
    if isempty(options.swarm_marker_colors)
        options.swarm_marker_colors = repmat(options.color, [length(y),1]);
    elseif size(options.swarm_marker_colors,1) == length(yidx)
        options.swarm_marker_colors = options.swarm_marker_colors(~yidx, :);
    elseif size(options.swarm_marker_colors, 1) == 1
        options.swarm_marker_colors = repmat(options.swarm_marker_colors, [length(yidx),1]);
    end
    
    % Truncate y-values
    SwarmY = y;
    SwarmX = zeros(size(y));
    if ~isempty(options.swarm_y_limits)
        SwarmY(SwarmY > max(options.swarm_y_limits)) = max(options.swarm_y_limits);
        SwarmY(SwarmY < min(options.swarm_y_limits)) = min(options.swarm_y_limits);
    end
    
    % Siding
    if ~strcmpi(options.violin_sides, 'Both') && ~strcmpi(options.distribution_style, 'violin')
        error('Sided plots are only valid for Violin')
    end

    if strcmpi(options.violin_sides, 'Both')
        DistributionWidthArr = [-options.distribution_width, -options.distribution_width, options.distribution_width, options.distribution_width];
    elseif strcmpi(options.violin_sides, 'Right')
        DistributionWidthArr = [-options.distribution_width, -options.distribution_width, 0, 0];
        options.distribution_whisker_ratio = options.distribution_whisker_ratio / 2;
    elseif strcmpi(options.violin_sides, 'Left')
        DistributionWidthArr = [0, 0, options.distribution_width, options.distribution_width];
        options.distribution_whisker_ratio = options.distribution_whisker_ratio / 2;
    end
    
    
    % Plot background
    switch lower(options.distribution_style) % Because switch has no case-invariant mode
        case 'box'
            if strcmpi(options.error_method, 'Percentile')
                if length(options.error_percentiles) ~= 4
                    error('When using "options.distribution_style: Box", you must pass 4 values to "options.error_percentiles" and set "options.error_method: Percentile".')
                end
            end
            % Box
            patch(x+DistributionWidthArr, y_error([1,2,2,1]), ...
                  options.distribution_color, 'FaceAlpha', options.distribution_face_alpha, ...
                  'EdgeAlpha', options.distribution_line_alpha, 'EdgeColor', options.distribution_color, 'LineWidth', ...
                  options.distribution_line_width, 'parent', options.parent)
            % Whiskers
            if options.error_whiskers
                plot([x,x], [y_error(2), prctile(y, options.error_percentiles(4))],...
                    'Color' , [options.distribution_color, options.distribution_line_alpha], 'LineWidth', options.distribution_line_width, 'parent', options.parent)
                plot([x-options.distribution_width*options.distribution_whisker_ratio,x+options.distribution_width*options.distribution_whisker_ratio],...
                    prctile(y, options.error_percentiles([4,4])), 'Color' , [options.distribution_color, options.distribution_line_alpha], 'LineWidth', options.distribution_line_width, 'parent', options.parent)
                plot([x,x], [y_error(1), prctile(y, options.error_percentiles(1))],...
                    'Color' , [options.distribution_color, options.distribution_line_alpha], 'LineWidth', options.distribution_line_width, 'parent', options.parent)
                plot([x-options.distribution_width*options.distribution_whisker_ratio,x+options.distribution_width*options.distribution_whisker_ratio],...
                    prctile(y, options.error_percentiles([1,1])), 'Color' , [options.distribution_color, options.distribution_line_alpha], 'LineWidth', options.distribution_line_width, 'parent', options.parent)
            end
    
        case 'bar'
            % Bar
            patch(x+DistributionWidthArr, ...
                  [0, y_central, y_central, 0],...
                  options.distribution_color, 'FaceAlpha', options.distribution_face_alpha, ...
                  'EdgeAlpha', 0, 'EdgeColor', options.distribution_color, 'LineWidth', ...
                  options.distribution_line_width, 'parent', options.parent)
            plot(x+DistributionWidthArr, ...
                 [0, y_central, y_central, 0], 'Color' , [options.distribution_color, options.distribution_line_alpha], 'LineWidth', ...
                  options.distribution_line_width, 'parent', options.parent)
            % Whiskers
            if options.error_whiskers && length(y) > 1
                plot([x,x], [y_central,y_error(2)], 'Color' , [options.distribution_color, options.distribution_line_alpha], 'LineWidth', options.distribution_line_width, 'parent', options.parent)
                plot([x-options.distribution_width*options.distribution_whisker_ratio,x+options.distribution_width*options.distribution_whisker_ratio],...
                    y_error([2,2]), 'Color' , [options.distribution_color, options.distribution_line_alpha], 'LineWidth', options.distribution_line_width, 'parent', options.parent)
                plot([x,x], [y_central,y_error(1)], 'Color' , [options.distribution_color, options.distribution_line_alpha], 'LineWidth', options.distribution_line_width, 'parent', options.parent)
                plot([x-options.distribution_width*options.distribution_whisker_ratio,x+options.distribution_width*options.distribution_whisker_ratio],...
                    y_error([1,1]), 'Color' , [options.distribution_color, options.distribution_line_alpha], 'LineWidth', options.distribution_line_width, 'parent', options.parent)
            end
    
        case 'violin'
            [violin_x, violin_y] = ksdensity(SwarmY, 'NumPoints', 100);
            violin_x = violin_x(options.error_percentiles(1):options.error_percentiles(end));
            violin_x = rescale(violin_x, 0, options.distribution_width);
            violin_y = violin_y(options.error_percentiles(1):options.error_percentiles(end));
            % Apply siding
            if strcmpi(options.violin_sides, 'Both')
                fill([violin_x, fliplr(-violin_x)] + x, [violin_y, fliplr(violin_y)],...
                     options.distribution_color, 'EdgeColor', options.distribution_color, 'FaceAlpha', options.distribution_face_alpha,...
                     'EdgeAlpha', options.distribution_line_alpha, 'LineWidth', options.distribution_line_width, 'parent', options.parent)
            elseif strcmpi(options.violin_sides, 'Right')
                fill([violin_x, zeros(size(violin_x))] + x, [violin_y, fliplr(violin_y)],...
                     options.distribution_color, 'EdgeColor', options.distribution_color, 'FaceAlpha', options.distribution_face_alpha,...
                     'EdgeAlpha', options.distribution_line_alpha, 'LineWidth', options.distribution_line_width, 'parent', options.parent)
            elseif strcmpi(options.violin_sides, 'Left')
                fill([zeros(size(violin_x)), fliplr(-violin_x)] + x, [violin_y, fliplr(violin_y)],...
                     options.distribution_color, 'EdgeColor', options.distribution_color, 'FaceAlpha', options.distribution_face_alpha,...
                     'EdgeAlpha', options.distribution_line_alpha, 'LineWidth', options.distribution_line_width, 'parent', options.parent)
            end
            
        case 'stacks'
            if options.num_stacks == 0
                [stack_x, stack_y, ~] = histcounts(SwarmY, 'BinMethod', 'sturges');
            else
                [stack_x, stack_y, ~] = histcounts(SwarmY, options.num_stacks);
            end
            stack_x = (stack_x ./ max(stack_x)) * options.distribution_width * options.swarm_width_ratio;
            stack_x(stack_x == 0) = options.distribution_width / 25;
            stack_xx = reshape(repmat(stack_x, 2,1), [], 1);
            stack_yy = reshape(cat(1, stack_y(1:end-1), stack_y(2:end)), [], 1);
            fill([stack_xx; flipud(-stack_xx)] + x, [stack_yy; flipud(stack_yy)],...
                 options.distribution_color, 'EdgeColor', options.distribution_color, 'FaceAlpha', options.distribution_face_alpha,...
                 'EdgeAlpha', options.distribution_line_alpha, 'LineWidth', options.distribution_line_width, 'parent', options.parent)
    end
    
    % Hash overlay
    if ~strcmpi(options.hash_style, 'None') && any(strcmpi(options.distribution_style, {'Box', 'Bar'})) && strcmpi(options.violin_sides, 'both')
        % Determine hash range
        if strcmpi(options.distribution_style, 'Box')
            hmin = y_error(1);
            hmax = y_error(2);
        elseif strcmpi(options.distribution_style, 'Bar')
            hmin = min([0, y_central]);
            hmax = max([0, y_central]);
        end
        if any(strcmp(options.hash_style, {'/', '\', '\/', '/\'}))
            if strcmp(options.hash_style, '/\') || strcmp(options.hash_style, '\/')
                options.hash_angle = [options.hash_angle, options.hash_angle-90];
            end
            for HA = options.hash_angle
                % Simplify hash angle
                FlipHash = false;
                if HA < 0
                    FlipHash = true;
                    HA = abs(HA); %#ok<FXSET> 
                end
                % Determine number of hashes based on options.hash_density and range
                hash_height = tan(deg2rad(HA)) * options.distribution_width / 2;
                hash_slope = hash_height / (options.distribution_width * 2);
                if isempty(options.hash_offset)
                    options.hash_offset = range([hmin, hmax]) * options.hash_density;
                end
                num_hashes = floor(range([hmin-hash_height, hmax]) / options.hash_offset); % Just a guess
                [hash_x, hash_y] = deal(cell(num_hashes,1));
                % Start at the bottom and assert that all hashes are in bounds
                yrt = options.hash_offset + hmin; % Target Yr
                for h = 1:num_hashes
                    % Compute XR for YR
                    if yrt > hmax
                        xr = (x + options.distribution_width) - (yrt - hmax) / hash_slope;
                        yr = hmax;
                    else
                        yr = yrt;
                        xr = x + options.distribution_width;
                    end
    
                    % Compute YL wrt YRT
                    yl = yrt - hash_slope * options.distribution_width * 2;
                    if yl < hmin
                        yl = hmin;
                        xl = xr - (yr - yl) / hash_slope;
                    elseif yl > hmax
                        break
                    else
                        xl = x - options.distribution_width;
                    end
                    % Assign
                    hash_x{h} = [xl,xr,NaN];
                    hash_y{h} = [yl,yr,NaN];
    
                    % Update
                    yrt = yrt + options.hash_offset;
                end
                hash_x = cat(2, hash_x{:});
                hash_y = cat(2, hash_y{:});
                if FlipHash
                     hash_x = ((hash_x - x) .* -1) + x;
                end
                plot(hash_x, hash_y, 'Color', options.distribution_color, 'LineWidth', options.distribution_line_width)
            end
    
        elseif strcmp(options.hash_style, '#')
            if isempty(options.hash_offset)
                HashXOffset = options.distribution_width * 2 * options.hash_density;
                HashYOffset = range([hmin, hmax]) * options.hash_density;
            elseif isscalar(options.hash_offset)
                [HashXOffset, HashYOffset] = deal(options.hash_offset);
            elseif length(options.hash_offset) == 2
                HashXOffset = options.hash_offset(1);
                HashYOffset = options.hash_offset(2);
            end
            % Indices
            hx = x - options.distribution_width + HashXOffset : HashXOffset : x + options.distribution_width - HashXOffset;
            hy = hmin + HashYOffset : HashYOffset : hmax - HashYOffset;
            % Vertical lines
            hx_v = [repmat(hx, [2,1]); NaN(1, size(hx,2))];
            hy_v = repmat([hmin;hmax;NaN], [1, size(hx,2)]);
            plot(hx_v(:), hy_v(:), 'Color', options.distribution_color, 'LineWidth', options.distribution_line_width)
            % Horizontal lines
            hy_v = [repmat(hy, [2, 1]); NaN(1, size(hy,2))];
            hx_v = repmat([x - options.distribution_width; x + options.distribution_width; NaN], [1, size(hy_v,2)]);
            
            plot(hx_v(:), hy_v(:), 'Color', options.distribution_color, 'LineWidth', options.distribution_line_width, 'parent', options.parent)
        end
    end
    
    % Swarm
    if options.swarm_point_limit > 0
        % Make swarm distribution
        if strcmpi(options.distribution_method, 'Histogram')
            if options.num_stacks == 0
                [swarm_x_range, swarm_y_edges, ~] = histcounts(SwarmY, 'BinMethod', 'sturges');
            else
                [swarm_x_range, swarm_y_edges, ~] = histcounts(SwarmY, options.num_stacks);
            end
            swarm_x_range = (swarm_x_range ./ max(swarm_x_range)) * options.distribution_width * options.swarm_width_ratio;
            swarm_x_range(swarm_x_range == 0) = options.distribution_width / 25;
            swarm_x_range = (swarm_x_range ./ max(swarm_x_range)) * options.distribution_width * options.swarm_width_ratio;
            swarm_x_range = smoothdata(swarm_x_range, 'Gaussian', 3);
            swarm_x_range = swarm_x_range - min(swarm_x_range);
            
        elseif strcmpi(options.distribution_method, 'KernelDensity')
            % Low res for swarm
            [swarm_x_range, swarm_y_edges] = ksdensity(SwarmY, 'NumPoints', round(sqrt(length(SwarmY))));
            swarm_x_range = (swarm_x_range ./ max(swarm_x_range)) * options.distribution_width * options.swarm_width_ratio;
            % Convert eval points to bin edges
            swarm_y_edges = [swarm_y_edges - diff(swarm_y_edges(1:2))/2, swarm_y_edges(end) + diff(swarm_y_edges(1:2))/2];
        end
    
        if ~strcmpi(options.distribution_method, 'None') % Jitter x-values
            [bin_y, bin_x, bin_c] = deal(cell([length(swarm_x_range),1]));
            for b = 1:length(swarm_x_range)
                if b == 1
                    b_idx = SwarmY >= swarm_y_edges(b) & SwarmY <= swarm_y_edges(b+1);
                else
                    b_idx = SwarmY > swarm_y_edges(b) & SwarmY <= swarm_y_edges(b+1);
                end
                bin_y{b} = SwarmY(b_idx);
                bin_c{b} = options.swarm_marker_colors(b_idx,:);
                temp_x = linspace(-swarm_x_range(b), swarm_x_range(b), length(bin_y{b}))';
                bin_x{b} = temp_x(randperm(length(temp_x)));
            end
    
            SwarmX = vertcat(bin_x{:});
            SwarmY = vertcat(bin_y{:});
            options.swarm_marker_colors = vertcat(bin_c{:});
        end
        
        % Subsample
        if options.swarm_point_limit < length(SwarmY)
            rand_idx = randperm(length(SwarmY));
            SwarmX = SwarmX(rand_idx(1:options.swarm_point_limit));
            SwarmY = SwarmY(rand_idx(1:options.swarm_point_limit));
            options.swarm_marker_colors = options.swarm_marker_colors(rand_idx(1:options.swarm_point_limit),:);
        end
        
        % Plot swarm
        if strcmpi(options.violin_sides, 'Right')
            SwarmX = abs(SwarmX);
        elseif strcmpi(options.violin_sides, 'Left')
            SwarmX = -abs(SwarmX);
        end
        scatter(SwarmX + x, SwarmY, options.swarm_marker_size, options.swarm_marker_colors, options.swarm_marker_type, "filled",'MarkerEdgeColor','flat',...
            'MarkerFaceAlpha', options.swarm_face_alpha, 'MarkerEdgeAlpha', options.swarm_edge_alpha, 'parent', options.parent);
    
    end
    
    % Overlay central tendency (in some cases)
    if options.center_line_width > 0
        if strcmpi(options.distribution_style, 'Box')
            if options.swarm_point_limit == 0 && options.center_line_width == 2
                plot(x+[DistributionWidthArr(1), DistributionWidthArr(end)], [y_central, y_central], 'Color', options.center_color, ...
                    'LineWidth', options.distribution_line_width, 'parent', options.parent)
            else
                plot(x+[DistributionWidthArr(1), DistributionWidthArr(end)], [y_central, y_central], 'Color', options.center_color, ...
                    'LineWidth', options.center_line_width, 'parent', options.parent)
            end
        elseif any(strcmpi(options.distribution_style, {'Bar', 'None'})) && options.swarm_point_limit > 0
            plot(x+[options.distribution_width, -options.distribution_width], [y_central, y_central], 'Color', options.center_color, ...
                'LineWidth', options.center_line_width, 'parent', options.parent)
        elseif strcmpi(options.distribution_style, 'Violin')
            [~,med_idx] = min(abs(violin_y - y_central));
            if strcmpi(options.violin_sides, 'Both')
                plot(x+[violin_x(med_idx), -violin_x(med_idx)], [y_central, y_central], 'Color', options.center_color, ...
                    'LineWidth', options.center_line_width, 'parent', options.parent)
            elseif strcmpi(options.violin_sides, 'Right')
                plot(x+[0, violin_x(med_idx)], [y_central, y_central], 'Color', options.center_color, ...
                    'LineWidth', options.center_line_width, 'parent', options.parent)
            elseif strcmpi(options.violin_sides, 'Left')
                plot(x+[-violin_x(med_idx), 0], [y_central, y_central], 'Color', options.center_color, ...
                    'LineWidth', options.center_line_width, 'parent', options.parent)
            end
            
            if options.error_whiskers
                [~,err_idx] = min(abs(violin_y - y_error(2)));
                plot(x+[violin_x(err_idx), -violin_x(err_idx)], y_error([2,2]) , 'Color', options.center_color, ...
                    'LineWidth', options.distribution_line_width, 'parent', options.parent)
                [~,err_idx] = min(abs(violin_y - y_error(1)));
                plot(x+[violin_x(err_idx), -violin_x(err_idx)], y_error([1,1]) , 'Color', options.center_color, ...
                    'LineWidth', options.distribution_line_width, 'parent', options.parent)
            end
        elseif strcmpi(options.distribution_style, 'Stacks')
            med_idx = find(y_central < stack_yy, 1, 'first');
            plot(x+[stack_xx(med_idx), -stack_xx(med_idx)], [y_central, y_central], 'Color', options.center_color, ...
                'LineWidth', options.center_line_width, 'parent', options.parent)
            if options.error_whiskers
                % [~,err_idx] = min(abs(stack_y - y_error(2)));
                err_idx = find(y_error(2) < stack_yy, 1, 'first');
                plot(x+[stack_xx(err_idx), -stack_xx(err_idx)], y_error([2,2]) , 'Color', options.center_color, ...
                    'LineWidth', options.distribution_line_width, 'parent', options.parent)
                % [~,err_idx] = min(abs(stack_y - y_error(1)));
                err_idx = find(y_error(1) < stack_yy, 1, 'first');
                plot(x+[stack_xx(err_idx), -stack_xx(err_idx)], y_error([1,1]) , 'Color', options.center_color, ...
                    'LineWidth', options.distribution_line_width, 'parent', options.parent)
            end
        end
    end
end
