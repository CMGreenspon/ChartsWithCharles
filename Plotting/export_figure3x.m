function export_figure3x(export_path, fname, figure_handle, resolution)
    arguments
        export_path {mustBeText}
        fname {mustBeText}
        figure_handle = gcf()
        resolution {mustBeInteger} = 300
    end
    export_fname = fullfile(export_path, fname);
    print(figure_handle, export_fname, '-dpng', sprintf('-r%d', resolution))
    set(figure_handle, 'Renderer', 'painters')
    print(figure_handle, export_fname, '-dpdf')
    print(figure_handle, export_fname, '-dsvg')
end