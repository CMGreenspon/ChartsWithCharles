function [wb, pfwb_update] = ParforWaitbar(string, max_val)
    % [wb, pfwb_update] = ParforWaitbar(string, max_val)
    % Function to create waitbar handle and parallel queue handle for
    % seeing parfor loop progress
    % The 'string' is the text for the waitbar to display.
    % The 'max_val' should be the number of times you expect the waitbar to
    % update. This is dependent upon the number of parfor loops and the
    % place within the loop the update command is called. 
    % Example:
    % [wb, pfwb_update]  = ParforWaitbar('Test', 100);
    % parfor i = 1:100
    %     pause(0.1)
    %     send(pfwb_update, 0);
    % end

    wb = waitbar(0, string);
    wb.UserData = [0 max_val];

    pfwb_update = parallel.pool.DataQueue;
    afterEach(pfwb_update, @(varargin) ParforWaitbar_increment(wb));
end
