function raster_ticks = Rasterfy(x, options)
    arguments
        x
        options.y_margin {mustBeFloat} = 0.4;
        options.concat {mustBeNumericOrLogical} = true;
    end
    
    if isa(x, 'cell')
        if ~all(cellfun(@(c) isa(c, 'double'), x))
            error('x must be a double or cell of')
        end
    end
    if isa(x, 'double')
        x = {x};
    end
    num_trials = length(x);
    
    raster_ticks = cell([num_trials,2]);
    for t = 1:num_trials
        % Create placeholder
        ne = numel(x{t});
        [x_vec, y_vec] = deal(NaN(4,ne)); % NaNs allow for breaks between idents
        % Assign
        x_vec([2,3],:) = repmat(x{t}, [2, 1]);
        y_vec([2,3],:) = repmat([-options.y_margin; options.y_margin], [1, ne]);
        % Concatenate
        raster_ticks{t,1} = x_vec(:);
        raster_ticks{t,2} = y_vec(:) + t;
    end
    if options.concat
        raster_ticks = [cat(1, raster_ticks{:,1}), cat(1, raster_ticks{:,2})];
    end
end  