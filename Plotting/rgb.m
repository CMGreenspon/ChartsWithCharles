function rgb_norm = rgb(r,g,b)
    % Simple function that takes the output from https://materialui.co/colors/ 
    % and converts it to Matlab normalized RGB
    if nargin == 1 % Reverse order to prevent overwriting r
        b = r(3);
        g = r(2);
        r = r(1);
    end
    
    rgb_norm = [r,g,b] ./ 255;
end