%% make_SFIG4.m
%%% FEBRUARY 11, 2021

clear all

close all


%% Define the list of experiments
exp_list = {'SFIG7_abcde_-MET', 'FIG4_fghij_RefOsc_I', ...
    'SFIG8_abcde_RefOsc_II', 'SFIG8_fghij_RefOsc_III', ...
    'SFIG7_klmno_OpenLoop80', 'FIG4_pqrst_RefOscG', ...
    'FIG4_klmno_OpenLoopG'};


%% Set the total number of frames
dim_exp = 500;


%% Define the time interval for processing the data
tim_indx = 51:300; % Time frames to be considered


%% Set the PSD estimation parameters
fil_order = 12; %  Order of the autoregressive (AR) model
nfft = 1024; % Number of points in the discrete Fourier transform (DFT)
fs = 1/2; % Sampling frequency


%% Allocate matrices and vectors
matr_R = nan(dim_exp,numel(exp_list));
matr_Rad = nan(dim_exp,numel(exp_list));
matr_trMean = nan(dim_exp,numel(exp_list));
vct_trMean_psd = nan(3,numel(exp_list));


%% Define the labels associated to each experiment
VarLabels = {'-MET', 'Ref. osc. I','Ref. osc. II', ...
    'Ref. osc. III', 'Open loop (80 min)', 'Ref. osc. G', ...
    'Open loop (80 min) G'};

cat_VarNames = categorical(VarLabels);
cat_VarNames = reordercats(cat_VarNames,VarLabels);


%% Colormap
cMap = [0.4000    0.7608    0.6471;
        0.9882    0.5529    0.3843;
        0.9882    0.5529    0.3843;
        0.9882    0.5529    0.3843;
        0.5529    0.6275    0.7961;
        0.9882    0.5529    0.3843;
        0.5529    0.6275    0.7961];

    
%% Process the data to generate the SFIG4
for q = 1:numel(exp_list)
    
    exp_name = exp_list{q};
    
    %% Try to load the processed data
    try
        
        load(['./Processed_data/proc_data_' exp_name '.mat'], 'trMEAN', ...
            'trSTD', 'radMEAN', 'radSTD', 'R', 'Psi');
        
    catch % Otherwise, process the output data
        
        process_output_data(exp_name);
        
        load(['./Processed_data/proc_data_' exp_name '.mat'], 'trMEAN', ...
            'trSTD', 'radMEAN', 'radSTD', 'R', 'Psi');
        
    end
    
    
    %% Retrieve the processed output data
    matr_R(:,q) = R.';
    matr_trMean(:,q) = trMEAN;
    matr_Rad(:,q) = radMEAN;
    
    
    %% Compute the PSD
    data_trMean = matr_trMean(tim_indx,q);
    
    tmp_data = data_trMean - nanmean(data_trMean); % Zero mean signal
        
    [tmp_psd, tmp_f] = pmcov(tmp_data, fil_order, nfft, fs);
        
    tmp_psd = 10*log10(tmp_psd);
    
    
    %% Find the peak in the PSD
    [tmp_peak, tmp_indx_peak] = max(tmp_psd);
    
    min_freq = 1/((tim_indx(end)-tim_indx(1)+1).*2); % Min frequency
    
    
    %% Detect the not detectable peak in the PSD (i.e., tmp_peak<min_freq)
    if tmp_f(tmp_indx_peak) >= min_freq
        
        vct_trMean_psd(1,q) = tmp_f(tmp_indx_peak);
        vct_trMean_psd(2,q) = 1./tmp_f(tmp_indx_peak);
        vct_trMean_psd(3,q) = tmp_peak;
    
    else
        
        vct_trMean_psd(1,q) = 0;
        vct_trMean_psd(2,q) = +Inf;
        vct_trMean_psd(3,q) = 0;
    
    end
    
end

%% Compute mean and std of R
R_mean(1,:) = nanmean(matr_R(tim_indx,:));
R_std(1,:) = nanstd(matr_R(tim_indx,:), 1);

%% Compute mean and std of Radii
Rad_mean(1,:) = nanmean(matr_Rad(tim_indx,:));
Rad_std(1,:) = nanstd(matr_Rad(tim_indx,:), 1);


%% Print panel b
F_SFIG4b_ = figure('Position', [1 1 540 360], 'DefaultAxesFontSize', 16);
hold on;
tmp_b = bar(cat_VarNames, R_mean.');
tmp_b.FaceColor = 'Flat';
tmp_b.CData = cMap;
ylabel('R');
print(F_SFIG4b_, './Figures/SFIG4b', '-dpng')


%% Print panel d
F_SFIG4d_ = figure('Position', [1 1 540 360], ...
    'DefaultAxesFontSize', 16);
tmp_b = bar(cat_VarNames, vct_trMean_psd(3,:).');
tmp_b.FaceColor = 'Flat';
tmp_b.CData = cMap;
ylabel('Power (dB)');
print(F_SFIG4d_, './Figures/SFIG4d', '-dpng');


%% Print panel f
F_SFIG4f_ = figure('Position', [1 1 540 360], ...
    'DefaultAxesFontSize', 16);
tmp_b = bar(cat_VarNames, vct_trMean_psd(2,:).');
tmp_b.FaceColor = 'Flat';
tmp_b.CData = cMap;
ylim([0,160]);
ylabel('Period (min)');
print(F_SFIG4f_, './Figures/SFIG4f', '-dpng');


%% Print panel h
F_SFIG4h_ = figure('Position', [1 1 540 360], 'DefaultAxesFontSize', 16);
hold on;
tmp_b = bar(cat_VarNames, Rad_mean.');
tmp_b.FaceColor = 'Flat';
tmp_b.CData = cMap;
ylabel('Radius (px)');
print(F_SFIG4h_, './Figures/SFIG4h', '-dpng');