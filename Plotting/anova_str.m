function str = anova_str(anova_tab, deblank)
    arguments
        anova_tab cell
        deblank {mustBeNumericOrLogical} = false;
    end
   
    num_vars = size(anova_tab,1) - 3;
    str = cell(num_vars, 1);
    for v = 1:num_vars
        str{v} = sprintf('%s: F_{[%d,%d]} = %.2f, %s', ...
            anova_tab{v+1,1}, ...                   % Name
            anova_tab{v+1,3}, anova_tab{end,3}, ... % Degrees of freedom
            anova_tab{v+1,6}, ...                   % F
            pStr(anova_tab{v+1,7}));                % p
        if deblank
            str{v} = strrep(str{v}, ' ', '');
        end
    end
    
    str = join(str, newline);
    str = str{1};
end