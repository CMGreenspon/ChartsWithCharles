function [x,y] = RoundedSquare(square, radius, num_points)
    arguments
        square{mustBeNumeric, mustBeScalarOrEmpty} = 0.5;
        radius{mustBeNumeric, mustBeScalarOrEmpty} = 0.15;
        num_points{mustBeInteger, mustBeScalarOrEmpty} = 100;
    end
    
    % Radius check
    if radius > square
        error('Rounding radius cannot be greater than the size of the square.')
    end

    % Offset s by r to maintain square size
    square = square - radius;
    
    % Make a circle (starting west-most point)
    q = linspace(-pi, pi, num_points*4);
    x = sin(q) * radius;
    y = cos(q) * radius;
    
    % Offset points in order
    corners = [-square, -square; -square, square; square, square; square, -square];
    idx = 1;
    for c = 1:4
        x(idx:idx+num_points-1) = x(idx:idx+num_points-1) + corners(c,1);
        y(idx:idx+num_points-1) = y(idx:idx+num_points-1) + corners(c,2);
        idx = idx + num_points;
    end
end