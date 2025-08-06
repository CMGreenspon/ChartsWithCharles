function FormattedText = ColorText(input_text, colors, append)
    % FormattedText = ColorText(input_text, colors)
    % input text = cell(n,1) with chars in each cell
    % colors = double(n,3) in RGB format with range 0-1
    % Output: cell array with formatted text. Can then use text(x,y,FormattedText)
        
    if size(input_text,2) > size(input_text,1)
        input_text = input_text';
    end
    
    % Check input text
    if isnumeric(input_text)
        input_text = string(input_text);
    elseif ischar(input_text)
        input_text = convertCharsToStrings(input_text);
    end

    if exist('append', 'var')
        if ischar(append) == 0
            error('Input 3 must be a char.')
        end
        for i = 1:size(input_text,1)
            input_text{i} = [input_text{i}, ' ', append];
        end
    end
    
    % Check color input
    if exist('colors', 'var') == 0
        colors = [.6 .6 .6];
    elseif isnumeric(colors)
        elseif all(size(colors) ~= [1,3], 2)
            if all(size(colors) == [1,3],2)
                colors = colors';
            elseif any(size(colors) > 3)
                error('Only 3 values [RGB] may be given for the color.')
            end
    else
        error('Color must be numeric.')
    end
    if any(colors > 1)
        colors = colors ./ 255;
    end

    FormattedText = cell([size(input_text,1),1]);
    for i = 1:size(input_text,1)
        FormattedText(i) = {sprintf('\\color[rgb]{%0.3f %0.3f %0.3f}%s',  colors(i,:),input_text{i,1})};
    end

end
