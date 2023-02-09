function SMD = StandardizedMeanDifference(x1,x2)
    % Assert that both x1 and x2 are column vectors
    if ~(any(size(x1) == 1) && any(size(x1) > 1))
        error('X1 must be a vector')
    end

    if ~(any(size(x2) == 1) && any(size(x2) > 1))
        error('X2 must be a vector')
    end

    SMD = (mean(x1, 'omitnan')-mean(x2, 'omitnan')) / mean([std(x1,'omitnan'),std(x2,'omitnan')]);
  end