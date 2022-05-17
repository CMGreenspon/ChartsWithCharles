function raster_ticks = Rasterfy(spike_times, y_margin)
    if nargin < 2
        y_margin = 0.4;
    end
    num_trials = length(spike_times);
        
    for t = 1:num_trials
        [x_vec, y_vec] = deal(NaN(1,1));

        trial_spikes = spike_times{1,t};
        num_trial_spikes = length(trial_spikes);
        for s = 1:num_trial_spikes
            x_vec = [x_vec, trial_spikes(s), trial_spikes(s), NaN];
            y_vec = [y_vec, -y_margin, y_margin, NaN];
        end
        
        raster_ticks{t,1} = x_vec;
        raster_ticks{t,2} = y_vec;
    end
    
end  