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

set(gcf, 'Units', 'Normalized', 'Position', [.3 .4 .4 .2], 'Name', 'SetFont Example')

%% 2. GetUnicodeChar
% Many figures require Greek letters to be used as notation (eg. mu, sigma)
% This function allows for them to be easily made and in some cases will be supported by
% the typeface used
fprintf('The string "mu" produces %s, while "Mu" produces %s\n', GetUnicodeChar('mu'), GetUnicodeChar('Mu'))

%% 3. AlphaLine
% Quite simply the standard stalks for error bars are ugly, don't use them.
SetFont('Arial', 12)

x = [1:10];
y = repmat([1:10], [5,1]) + randn([5,10]);
y_mean = mean(y,1);
err = std(y,1,1) / sqrt(5);

clf; 
subplot(1,2,1); hold on
errorbar(x,y_mean,err)
title('Absolutely Not')
subplot(1,2,2); hold on
AlphaLine(x,y,lines(1))
title('So Much Better')

set(gcf, 'Units', 'Normalized', 'Position', [.3 .4 .3 .2], 'Name', 'SetFont Example')

