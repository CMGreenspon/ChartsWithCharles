function pAdjusted = HolmBonferroni(p, alpha)
    if nargin < 2
        alpha = 0.05;
    end
    
    % Sort and iterate
    p_vec = p(:);
    [p_sorted, sort_idx] = sort(p_vec);
    [~, rsort_idx] = sort(sort_idx);
    current_multiplier = sum(~isnan(p_vec));
    pAdjusted = ones([length(p_vec), 1]);
    for i = 1:length(p_vec)
        pAdjusted(i) = p_sorted(i) * current_multiplier;
        if pAdjusted(i) < alpha
            current_multiplier = current_multiplier - 1;
        end
        if pAdjusted(i) > 1
            pAdjusted(i) = 1;
            break
        end
    end
    
    pAdjusted = pAdjusted(rsort_idx);
    pAdjusted(isnan(p_vec)) = NaN;
    pAdjusted = reshape(pAdjusted, size(p));
end