function folded_hist = FoldedPSTH(spike_times, bin_edges, n_folds, gauss_width)
    % folded_hists = FoldedPSTH(spike_times, bin_edges, n_folds, gauss_width)
    % Function to take in spike times and make a PSTH with error-bars based on
    % sub-sampling (folding) the input trials
    % Input:
    % spike_times (cell array, [1,trial]) = spike times where each cell is a trial
    % bin edges (double, vector) = desired bin edges for PSTH
    % n_folds (integer) = number of folds to use (minimum of 3)
    % gauss_width (integer) = how many bins over which to smooth
    % Output:
    % folded_hist (double, [num_folds, num_bins]) = mean of each fold at each time point

    num_trials = length(spike_times);
    trials_per_fold = floor(num_trials/n_folds);
    fold_idx = randperm(trials_per_fold*n_folds);
    
    fold_idx = reshape(fold_idx, [n_folds, trials_per_fold]);
    folded_hist = zeros([n_folds, length(bin_edges)-1]);
    
    for f = 1:n_folds
        temp_spikes = horzcat(spike_times{1,fold_idx(f,:)});
        temp_hist = histcounts(temp_spikes, bin_edges) / range(bin_edges(1:2));
        temp_hist = smoothdata(temp_hist ./ trials_per_fold, 'gaussian', gauss_width);
        folded_hist(f,:) = temp_hist;
    end
end