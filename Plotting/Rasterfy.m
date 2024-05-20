function raster_ticks = Rasterfy(spike_times, y_margin, concat)
    if nargin < 3
        concat = false;
    end
    if nargin < 2
        y_margin = 0.4;
    end
    num_trials = length(spike_times);
    
    raster_ticks = cell([num_trials,2]);
    for t = 1:num_trials
        [x_vec, y_vec] = deal(NaN(1,1));

        trial_spikes = spike_times{t};
        num_trial_spikes = length(trial_spikes);
        for s = 1:num_trial_spikes
            x_vec = [x_vec, trial_spikes(s), trial_spikes(s), NaN]; %#ok<*AGROW> 
            y_vec = [y_vec, -y_margin, y_margin, NaN];
        end
        
        raster_ticks{t,1} = x_vec;
        raster_ticks{t,2} = y_vec + t;
    end
    if concat
        raster_ticks = [cat(2, raster_ticks{:,1})', cat(2, raster_ticks{:,2})'];
    end
end  