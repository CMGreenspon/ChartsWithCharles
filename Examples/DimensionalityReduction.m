%%% Dimensionality reduction examples
%% LDA
clear
load fisheriris

mdl = fitcdiscr(meas, species);
[W, LAMBDA] = eig(mdl.BetweenSigma, mdl.Sigma); % Decompose LDA coeffs

lambda_d = diag(LAMBDA); % Need diagonal weights for sorting
[lambda_d, SortOrder] = sort(lambda_d, 'descend'); % Order it
W = W(:, SortOrder); % Sort the weights with respect to diagonals
W_inv = inv(W); % Invert coefficients

nd = 4; % Tweak this to change how many dimensions are used for the reconstruction
meas_projected = meas * W(:,1:nd); % Project onto LDA axes
meas_reconstructed = meas_projected * W_inv(1:nd,:); % Reconstruct 

clf; 
nexttile; hold on; title('Original')
    gscatter(meas(:,1), meas(:,2), species, 'rgb', 'osd');
nexttile; hold on; title('LDA Projection')
    gscatter(meas_projected(:,1), meas_projected(:,2), species, 'rgb', 'osd');
nexttile; hold on; title(sprintf('Reconstructed, %d/%d Dims', nd, 4))
    gscatter(meas_reconstructed(:,1), meas_reconstructed(:,2), species, 'rgb', 'osd');

%% PCA
clear
load fisheriris

meas_mean = mean(meas,1); % Take the mean of each column/predictor
meas_offset = meas - meas_mean;
                
% Perform PCA on the mean subtracted array
[coeffs, scores] = pca(meas_offset); % Simple PCA
inverse_coeffs = inv(coeffs);  % Invert coefficients

nd = 2; % Tweak this to change how many dimensions are used for the reconstruction
meas_projected = meas_offset * coeffs(:,1:nd); % Project onto desired dimensions
meas_reconstructed = (meas_projected * inverse_coeffs(1:nd,:)) + meas_mean; % Reconstruct and add means back in

figure; 
nexttile; hold on; title('Original')
    gscatter(meas(:,1), meas(:,2), species, 'rgb', 'osd');
nexttile; hold on; title('PCA Projection')
    gscatter(meas_projected(:,1), meas_projected(:,2), species, 'rgb', 'osd');
nexttile; hold on; title(sprintf('Reconstructed, %d/%d Dims', nd, 4))
    gscatter(meas_reconstructed(:,1), meas_reconstructed(:,2), species, 'rgb', 'osd');

%% PCA2
clear
load fisheriris

meas_mean = mean(meas,1); % Take the mean of each column/predictor
meas_offset = meas - meas_mean;
                
% Perform PCA on the mean subtracted array
[coeffs, scores] = pca(meas_offset); % Simple PCA
% inverse_coeffs = inv(coeffs);  % Invert coefficients

nd = 2; % Tweak this to change how many dimensions are used for the reconstruction
meas_projected = meas_offset * coeffs(:,1:nd); % Project onto desired dimensions
meas_reconstructed = (meas_projected * coeffs(:,1:nd)') + meas_mean; % Reconstruct and add means back in

clf; 
nexttile; hold on; title('Original')
    gscatter(meas(:,1), meas(:,2), species, 'rgb', 'osd');
nexttile; hold on; title('PCA Projection')
    gscatter(meas_projected(:,1), meas_projected(:,2), species, 'rgb', 'osd');
nexttile; hold on; title(sprintf('Reconstructed, %d/%d Dims', nd, 4))
    gscatter(meas_reconstructed(:,1), meas_reconstructed(:,2), species, 'rgb', 'osd');

%% Factor analysis
clear
load carbig % Factor analysis needs more dimensions than fisheriris contains

% Need to filter out missing values from this dataset
X = [Acceleration Displacement Horsepower MPG Weight]; 
nan_idx = all(~isnan(X), 2);
X = X(nan_idx,:);
Origin = Origin(nan_idx, :);

X_mean = mean(X, 1); % Take the mean of each column/predictor
X_offset = X - X_mean;

nd = 2; % Carbig is too small to do more than 2 factors
[lambda, psi, T, stats, F] = factoran(X_offset, nd);
xp = (F * lambda') + X_mean; % Project the factor weights against the loading matrix and add means back in


clf; 
nexttile; hold on; title('Original')
    gscatter(X(:,1), X(:,2), cellstr(Origin), 'rgb', 'osd');

nexttile; hold on; title('Factor Loading')
    gscatter(F(:,1), F(:,2), cellstr(Origin), 'rgb', 'osd');

nexttile; hold on; title('Reconstruction')
    gscatter(xp(:,1), xp(:,2), cellstr(Origin), 'rgb', 'osd');
