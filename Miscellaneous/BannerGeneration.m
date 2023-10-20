%% Triangle Pattern Generator
clf; hold on
set(gcf, 'Units', 'Pixels', 'Position', [2600, 100, 3000, 300])

num_rows = 5;
num_cols = 80;

base_color = rgb(106, 27, 154);
bc_hsv = rgb2hsv(base_color);
s_variance = 0.1;
v_variance = 0.005;

width = 50;
x0 = 0; y0 = 0;
for r = 1:num_rows
    for c = 1:num_cols
        % Pick 2 colors
        color1 = [bc_hsv(1) , bc_hsv(2) + randn * s_variance, bc_hsv(3) + randn * v_variance * c];
        color1(color1 < 0) = 0; color1(color1 > 1) = 1; 
        color2 = [bc_hsv(1) , bc_hsv(2) + randn * s_variance, bc_hsv(3) + randn * v_variance * c];
        color2(color2 < 0) = 0; color2(color2 > 1) = 1; 
        % Make patches
        patch([x0, x0 + width / 2 , x0 + width], [y0, y0 + width, y0], hsv2rgb(color1), 'EdgeColor', 'none')
        patch([x0 + width / 2 , x0 + width, x0 + width * 1.5], [y0 + width, y0, y0 + width], hsv2rgb(color2), 'EdgeColor', 'none')
    
        x0 = x0 + width;
    end
    y0 = y0 + width;
    x0 = rem(x0 + width/2, width);
end

set(gca, 'XColor', 'none',...
         'YColor', 'none',...
         'DataAspectRatio', [1,1,1],...
         'XLim', [width, width * (num_cols-1)],...
         'Position', [0 0 1 1],...
         'XDir', 'reverse', ...
         'Position', [0 0 1 1])
shg

%% Square Pattern Generator
clf; hold on
set(gcf, 'Units', 'Pixels', 'Position', [2600, 100, 3000, 300])

num_rows = 5;
num_cols = 80;
offset = false;

base_color = rgb(106, 27, 154);
bc_hsv = rgb2hsv(base_color);
s_variance = 0.1;
v_variance = 0.005;

width = 50;
x0 = 0; y0 = 0;
for r = 1:num_rows
    for c = 1:num_cols
        % Pick a color
        color1 = [bc_hsv(1) , bc_hsv(2) + randn * s_variance, bc_hsv(3) + randn * v_variance * c];
        color1(color1 < 0) = 0; color1(color1 > 1) = 1;
        % Make patches
        patch([x0, x0 , x0 + width, x0 + width], [y0, y0 + width, y0 + width, y0], hsv2rgb(color1), 'EdgeColor', 'none')    
        x0 = x0 + width;
    end
    y0 = y0 + width;
    if offset
        x0 = rem(x0 + width/2, width);
    else
        x0 = 0;
    end
end

set(gca, 'XColor', 'none',...
         'YColor', 'none',...
         'DataAspectRatio', [1,1,1],...
         'XLim', [width, width * (num_cols-1)],...
         'Position', [0 0 1 1],...
         'XDir', 'reverse', ...
         'Position', [0 0 1 1])
shg

%% ICMS Pattern Generator
clf; hold on
set(gcf, 'Units', 'Pixels', 'Position', [2600, 100, 3000, 300])

num_rows = 7;
num_cols = 50;

% Pulse config
amp_mean = 50;
amp_std = amp_mean / 2;
width_mean = 200;
width_std = width_mean * 2;

base_color = rgb(183, 28, 28);
[x, y] = deal(cell(num_rows * num_cols, 1));
x0 = 0; y0 = 0; ii = 1;
for r = 1:num_rows
    for c = 1:num_cols
        % Draw pulse parameters
        inter_width = width_mean / 2 + abs(randn() * width_std * 5);
        temp_amp = amp_mean + randn() *  amp_std;
        temp_width = width_mean + abs(randn() * width_std);
        % Make pulse shape
        x{ii} = [0,...
                 inter_width, ...
                 inter_width, ...
                 inter_width + temp_width, ...
                 inter_width + temp_width, ...
                 inter_width + temp_width + temp_width / 2, ...
                 inter_width + temp_width + temp_width / 2, ...
                 inter_width + temp_width + temp_width / 2 + temp_width * 2, ...
                 inter_width + temp_width + temp_width / 2 + temp_width * 2, ...
                 inter_width + temp_width + temp_width / 2 + temp_width * 2 + inter_width, ...
                 inter_width + temp_width + temp_width / 2 + temp_width * 2 + inter_width, NaN] + x0;
        y{ii} = [y0, ...
                 y0, ...
                 y0-temp_amp, ...
                 y0-temp_amp, ...
                 y0, ...
                 y0, ...
                 y0 + temp_amp / 2 , ...
                 y0 + temp_amp / 2, ...
                 y0, ...
                 y0, NaN, NaN];
        x0 = x0 + inter_width + temp_width + temp_width / 2 + temp_width * 2 + inter_width;
        ii = ii + 1;
    end
    y0 = y0 + amp_mean * 3;
    x0 = -inter_width * 2;
end
x = cat(2, x{:});
y = cat(2, y{:});
plot(x,y, 'Color', 'w', 'LineWidth', 1.5)
set(gca, 'XLim', [0 prctile(x, 90)], ...
         'YLim', [min(y), max(y)], ...
         'XColor', 'none', ...
         'YColor', 'none', ...
         'Color', base_color, ...
         'Position', [0 0 1 1])
shg
