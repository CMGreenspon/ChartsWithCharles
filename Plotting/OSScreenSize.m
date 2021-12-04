function position = OSScreenSize(FigureSize, Units, MonitorOffset)
    % Uses the screens pixel density to make figures of an exact size
    % position = OSScreenSize(FigureSize, MonitorOffset, Units)
    % set(gcf, 'Units', 'pixels', 'Position', OSScreenSize(fig_size));
    % Accepts FigureSize in either ('Inches'/'in'), or ('Centimeters'/'cm')
    % 
    
    if nargin == 1
        MonitorOffset = 0;
        Units = 'inches';
    elseif nargin == 2
        MonitorOffset = 0;
    end
    
    % Get pixels per unit
    monitor_info = get(0);
    screen_pixels = monitor_info.ScreenSize(3:4);
    if any(strcmpi(Units, {'Inches', 'in'}))
        ppu = monitor_info.ScreenPixelsPerInch;
    elseif any(strcmpi(Units, {'Centimeters', 'cm'}))
        ppu = monitor_info.ScreenPixelsPerInch / 2.54;
    end
    % Determine figure size in pixels
    FigureSize_pixels = FigureSize .* ppu;
    
    % Determine screen midpoint and which monitor to place figure on
    screen_midpoint = round(screen_pixels / 2); 
    if size(monitor_info.MonitorPositions,2) > 2 && MonitorOffset ~= 0
        screen_midpoint = screen_midpoint + ([screen_pixels(1), 0] * MonitorOffset); % Can move to seperate monitor
    end
    figure_offset = round(FigureSize_pixels / 2);

    position = [screen_midpoint - figure_offset, FigureSize_pixels];
end