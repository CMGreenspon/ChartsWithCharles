%%% How to format a figure
SetFont('Arial', 9) % Set the font size of all chart elements for consistency
figure_size = [6.5, 4]; % How big will the figure be on the page (h * w inches). Full width is about 6.5, half is 3 

% For a powerpoint, use a font size >20 and just workout using a textbox what size you want it to be

clf;
set(gcf, 'Units', 'inches', 'Position', [1, 1, figure_size]) % Set the size of the figure
% Determine spacing of your figures for X (obviously don't need to declare variables but for the sake of an example...)
% I do this instead of using subplots because this allows way more control
num_columns = 4;
margin = 0.1;
border = 0.1;
[ax_x_size, ax_x_val] = GetAxisCoords(num_columns, margin, border);

% and for Y
num_rows = 2;
margin = 0.1;
border = 0.1;
[ax_y_size, ax_y_val] = GetAxisCoords(num_rows, margin, border, true); % 4th value flips so we start at the top of the figure

% Iterate through them automatically if the data structure allows
for c = 1:num_columns
    axes('Position', [ax_x_val(c), ax_y_val(1), ax_x_size, ax_y_size]);
    for i = 1:3
        Swarm(i, randn(20,1))
    end
end

% Or do it manually
axes('Position', [ax_x_val(1), ax_y_val(2), ax_x_size, ax_y_size]);
    plot([1,2.5,3], [4,5,6])

% Add some labels
x_offset = .05;
y_offset = -.015;
AddFigureLabels(gcf(), [x_offset, y_offset])

shg % Bring to front
export_figure3x(pwd(), 'FigureName') % Export as PNG, PDF, and SVG
