function xtl = sparse_xticklabels(xt)
    xtl = cell(size(xt));
    for i = 1:length(xtl)
        if i == 1
            xtl{i} = num2str(xt(1));
        elseif i == length(xtl)
            xtl{i} = num2str(xt(end));
        else
            xtl{i} = '';
        end
    end
end