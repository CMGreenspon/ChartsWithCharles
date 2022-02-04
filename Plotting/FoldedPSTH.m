function folded_hists = FoldedPSTH(spike_times, bin_edges, n_folds, gauss_width)
    num_trials = length(spike_times);
    trials_per_fold = floor(num_trials/n_folds);
    fold_idx = randperm(trials_per_fold*n_folds);
    
    fold_idx = reshape(fold_idx, [n_folds, trials_per_fold]);
    folded_hists = zeros([n_folds, length(bin_edges)-1]);
    
    for f = 1:n_folds
        temp_spikes = horzcat(spike_times{1,fold_idx(f,:)});
        temp_hist = histcounts(temp_spikes, bin_edges) / range(bin_edges(1:2));
        temp_hist = smoothdata(temp_hist ./ trials_per_fold, 'gaussian', gauss_width);
        folded_hists(f,:) = temp_hist;
    end
end