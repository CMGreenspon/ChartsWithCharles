function color_array = ColorGradient(color1, color2, num_outputs)
    % function ColorGradient(color1, color2, num_outputs)
    % Takes any 2 colors and interpolates between them at the desired number of intervals
    % Color1 or color2 must be [1,3] in size but can be normalized (0-1) or standard (0-255)
    % If num_outputs is not given then assumed to be 255
    
    if nargin < 3
        num_outputs = 255;
    end
    
    color_array = [linspace(color1(1), color2(1), num_outputs)',...
                   linspace(color1(2), color2(2), num_outputs)',...
                   linspace(color1(3), color2(3), num_outputs)'];

end