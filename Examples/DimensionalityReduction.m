%%% Dimensionality reduction example
load fisheriris

%% LDA
clearvars -except meas species
mdl = fitcdiscr(meas, species);
[W, LAMBDA] = eig(mdl.BetweenSigma, mdl.Sigma); % Decompose LDA coeffs

lambda_d = diag(LAMBDA); % Must sort coefficients by diagonal weight
[lambda_d, SortOrder] = sort(lambda_d, 'descend'); % Order it
W = W(:, SortOrder); % Sort the weights with respect to weighting
W_inv = inv(W); % Invert coefficients

nd = 4; % Tweak this to change how many dimensions are used for the reconstruction
meas_projected = meas * W(:,1:nd); % Project onto LDA axes
meas_reconstructed = meas_projected * W_inv(1:nd,:); % Reconstruct 

clf; 
nexttile; hold on; title('Original')
    gscatter(meas(:,1), meas(:,2), species,'rgb','osd');
nexttile; hold on; title('LDA Projection')
    gscatter(meas_projected(:,1), meas_projected(:,2), species,'rgb','osd');
nexttile; hold on; title(sprintf('Reconstructed, %d/%d Dims', nd, 4))
    gscatter(meas_reconstructed(:,1), meas_reconstructed(:,2), species,'rgb','osd');

%% PCA
clearvars -except meas species

meas_mean = mean(meas,1); % Take the mean of each column/predictor
meas_offset = meas - meas_mean;
                
% Perform PCA on the mean subtracted array
[coeffs, scores] = pca(meas_offset);
inverse_coeffs = inv(coeffs);

nd = 4; % Tweak this to change how many dimensions are used for the reconstruction
meas_projected = meas_offset * coeffs(:,1:nd);
meas_reconstructed = (meas_projected * inverse_coeffs(1:nd,:)) + meas_mean; % Reconstruct and add means back in

clf; 
nexttile; hold on; title('Original')
    gscatter(meas(:,1), meas(:,2), species,'rgb','osd');
nexttile; hold on; title('PCA Projection')
    gscatter(meas_projected(:,1), meas_projected(:,2), species,'rgb','osd');
nexttile; hold on; title(sprintf('Reconstructed, %d/%d Dims', nd, 4))
    gscatter(meas_reconstructed(:,1), meas_reconstructed(:,2), species,'rgb','osd');