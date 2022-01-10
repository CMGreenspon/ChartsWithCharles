function rgb_norm = rgb(r,g,b)
    % Simple function that takes the output from https://materialui.co/colors/ 
    % and converts it to mMtlab normalized RGB
    rgb_norm = [r,g,b] ./ 255;
end