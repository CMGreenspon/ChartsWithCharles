function gc = GetGreekChar(letter)
% Get the unicode char value for a Greek letter
% gc = GetGreekChar('letter' [string])
% The 'letter' requested is case sensitive. 'Gamma' ~= 'gamma'
% If 'all' is passed then a structure containing all letters will be generated.

% See https://www.webstandards.org/learn/reference/charts/entities/symbol_entities/index.html for other characters
% Be aware that not all typefaces support Greek letters. I suggest OpenSans or RobotoMono (can be found on google fonts)
    names = {'Alpha', 'Beta', 'Gamma', 'Delta', 'Epsilon', 'Zeta', 'Eta', 'Theta', 'Iota', 'Kappa','Lambda',...
             'Mu', 'Nu', 'Xi', 'Omicron', 'Pi', 'Rho', 'Sigma', 'Tau', 'Upsilon', 'Phi', 'Chi', 'Psi', 'Omega',...
             'alpha', 'beta', 'pamma', 'delta', 'epsilon', 'zeta', 'eta', 'theta', 'iota', 'kappa','lambda',...
             'mu', 'nu', 'xi', 'omicron', 'pi', 'rho', 'sigma', 'tau', 'upsilon', 'phi', 'chi', 'psi', 'omega'};
    unicode_values = [913:929, 931:937, 945:961, 963:969];
    
    if strcmpi(letter, 'all') % Generate struct with all letters
        gc = struct();
        for i = 1:length(names)
            eval_str = ['gc.', names{i}, ' = char(', num2str(unicode_values(i)), ');'];
            eval(eval_str)
        end
        
    else % Find the specific letter and only give that one
        letter_idx = find(strcmp(names, letter));
        if length(letter_idx) ~= 1
            error(sprintf('Could not find letter: "%s"', letter))
            return
        else
            gc = char(unicode_values(letter_idx));
        end
    
    end
end