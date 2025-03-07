function export_figure4x(export_path, fname)
    export_fname = fullfile(export_path, fname);
    print(gcf, export_fname, '-dpng', '-r300')
    set(gcf, 'Renderer', 'painters')
    print(gcf, export_fname, '-dsvg')
    print(gcf, export_fname, '-dpdf')
end