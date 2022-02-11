function [msg] = InlineProgressBar(string, ordered_values, current_msg)
    p_complete_res = 25;
    % Function to streamline inline progress
    rs = repmat(sprintf('\b'), 1, length(current_msg));
    if strcmp(string, '#') % Treat as a loading bar
        p_complete = round((ordered_values(1) / ordered_values(2))*p_complete_res);
        msg = ['|', repmat('#', [1,p_complete]), repmat('_', [1,p_complete_res-p_complete]),...
               '| ', num2str(ordered_values(1)), '/', num2str(ordered_values(2))];
    else % Treat as a string
        msg = sprintf(string, ordered_values);
    end
    fprintf([rs, msg]);

    if strcmp(string, '#') && ordered_values(1) == ordered_values(2)
        fprintf('\n')
    end
end

