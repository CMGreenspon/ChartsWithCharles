% Permutation test function for two vectors
function [h,p] = PermutationTest(x1,x2,num_perms,alpha)
    % Assert that both x1 and x2 are column vectors
    if ~(size(x1,2) == 1 && size(x1,1) > 1)
        if (size(x1,1) == 1 && size(x1,2) > 1)
            x1 = x1';
        elseif all(size(x1) > 1)
            error('X1 must be a vector')
        end
    end

    if ~(size(x2,2) == 1 && size(x2,1) > 1)
        if (size(x2,1) == 1 && size(x2,2) > 1)
            x2 = x2';
        elseif all(size(x2) > 1)
            error('X2 must be a vector')
        end
    end
    
    if nargin < 3
        num_perms = min([min([length(x1), length(x2)])^2, 1000]);
    end
    if nargin < 4
        alpha = 0.05;
    end
    observed_delta = abs(mean(x1, 'omitnan') - mean(x2, 'omitnan'));
    
    % Permutations
    perm_delta = zeros(num_perms,1);
    x_cat = [x1;x2];
    if numel(x1) == numel(x2) % Can use whole vectors
        nx = numel(x_cat);
        for p = 1:num_perms
            perm_delta(p) = abs(diff(mean(reshape(x_cat(randperm(nx)), [], 2), 1, 'omitnan')));
        end
    else % Subsample appropriate number
        n1 = numel(x1);
        for p = 1:num_perms
            perm_sample = datasample(x_cat, numel(x_cat),'Replace', false);
            perm_delta(p) = abs(diff([mean(perm_sample(1:n1), 'omitnan'), mean(perm_sample(n1:1:end), 'omitnan')]));
        end
    end

    % Test alpha
    p = 1-(sum(perm_delta < observed_delta) / num_perms);
    if p < alpha
        h = 1;
    else
        h = 0;
    end

end