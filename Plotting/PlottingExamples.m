%%% Example scripts for plotting functions
%% 1. SetFont
% This function allows for globally setting all typefaces and fontsizes in one call.
% Note that the SetFont must be run at the beginning of the script (or in this case before
% the axes are created)
figure; 
SetFont('Arial', 9)
subplot(1,3,1); hold on
plot([1:10], [1:10], 'LineWidth', 2)
title('Arial is fine')

SetFont('Papyrus', 15)
subplot(1,3,2); hold on
plot([1:10], [1:10], 'LineWidth', 2)
title('Papyrus is not')

SetFont('Monospaced', 9)
subplot(1,3,3); hold on
plot([1:10], [1:10], 'LineWidth', 2)
title('Serifs are bad')

%set(gcf, 'Units', 'Normalized', 'Position', [.3 .4 .4 .2], 'Name', 'Plotting Example')
set(gcf, 'Units', 'pixels', 'Position', OSScreenSize([30, 10], 'cm', 1));

%% 2. GetUnicodeChar
% Many figures require Greek letters to be used as notation (eg. mu, sigma)
% This function allows for them to be easily made and in some cases will be supported by
% the typeface used
fprintf('The string "mu" produces %s, while "Mu" produces %s\n', GetUnicodeChar('mu'), GetUnicodeChar('Mu'))

%% 3. AlphaLine
% Quite simply the standard stalks for error bars are ugly, don't use them.
SetFont('Arial', 12)
clf; 

x = [1:10];
y = repmat([1:10], [100,1]) + randn([100,10])*2;
y_mean = mean(y,1);
err = std(y,1,1) / sqrt(5);

subplot(2,3,1);
errorbar(x,y_mean,err)
title('Absolutely Not')

subplot(2,3,2);
AlphaLine(x,y,lines(1))
title('So Much Better')

subplot(2,3,3);
AlphaLine(x,y,lines(1), 'ErrorType', 'Percentile', 'Percentiles', [5 95])
title('Easily control error bounds')
%%
% Handles NaNs too
y(:,[5,10]) = NaN;

subplot(2,3,4);
AlphaLine(x,y,lines(1), 'ErrorType', 'Percentile', 'Percentiles', [5 95])
title('Will warn if NaNs are present')

subplot(2,3,5);
AlphaLine(x,y,lines(1), 'ErrorType', 'Percentile', 'Percentiles', [5 95], 'IgnoreNaN', 1)
title('Can split lines with NaNs')

subplot(2,3,6);
AlphaLine(x,y,lines(1), 'ErrorType', 'Percentile', 'Percentiles', [5 95], 'IgnoreNaN', 2)
title('Can split lines with NaNs')

%% 4. SymphonicBeeSwarm
% A nicer method of showing value distribution of categories when not using a histogram or CDF
SetFont('Arial', 12)
clf; 
colors = lines(7);
x = 1;
y = randn([100,1]) + 5;

% The default look. Takes the x value, a vector of y values, the color, and the point size
SymphonicBeeSwarm(x, y, colors(1,:), 50)
% The function also allows for a variety of background plots
SymphonicBeeSwarm(2, y, colors(2,:), 50, 'BackgroundType', 'Bar', 'CenterColor', 'none')
SymphonicBeeSwarm(3, y, colors(3,:), 50, 'BackgroundType', 'Violin', 'CenterColor', [.6 .6 .6])
SymphonicBeeSwarm(4, y, colors(4,:), 50, 'BackgroundType', 'Box', 'CenterWidth', .1)
% and many many other options
SymphonicBeeSwarm(5, y, colors(5,:), 50, 'CenterMethod', 'median', 'CenterColor', [.6 .6 .6], 'CenterWidth', .1,...
    'DistributionMethod', 'histogram', 'BackgroundType', 'violin', 'BackgroundFaceAlpha', 0.1, 'BackgroundEdgeAlpha', 1,...
    'MarkerFaceAlpha', 1, 'MarkerEdgeAlpha', 1, 'BoxPercentiles', [1,40,60,99], 'MaxPoints', 0)
% Bar adds whiskers if maxpoints = 0
SymphonicBeeSwarm(6, y, colors(6,:), 50, 'BackgroundType', 'bar', 'BackgroundFaceAlpha', 0.1, 'BackgroundEdgeAlpha', 1,...
    'MarkerFaceAlpha', 1, 'MarkerEdgeAlpha', 1, 'BoxPercentiles', [1,40,60,99], 'MaxPoints', 0)
% Box only for completions sake
SymphonicBeeSwarm(7, y, colors(7,:), 50, 'BackgroundType', 'box', 'BackgroundFaceAlpha', 0.1, 'BackgroundEdgeAlpha', 1,...
    'MarkerFaceAlpha', 1, 'MarkerEdgeAlpha', 1, 'BoxPercentiles', [5,25,75,95], 'MaxPoints', 0)
xticks([1:7]);
xticklabels({'Default', '+Bar', '+Violin', '+Box', 'ViolinOnly', 'BarOnly', 'BoxOnly'})