function pAdjusted = HolmBonferroni(p, alpha)
    if nargin < 2
        alpha = 0.05;
    end
    
    % Sort and iterate
    [p_sorted,sort_idx] = sort(p);
    current_multiplier = length(p);
    pAdjusted = ones([length(p), 1]);
    for i = 1:length(p)
        pAdjusted(i) = p_sorted(i) * current_multiplier;
        if pAdjusted(i) < alpha
            current_multiplier = current_multiplier - 1;
        end
        if pAdjusted(i) > 1
            pAdjusted(i) = 1;
            break
        end
    end
    
    pAdjusted = pAdjusted(sort_idx);
end