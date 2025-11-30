function [MI, p, mi_perm] = MoransI(input_mat, method, options)
    arguments
        input_mat {mustBeMatrix}
        method {mustBeMember(method, ["rook", "queen", "distance"])} = 'rook';
        options.size {mustBeInteger} = 3;
        options.num_perms {mustBeInteger} = 1e3;
        % More dispersed, more clustered, either
        options.test_side {mustBeMember(options.test_side, ["left", "right", "both"])} = 'both';
    end
    
    % Evaluate matrix size convolution value
    if ~rem(options.size, 2) || options.size < 3
        error('Matrix size must be odd valued and greater than 1')
    end

    if strcmpi(method, 'distance') && ~options.size == 3
        error('Matrix sizes != 3 are only supported for distance matrices')
    end
    
    w_center = ceil(options.size/2);
    pad_size = floor(options.size / 2);
    
    % Construct weight matrix by distance
    switch method
        case 'rook'
            w = [0 1 0; ...
                 1 0 1; ...
                 0 1 0];
        case 'queen'
            w = [1 1 1; ...
                 1 0 1; ...
                 1 1 1];
        case 'distance'
            [x,y] = meshgrid(1:options.size);
            w = sqrt((x - w_center) .^ 2 + (y - w_center) .^ 2);
    end
    
    % Normalize weight matrix
    w = w ./ sum(w, 'all');
    
    % Pad the input array to allow for convolution and then subtract the mean
    input_mean = mean(input_mat, 'all', 'omitmissing');
    padded_mat = padarray(input_mat, [pad_size, pad_size], NaN, 'both') - input_mean;
    
    % Convolve input matrix with weight matrix
    MI = convolve_MI(padded_mat, w);

    % Recursive shuffle for p-value estimation
    if nargout > 1
        % Parse NaNs in input to maintain structure
        nan_mask = ~isnan(padded_mat);
        input_filt = input_mat(~isnan(input_mat));
        nif = numel(input_filt);

        % Perumte input matrix and get null MI
        mi_perm = zeros(options.num_perms, 1);
        for p = 1:options.num_perms
            % Create blank input matrix
            input_perm = NaN(size(padded_mat));
            % Assign shuffled values to non-NaN parts of matrix and subtract the mean
            input_perm(nan_mask) = input_filt(randperm(nif)) - input_mean;
            % Get shuffled MI
            mi_perm(p) = convolve_MI(input_perm, w);
        end

        % Test observed MI against permutations
        % As the default is both, we can compute both here to reduce duplication
        p_left = sum(MI < mi_perm) / options.num_perms;
        p_right = sum(MI > mi_perm) / options.num_perms;
        switch options.test_side
            case 'left'
                p = p_left;
            case 'right'
                p = p_right;
            case 'both'
                p = min([p_left, p_right]) * 2;
        end
    end

    function mi = convolve_MI(X, w)
        c = NaN(size(input_mat));
        for i = 1:size(X,1) - options.size + 1
            for j = 1:size(X,2) - options.size + 1
                % Get local matrix
                local_mat = X(i:i+options.size-1, j:j+options.size-1);
        
                % Get local w
                local_w = w;
                local_w(isnan(local_mat)) = NaN;
                local_w = local_w ./ sum(local_w, 'all', 'omitnan');
        
                % Local X weighted neighbor
                c(i,j) = local_mat(w_center, w_center) * sum(local_mat .* local_w, 'all', 'omitmissing');
            end
        end
       
        % Normalize dot product by sum of squares
        mi = sum(c, 'all', 'omitnan') / sum(X .^2, 'all', 'omitnan');
    end
end