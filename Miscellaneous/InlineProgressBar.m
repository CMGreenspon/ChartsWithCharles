function [msg] = InlineProgressBar(input_str, ordered_values, current_msg)
    p_complete_res = 25;
    % Function to streamline inline progress
    rs = repmat(sprintf('\b'), 1, length(current_msg));
    if strcmp(input_str, '#') % Treat as a loading bar
        p_complete = round((ordered_values(1) / ordered_values(2))*p_complete_res);
        msg = ['|', repmat('#', [1,p_complete]), repmat('_', [1,p_complete_res-p_complete]),...
               '| ', num2str(ordered_values(1)), '/', num2str(ordered_values(2))];
    else % Treat as a string
        if isa(ordered_values, "double")
            msg = sprintf(input_str, ordered_values); % More flexible as can take infinite arguments
        elseif isa(ordered_values, "cell") % Construct an appropriate msg dynamically
            eval_str = 'msg = sprintf(input_str,';
            for i = 1:length(ordered_values)
                eval_str = [eval_str, sprintf('ordered_values{%d},',i)];
            end
            eval_str = [eval_str(1:end-1), ');'];
            eval(eval_str)
        end
    end
    fprintf([rs, msg]);

    if strcmp(input_str, '#') && ordered_values(1) == ordered_values(2)
        fprintf('\n')
    end
end

% Example 1
% msg = '';
% for i = 1:100
% [msg] = InlineProgressBar('#', [i,100], msg);
% pause(.1)
% end
% Will produce:
% "|#########################| 100/100"

% Example 2
% msg = '';
% for i = 1:100
%     [msg] = InlineProgressBar('Loading %d/%d', [i,100], msg);
%     pause(.1)
% end
% Will produce:
% "Loading i/100..."