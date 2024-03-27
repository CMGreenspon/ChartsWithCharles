function FormattedText = ColorText(input_text, colors)
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
    
    % Check color input
    if exist('colors', 'var') == 0
        colors = [.6 .6 .6];
    elseif all(size(colors) ~= [1,3], 2)
        if all(size(colors) == [1,3],2)
            colors = colors';
        elseif any(size(colors) > 3)
            error('Only 3 values [RGB] may be given for the color.')
        end
    end
    if any(colors > 1)
        colors = colors ./ 255;
    end

    FormattedText = cell([size(input_text,1),1]);
    for i = 1:size(input_text,1)
        FormattedText(i) = {['\color[rgb]{', num2str(colors(i,:)), '}',  input_text{i,1}]};
    end

end
