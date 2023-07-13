function Swarm(x, y, varargin)
% Updated SymphonicBeeSwarm
% Produces a distribution of points akin to a beeswarm, violin, or box and whisker
% Swarm(x, y, varargin)
% Only supports a single group at a time as this reduces ambiguity in matrix dimensions.

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
if length(y) > 4
    h = lillietest(y, 'alpha', .01);
    DistributionMethod = 'Histogram'; % {DM} Valid: None', KernelDensity (KD), Histogram (Hist)
else
    h = true;
    DistributionMethod = 'None';
end
if h 
    CenterMethod = 'Median'; % {CM}
    ErrorMethod = 'Percentile'; % {EM} 
else
    CenterMethod = 'Mean'; % {CM}
    ErrorMethod = 'STD'; % {EM} 
end

% Default arguments - shorthand keys shown in {}
Color = [.6 .6 .6]; % Master color - unset values will use this
% How to display the central tendency
CenterLineWidth = 2; % {CLW}
CenterColor = []; % {CC}
ErrorPercentiles = [5,25,75,95]; % {EP} If ErrorMethod is Percentile
ErrorWhiskers = true; % {EW}
% How to display the distribution
DistributionStyle = 'None'; % {DS} Valid: None, Box, Violin, Bar
DistributionWidth = .25; % {DW} half width of bar/box/violin etc
DistributionColor = []; % {DC}
DistributionFaceAlpha = .3; % {DFA} Transparency value of distribution
DistributionLineWidth = 1; % {DLW} 
DistributionLineAlpha = .75; % {DLA} 
DistributionWhiskerRatio = .3; % {DWR} 
% Swarm options
SwarmMarkerSize = 30; % {SMS} Scatter size
SwarmYLimits = []; % {SYL} Truncation of y-values in swarm
SwarmPointLimit = 100; % {SPL} Maximum number of points/marker to display
SwarmFaceAlpha = .5; % {SFA} 
SwarmEdgeAlpha = 1; % {SEA}
SwarmMarkerType = 'o'; % {SMT} pass through to mkr option in scatter
SwarmColor = []; % {SC}
SwarmWidthRatio = 0.75; % {SWR} Width relative to DistributionWidth
% Hashing - Box & bar only
HashStyle = 'None'; % {HS} Valid = '\' ('/') or '#'
HashAngle = 45; % {HA} Angle of the hash lines 
HashDensity = 0.1; % {HD} Scales to the central value
HashOffset = []; % {HO} Override HashDensity
% Other
Parent = [];
ShowStats = false;
GroupName = num2str(x); % For outpur of center +/- error

if ~isempty(varargin)
    % Let 3rd argument be color
    if all(size(varargin{1}) == [1,3]) && isnumeric(varargin{1})
        Color = varargin{1};
        if length(varargin) > 2
            varargin = varargin(2:end);
            ParseVarargin();
        end
    else
        ParseVarargin();
    end
end

if isempty(Parent)
    Parent = gca;
end
hold(Parent, 'on')

% Compute y_central
if strcmpi(CenterMethod, 'Mean')
    y_central = mean(y);
elseif strcmpi(CenterMethod, 'Median')
    y_central = median(y);
end
% Compute y_error
if strcmpi(ErrorMethod, 'Percentile')
    if length(ErrorPercentiles) == 2
        y_error = prctile(y, ErrorPercentiles);
        p = ErrorPercentiles;
    elseif length(ErrorPercentiles) == 4
        y_error = prctile(y, ErrorPercentiles([2,3]));
        p = ErrorPercentiles([2,3]);
    end
    stat_str = sprintf('Group "%s": Median (P(%d), P(%d)) = %0.2f (%0.2f, %0.2f)',...
        GroupName, p(1), p(2), y_central, y_error(1), y_error(2));
elseif strcmpi(ErrorMethod, 'STD')
    p = std(y);
    y_error = y_central + [p, -p];
    stat_str = sprintf('Group "%s": Mean %s %s = %0.2f %s %0.2f',...
        GroupName, GetUnicodeChar('PlusMinus'), ErrorMethod, y_central, GetUnicodeChar('PlusMinus'), p);
elseif strcmpi(ErrorMethod, 'SEM')
    p = std(y)/sqrt(length(y));
    y_error = y_central + [p, -p];
    stat_str = sprintf('Group "%s": Mean %s %s = %0.2f %s %0.2f',...
        GroupName, GetUnicodeChar('PlusMinus'), ErrorMethod, y_central, GetUnicodeChar('PlusMinus'), p);
end

if ShowStats
    disp(stat_str)
end

% Check color inputs
if isempty(CenterColor)
    CenterColor = Color;
end
if isempty(DistributionColor)
    DistributionColor = Color;
end
if isempty(SwarmColor)
    SwarmColor = repmat(Color, [length(y),1]);
elseif size(SwarmColor,1) == length(yidx)
    SwarmColor = SwarmColor(~yidx, :);
end

% Truncate y-values
SwarmY = y;
SwarmX = zeros(size(y));
if ~isempty(SwarmYLimits)
    SwarmY(SwarmY > max(SwarmYLimits)) = max(SwarmYLimits);
    SwarmY(SwarmY < min(SwarmYLimits)) = min(SwarmYLimits);
end

% Plot background
switch lower(DistributionStyle) % Because switch has no case-invariant mode
    case 'box'
        if length(ErrorPercentiles) ~= 4 || ~strcmpi(ErrorMethod, 'Percentile')
            error('When using "DistributionStyle: Box", you must pass 4 values to "ErrorPercentiles" and set "ErrorMethod: Percentile".')
        end
        % Box
        patch([x-DistributionWidth, x-DistributionWidth, x+DistributionWidth, x+DistributionWidth],...
              y_error([1,2,2,1]), DistributionColor, 'FaceAlpha', DistributionFaceAlpha, ...
              'EdgeAlpha', DistributionLineAlpha, 'EdgeColor', DistributionColor, 'LineWidth', ...
              DistributionLineWidth, 'Parent', Parent)
        % Whiskers
        if ErrorWhiskers
            plot([x,x], [y_error(2), prctile(y, ErrorPercentiles(4))],...
                'Color' , [DistributionColor, DistributionLineAlpha], 'LineWidth', DistributionLineWidth, 'Parent', Parent)
            plot([x-DistributionWidth*DistributionWhiskerRatio,x+DistributionWidth*DistributionWhiskerRatio],...
                prctile(y, ErrorPercentiles([4,4])), 'Color' , [DistributionColor, DistributionLineAlpha], 'LineWidth', DistributionLineWidth, 'Parent', Parent)
            plot([x,x], [y_error(1), prctile(y, ErrorPercentiles(1))],...
                'Color' , [DistributionColor, DistributionLineAlpha], 'LineWidth', DistributionLineWidth, 'Parent', Parent)
            plot([x-DistributionWidth*DistributionWhiskerRatio,x+DistributionWidth*DistributionWhiskerRatio],...
                prctile(y, ErrorPercentiles([1,1])), 'Color' , [DistributionColor, DistributionLineAlpha], 'LineWidth', DistributionLineWidth, 'Parent', Parent)
        end

    case 'bar'
        % Bar
        patch([x-DistributionWidth, x-DistributionWidth, x+DistributionWidth, x+DistributionWidth], ...
              [0, y_central, y_central, 0],...
              DistributionColor, 'FaceAlpha', DistributionFaceAlpha, ...
              'EdgeAlpha', 0, 'EdgeColor', DistributionColor, 'LineWidth', ...
              DistributionLineWidth, 'Parent', Parent)
        plot([x-DistributionWidth, x-DistributionWidth, x+DistributionWidth, x+DistributionWidth], ...
             [0, y_central, y_central, 0], 'Color' , [DistributionColor, DistributionLineAlpha], 'LineWidth', ...
              DistributionLineWidth, 'Parent', Parent)
        % Whiskers
        if ErrorWhiskers
            plot([x,x], [y_central,y_error(2)], 'Color' , [DistributionColor, DistributionLineAlpha], 'LineWidth', DistributionLineWidth, 'Parent', Parent)
            plot([x-DistributionWidth*DistributionWhiskerRatio,x+DistributionWidth*DistributionWhiskerRatio],...
                y_error([2,2]), 'Color' , [DistributionColor, DistributionLineAlpha], 'LineWidth', DistributionLineWidth, 'Parent', Parent)
            plot([x,x], [y_central,y_error(1)], 'Color' , [DistributionColor, DistributionLineAlpha], 'LineWidth', DistributionLineWidth, 'Parent', Parent)
            plot([x-DistributionWidth*DistributionWhiskerRatio,x+DistributionWidth*DistributionWhiskerRatio],...
                y_error([1,1]), 'Color' , [DistributionColor, DistributionLineAlpha], 'LineWidth', DistributionLineWidth, 'Parent', Parent)
        end

    case 'violin'
        [violin_x, violin_y] = ksdensity(SwarmY, 'NumPoints', 100);
        violin_x = violin_x(ErrorPercentiles(1):ErrorPercentiles(end));
        violin_x = rescale(violin_x, 0, DistributionWidth);
        violin_y = violin_y(ErrorPercentiles(1):ErrorPercentiles(end));
        % Get a nicer KS distribution with more points
        fill([violin_x, fliplr(-violin_x)] + x, [violin_y, fliplr(violin_y)],...
             DistributionColor, 'EdgeColor', DistributionColor, 'FaceAlpha', DistributionFaceAlpha,...
             'EdgeAlpha', DistributionLineAlpha, 'LineWidth', DistributionLineWidth, 'Parent', Parent)
end

% Hash overlay
if ~strcmpi(HashStyle, 'None') && any(strcmpi(DistributionStyle, {'Box', 'Bar'}))
    % Determine hash range
    if strcmpi(DistributionStyle, 'Box')
        hmin = y_error(1);
        hmax = y_error(2);
    elseif strcmpi(DistributionStyle, 'Bar')
        hmin = min([0, y_central]);
        hmax = max([0, y_central]);
    end
    if any(strcmp(HashStyle, {'/', '\', '\/', '/\'}))
        if strcmp(HashStyle, '/\') || strcmp(HashStyle, '\/')
            HashAngle = [HashAngle, HashAngle-90];
        end
        for HA = HashAngle
            % Simplify hash angle
            FlipHash = false;
            if HA < 0
                FlipHash = true;
                HA = abs(HA); %#ok<FXSET> 
            end
            % Determine number of hashes based on HashDensity and range
            hash_height = tan(deg2rad(HA)) * DistributionWidth / 2;
            hash_slope = hash_height / (DistributionWidth * 2);
            if isempty(HashOffset)
                HashOffset = range([hmin, hmax]) * HashDensity;
            end
            num_hashes = floor(range([hmin-hash_height, hmax]) / HashOffset); % Just a guess
            [hash_x, hash_y] = deal(cell(num_hashes,1));
            % Start at the bottom and assert that all hashes are in bounds
            yrt = HashOffset + hmin; % Target Yr
            for h = 1:num_hashes
                % Compute XR for YR
                if yrt > hmax
                    xr = (x + DistributionWidth) - (yrt - hmax) / hash_slope;
                    yr = hmax;
                else
                    yr = yrt;
                    xr = x + DistributionWidth;
                end

                % Compute YL wrt YRT
                yl = yrt - hash_slope * DistributionWidth * 2;
                if yl < hmin
                    yl = hmin;
                    xl = xr - (yr - yl) / hash_slope;
                elseif yl > hmax
                    break
                else
                    xl = x - DistributionWidth;
                end
                % Assign
                hash_x{h} = [xl,xr,NaN];
                hash_y{h} = [yl,yr,NaN];

                % Update
                yrt = yrt + HashOffset;
            end
            hash_x = cat(2, hash_x{:});
            hash_y = cat(2, hash_y{:});
            if FlipHash
                 hash_x = ((hash_x - x) .* -1) + x;
            end
            plot(hash_x, hash_y, 'Color', DistributionColor, 'LineWidth', DistributionLineWidth)
        end

    elseif strcmp(HashStyle, '#')
        if isempty(HashOffset)
            HashXOffset = DistributionWidth * 2 * HashDensity;
            HashYOffset = range([hmin, hmax]) * HashDensity;
        elseif length(HashOffset) == 1
            [HashXOffset, HashYOffset] = deal(HashOffset);
        elseif length(HashOffset) == 2
            HashXOffset = HashOffset(1);
            HashYOffset = HashOffset(2);
        end
        % Indices
        hx = x - DistributionWidth + HashXOffset : HashXOffset : x + DistributionWidth - HashXOffset;
        hy = hmin + HashYOffset : HashYOffset : hmax - HashYOffset;
        % Vertical lines
        hx_v = [repmat(hx, [2,1]); NaN(1, size(hx,2))];
        hy_v = repmat([hmin;hmax;NaN], [1, size(hx,2)]);
        plot(hx_v(:), hy_v(:), 'Color', DistributionColor, 'LineWidth', DistributionLineWidth)
        % Horizontal lines
        hy_v = [repmat(hy, [2, 1]); NaN(1, size(hy,2))];
        hx_v = repmat([x - DistributionWidth; x + DistributionWidth; NaN], [1, size(hy_v,2)]);
        
        plot(hx_v(:), hy_v(:), 'Color', DistributionColor, 'LineWidth', DistributionLineWidth)
    end
end

% Swarm
if SwarmPointLimit > 0
    % Make swarm distribution
    if contains(DistributionMethod, 'Hist')
        [swarm_x_range, swarm_y_edges, ~] = histcounts(SwarmY, 'BinMethod', 'sturges');
    %     bin_centers = swarm_y_edges(1:end-1) + (range(swarm_y_edges(1:2))/2); 
        swarm_x_range = (swarm_x_range ./ max(swarm_x_range)) * DistributionWidth * SwarmWidthRatio;
        swarm_x_range = smoothdata(swarm_x_range, 'Gaussian', 3);
        
    elseif strcmpi(DistributionMethod, 'KernelDensity') || strcmpi(DistributionMethod, 'KD')
        % Low res for swarm
        [swarm_x_range, swarm_y_edges] = ksdensity(SwarmY, 'NumPoints', round(sqrt(length(SwarmY))));
        swarm_x_range = (swarm_x_range ./ max(swarm_x_range)) * DistributionWidth * SwarmWidthRatio;
        % Convert eval points to bin edges
        swarm_y_edges = [swarm_y_edges - diff(swarm_y_edges(1:2))/2, swarm_y_edges(end) + diff(swarm_y_edges(1:2))/2];
    end

    if ~strcmpi(DistributionMethod, 'None') % Jitter x-values
        [bin_y, bin_x, bin_c] = deal(cell([length(swarm_x_range),1]));
        for b = 1:length(swarm_x_range)
            if b == 1
                b_idx = SwarmY >= swarm_y_edges(b) & SwarmY <= swarm_y_edges(b+1);
            else
                b_idx = SwarmY > swarm_y_edges(b) & SwarmY <= swarm_y_edges(b+1);
            end
            bin_y{b} = SwarmY(b_idx);
            bin_c{b} = SwarmColor(b_idx,:);
            temp_x = linspace(-swarm_x_range(b), swarm_x_range(b), length(bin_y{b}))';
            bin_x{b} = temp_x(randperm(length(temp_x)));
        end

        SwarmX = vertcat(bin_x{:});
        SwarmY = vertcat(bin_y{:});
        SwarmColor = vertcat(bin_c{:});
    end
    
    % Subsample
    if SwarmPointLimit < length(SwarmY)
        rand_idx = randperm(length(SwarmY));
        SwarmX = SwarmX(rand_idx(1:SwarmPointLimit));
        SwarmY = SwarmY(rand_idx(1:SwarmPointLimit));
        SwarmColor = SwarmColor(rand_idx(1:SwarmPointLimit),:);
    end
    
    % Plot swarm
    scatter(SwarmX + x, SwarmY, SwarmMarkerSize, SwarmColor, SwarmMarkerType, "filled",'MarkerEdgeColor','flat',...
        'MarkerFaceAlpha', SwarmFaceAlpha, 'MarkerEdgeAlpha', SwarmEdgeAlpha, 'Parent', Parent);

end

% Overlay central tendency (in some cases)
if strcmpi(DistributionStyle, 'Box')
    if SwarmPointLimit == 0 && CenterLineWidth == 2
        plot(x+[DistributionWidth, -DistributionWidth], [y_central, y_central], 'Color', CenterColor, 'LineWidth', DistributionLineWidth)
    else
        plot(x+[DistributionWidth, -DistributionWidth], [y_central, y_central], 'Color', CenterColor, 'LineWidth', CenterLineWidth)
    end
elseif any(strcmpi(DistributionStyle, {'Bar', 'None'})) && SwarmPointLimit > 0
    plot(x+[DistributionWidth, -DistributionWidth], [y_central, y_central], 'Color', CenterColor, 'LineWidth', CenterLineWidth)
elseif strcmpi(DistributionStyle, 'Violin')
    [~,med_idx] = min(abs(violin_y - y_central));
    plot(x+[violin_x(med_idx), -violin_x(med_idx)], [y_central, y_central], 'Color', CenterColor, 'LineWidth', CenterLineWidth)
    if ErrorWhiskers
        [~,err_idx] = min(abs(violin_y - y_error(2)));
        plot(x+[violin_x(err_idx), -violin_x(err_idx)], y_error([2,2]) , 'Color', CenterColor, 'LineWidth', DistributionLineWidth)
        [~,err_idx] = min(abs(violin_y - y_error(1)));
        plot(x+[violin_x(err_idx), -violin_x(err_idx)], y_error([1,1]) , 'Color', CenterColor, 'LineWidth', DistributionLineWidth)
    end
end

function ParseVarargin()
    if ~isempty(varargin)
        nargin = ceil(length(varargin)/2);
        varargin = reshape(varargin, [2, nargin]);
        for n = 1:nargin
            if strcmpi(varargin{1,n},'Color')
                if all(size(varargin{2,n}) == [1,3]) && isnumeric(varargin{2,n})
                    Color = varargin{2,n};
                elseif ischar(varargin{2,n}) || isstring(varargin{2,n})
                    try 
                        Color = validatecolor(varargin{2,n});
                    catch
                        error('Color %s could not be validated', varargin{2,n})
                    end
                else
                    error('"Color" must be a numeric vector of size [1,3], or a char/string.')
                end

            elseif strcmpi(varargin{1,n}, 'GroupName') || strcmpi(varargin{1,n}, 'GN')
                if ischar(varargin{2,n}) || isstring(varargin{2,n})
                    GroupName = varargin{2,n};
                else
                    error('"GroupName" must be a char.')
                end

            elseif strcmpi(varargin{1,n}, 'CenterMethod') || strcmpi(varargin{1,n}, 'CM')
                if ischar(varargin{2,n}) || any(strcmpi(varargin{2,n}, {'Mean', 'Median'}))
                    CenterMethod = varargin{2,n};
                else
                    error('"CenterMethod" must be "Mean"/"Median".')
                end

                if ~any(strcmp('ErrorMethod', varargin(1,:))) && ~any(strcmp('EM', varargin(1,:)))
                    if strcmp(CenterMethod, 'Mean')
                        ErrorMethod = 'STD';
                    elseif strcmp(CenterMethod, 'Median')
                        ErrorMethod = 'Percentile';
                    end
                end

            elseif strcmpi(varargin{1,n}, 'CenterLineWidth') || strcmpi(varargin{1,n}, 'CLW')
                CenterLineWidth = varargin{2,n};

            elseif strcmpi(varargin{1,n}, 'CenterColor') || strcmpi(varargin{1,n}, 'CC')
                if all(size(varargin{2,n}) == [1,3]) && isnumeric(varargin{2,n})
                    CenterColor = varargin{2,n};
                else
                    error('"CenterColor" must be a numeric vector of size [1,3].')
                end

            elseif strcmpi(varargin{1,n}, 'ErrorPercentiles') || strcmpi(varargin{1,n}, 'EP')
                if isnumeric(varargin{2,n}) && (length(varargin{2,n}) == 2 || length(varargin{2,n}) == 4)
                    ErrorPercentiles = varargin{2,n};
                else
                    error('"ErrorPercentiles" must be a numeric vector of length 2 or 4.')
                end
                

            elseif strcmpi(varargin{1,n}, 'ErrorMethod') || strcmpi(varargin{1,n}, 'EM')
                if (ischar(varargin{2,n}) || isstring(varargin{2,n})) &&...
                        any(strcmpi(varargin{2,n}, {'STD', 'SEM', 'Percentile'}))
                    ErrorMethod = varargin{2,n};
                else
                    error('"DistribtutionStyle" must be "STD"/"SEM"/"Percentile".')
                end

                if ~any(strcmp('CenterMethod', varargin(1,:))) && ~any(strcmp('CM', varargin(1,:)))
                    if strcmp(ErrorMethod, 'Percentile')
                        CenterMethod = 'Median';
                    end
                end

            elseif strcmpi(varargin{1,n}, 'ErrorWhiskers') || strcmpi(varargin{1,n}, 'EW')
                ErrorWhiskers = varargin{2,n};

            elseif strcmpi(varargin{1,n}, 'DistributionStyle') || strcmpi(varargin{1,n}, 'DS')
                if (ischar(varargin{2,n}) || isstring(varargin{2,n})) &&...
                        any(strcmpi(varargin{2,n}, {'None', 'Box', 'Bar', 'Violin'}))
                    DistributionStyle = varargin{2,n};
                else
                    error('"DistribtutionStyle" must be "None"/"Box"/"Bar"/"Violin".')
                end
                % Also set some defaults
                if any(strcmpi(varargin{2,n}, {'Box', 'Violin'})) &&...
                        ~any(strcmp('CenterMethod', varargin(1,:))) && ~any(strcmp('CM', varargin(1,:)))
                    CenterMethod = 'Median';
                end

                if any(strcmpi(varargin{2,n}, {'Box', 'Violin'})) && ...
                        ~any(strcmp('ErrorMethod', varargin(1,:))) && ~any(strcmp('EM', varargin(1,:)))
                    ErrorMethod = 'Percentile';
                end

                if strcmpi(DistributionStyle, 'Violin') && ~any(strcmp('ErrorWhisker', varargin(1,:)))
                    ErrorWhiskers = false;
                end

            elseif strcmpi(varargin{1,n}, 'DistributionMethod') || strcmpi(varargin{1,n}, 'DM')
                if (ischar(varargin{2,n}) || isstring(varargin{2,n})) &&...
                        any(strcmpi(varargin{2,n}, {'None', 'KernelDensity', 'Histogram', 'Hist'}))
                    DistributionMethod = varargin{2,n};
                else
                    error('"DistributionMethod" must be "None"/"KernelDensity"/"Histogram".')
                end

            elseif strcmpi(varargin{1,n}, 'DistributionWidth') || strcmpi(varargin{1,n}, 'DW')
                DistributionWidth = varargin{2,n};

            elseif strcmpi(varargin{1,n}, 'DistributionColor') || strcmpi(varargin{1,n}, 'DC')
                if all(size(varargin{2,n}) == [1,3]) && isnumeric(varargin{2,n})
                    DistributionColor = varargin{2,n};
                else
                    error('"CenterColor" must be a numeric vector of size [1,3].')
                end

            elseif strcmpi(varargin{1,n}, 'DistributionFaceAlpha') || strcmpi(varargin{1,n}, 'DFA')
                DistributionFaceAlpha = varargin{2,n};

            elseif strcmpi(varargin{1,n}, 'DistributionLineWidth') || strcmpi(varargin{1,n}, 'DLW')
                DistributionLineWidth = varargin{2,n};

            elseif strcmpi(varargin{1,n}, 'DistributionLineAlpha') || strcmpi(varargin{1,n}, 'DLA')
                DistributionLineAlpha = varargin{2,n};

            elseif strcmpi(varargin{1,n}, 'DistributionWhiskerRatio') || strcmpi(varargin{1,n}, 'DWR')
                DistributionWhiskerRatio = varargin{2,n};

            elseif strcmpi(varargin{1,n}, 'SwarmMarkerSize') || strcmpi(varargin{1,n}, 'SMS')
                SwarmMarkerSize = varargin{2,n};

            elseif strcmpi(varargin{1,n}, 'SwarmYLimits') || strcmpi(varargin{1,n}, 'SYL')
                SwarmYLimits = varargin{2,n};

            elseif strcmpi(varargin{1,n}, 'SwarmPointLimit') || strcmpi(varargin{1,n}, 'SPL')
                SwarmPointLimit = varargin{2,n};

            elseif strcmpi(varargin{1,n}, 'SwarmFaceAlpha') || strcmpi(varargin{1,n}, 'SFA')
                SwarmFaceAlpha = varargin{2,n};

            elseif strcmpi(varargin{1,n}, 'SwarmEdgeAlpha') || strcmpi(varargin{1,n}, 'SEA')
                SwarmEdgeAlpha = varargin{2,n};

            elseif strcmpi(varargin{1,n}, 'SwarmMarkerType') || strcmpi(varargin{1,n}, 'SMT')
                SwarmMarkerType = varargin{2,n};

            elseif strcmpi(varargin{1,n}, 'SwarmColor') || strcmpi(varargin{1,n}, 'SC')
                if size(varargin{2,n},2) == 3 && isnumeric(varargin{2,n})
                    SwarmColor = varargin{2,n};
                else
                    error('"SwarmColor" must be a numeric matrix of size [n,3].')
                end

            elseif strcmpi(varargin{1,n}, 'SwarmWidthRatio') || strcmpi(varargin{1,n}, 'SWR')
                SwarmWidthRatio = varargin{2,n};

            elseif strcmpi(varargin{1,n}, 'HashStyle') || strcmpi(varargin{1,n}, 'HS')
                if (ischar(varargin{2,n}) || isstring(varargin{2,n})) &&...
                        any(strcmpi(varargin{2,n}, {'None', '/', '\', '/\', '\/', '#'}))
                    HashStyle = varargin{2,n};
                else
                    error('"HashStyle" must be "/" or "\" or "\/" or "#".')
                end

            elseif strcmpi(varargin{1,n}, 'HashAngle') || strcmpi(varargin{1,n}, 'HA')
                if abs(varargin{2,n}) < 85 && abs(varargin{2,n}) > 5
                    HashAngle = varargin{2,n};
                else 
                    error('|HashAngle| must be in range 5 < HashAngle < 85')
                end

            elseif strcmpi(varargin{1,n}, 'HashDensity') || strcmpi(varargin{1,n}, 'HD')
                HashDensity = varargin{2,n};

            elseif strcmpi(varargin{1,n}, 'HashOffset') || strcmpi(varargin{1,n}, 'HO')
                HashOffset = varargin{2,n};

            elseif strcmpi(varargin{1,n}, 'Parent')
                if isa(varargin{2,n}, 'matlab.graphics.axis.Axes')
                    Parent = varargin{2,n};
                else
                    error("Parent must be an axis handle")
                end

            elseif strcmpi(varargin{1,n}, 'ShowStats')
                ShowStats = varargin{2,n};

            else
                error('%s is an unrecognized input.', varargin{1,n})
            end
        end
    end
end
end


























