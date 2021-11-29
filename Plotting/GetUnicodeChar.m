function uc = GetUnicodeChar(character)
% Get the unicode char value for a unicode character
% gc = GetUnicodeChar('character' [string])
% The 'character' requested is case sensitive. 'Gamma' ~= 'gamma'
% If 'all' is passed then a structure containing all character will be generated.

% See https://www.webstandards.org/learn/reference/charts/entities/symbol_entities/index.html for other characters
% Be aware that not all typefaces support unicode characters. I suggest OpenSans or RobotoMono (can be found on google fonts)

    names = {'Alpha', 'Beta', 'Gamma', 'Delta', 'Epsilon', 'Zeta', 'Eta', 'Theta', 'Iota', 'Kappa','Lambda',...
             'Mu', 'Nu', 'Xi', 'Omicron', 'Pi', 'Rho', 'Sigma', 'Tau', 'Upsilon', 'Phi', 'Chi', 'Psi', 'Omega',...
             'alpha', 'beta', 'pamma', 'delta', 'epsilon', 'zeta', 'eta', 'theta', 'iota', 'kappa','lambda',...
             'mu', 'nu', 'xi', 'omicron', 'pi', 'rho', 'sigma', 'tau', 'upsilon', 'phi', 'chi', 'psi', 'omega'};
    unicode_values = [913:929, 931:937, 945:961, 963:969];
    
    if strcmpi(character, 'all') % Generate struct with all characters
        uc = struct();
        for i = 1:length(names)
            eval(['gc.', names{i}, ' = char(', num2str(unicode_values(i)), ');'])
        end
        
    else % Find the specific letter and only give that one
        letter_idx = find(strcmp(names, character));
        if length(letter_idx) ~= 1
            error(sprintf('Could not find character: "%s"', character))
            return
        else
            uc = char(unicode_values(letter_idx));
        end
    
    end
end