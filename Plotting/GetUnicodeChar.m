function uc = GetUnicodeChar(character)
    % Get the unicode char value for a unicode character
    % gc = GetUnicodeChar('character' [string])
    % gc = GetUnicodeChar('Mu')
    % The 'character' requested is case sensitive. 'Gamma' ~= 'gamma'
    % If 'all' is passed then a structure containing all character will be generated.

    % See https://unicode-table.com/en/ for other characters
    % Be aware that not all typefaces support unicode characters. I suggest OpenSans or JuliaMono

    names = {'Alpha', 'Beta', 'Gamma', 'Delta', 'Epsilon', 'Zeta', 'Eta', 'Theta', 'Iota', 'Kappa','Lambda',...
             'Mu', 'Nu', 'Xi', 'Omicron', 'Pi', 'Rho', 'Sigma', 'Tau', 'Upsilon', 'Phi', 'Chi', 'Psi', 'Omega',...
             'alpha', 'beta', 'pamma', 'delta', 'epsilon', 'zeta', 'eta', 'theta', 'iota', 'kappa','lambda',...
             'mu', 'nu', 'xi', 'omicron', 'pi', 'rho', 'sigma', 'tau', 'upsilon', 'phi', 'chi', 'psi', 'omega',...
             'degree', 'Degree', 'LeftArrow', 'UpArrow', 'RightArrow', 'DownArrow', 'HBar', 'EMDash3', 'PlusMinus',...
             'EmptyCircle', 'UpTriangle', 'Intersection', 'Union'};
    unicode_values = [913:929, 931:937, 945:961, 963:969, 176, 176, 8592:8595, 8213, 11835, 177, 11096, 9651, 8745, 8746];
    
    if strcmpi(character, 'all') % Generate struct with all characters
        uc = struct();
        for i = 1:length(names)
           uc.(names{i}) = char(unicode_values(i));
        end
        
    else % Find the specific letter and only give that one
        letter_idx = find(strcmp(names, character));
        if length(letter_idx) ~= 1
            error('Could not find character: "%s"', character)
        else
            uc = char(unicode_values(letter_idx));
        end
    
    end
end