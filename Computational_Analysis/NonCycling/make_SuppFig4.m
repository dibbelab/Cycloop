%% make_SuppFig4.m
%%% FEBRUARY 11, 2021

clear all

close all

addpath('./Code_supporting_main/'); % Add this subfolder to the path variable


%% List of microfluidics experiments of the non-cycling strain
exp_list = {'Fig2_abcde_-MET','Fig3_fghij_Stop&goI', ...
    'SupplFig6_abcde_Stop&goII', 'SupplFig6_fghij_Stop&goIII', ...
    'Fig2_fghij_Openloop60', 'Fig2_klmno_Openloop75', ...
    'Fig2_pqrst_Openloop150', 'SupplFig5_fghij_Stop&goT', ...
    'SupplFig5_abcde_Openloop75T', 'Fig3_pqrst_Stop&goG', ...
    'Fig3_klmno_Openloop75G'};


%% Set the total number of frames
dim_exp = 500;


%% Define the time interval for processing the data
tim_indx = 166:265; % Time frames to be considered


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
VarLabels = {'-MET','Stop & go I','Stop & go II','Stop & go III',...
    'Open loop (60 min)','Open loop (75 min)','Open loop (150 min)',...
    'Stop & go T','Open loop (75 min) T','Stop & go G',...
    'Open loop (75 min) G'};

cat_VarNames = categorical(VarLabels);
cat_VarNames = reordercats(cat_VarNames,VarLabels);


%% Colormap
cMap = [0.4000    0.7608    0.6471;
        0.9882    0.5529    0.3843;
        0.9882    0.5529    0.3843;
        0.9882    0.5529    0.3843;
        0.5529    0.6275    0.7961;
        0.5529    0.6275    0.7961;
        0.5529    0.6275    0.7961;
        0.9882    0.5529    0.3843;
        0.5529    0.6275    0.7961;
        0.9882    0.5529    0.3843;
        0.5529    0.6275    0.7961];

cMap_R = cMap; % Colormap for R
    
%% Process the data to generate the Supp. Fig. 4
for q = 1:numel(exp_list)
    
    exp_name = exp_list{q};
    
    %% Load the output data
    load(strcat(pwd,'/Workspaces/',exp_name), 'trackedCELLS', ...
        'removedCELLS');

    Cells = [trackedCELLS,removedCELLS];
    clear trackedCELLS removedCELLS
    
    %% Compute the mean phase coherence
    disp('Computing the mean phase coherence')
    R = Mean_Phase_Coherence(Cells);
    
    %% Compute the mean phase Psi
    disp('Computing the mean phase Psi')
    Psi = Mean_Phase_Psi(Cells);
    
    %% Compute the mean fluorescence
    disp('Computing the mean fluorescence')
    MeanFluo = Mean_Fluorescence(Cells);
    
    %% Compute the mean radius
    disp('Computing the mean radius')
    radMEAN = Mean_Radius(Cells);
    
    
    %% Retrieve the processed output data
    matr_R(:,q) = R;
    matr_trMean(:,q) = MeanFluo;
    matr_Rad(:,q) = radMEAN;
    
    %% Assess the significance of R through Psi
    tmp_Psi = Psi(tim_indx,1);
    tmp_Psi = tmp_Psi(~isnan(tmp_Psi)); % Check if Psi contains NaN
    Psi_R = abs(1./numel(tmp_Psi).*sum(exp(1i*tmp_Psi)));
    V = 1 - Psi_R; % Circular variance V
    
    if V < .5
        
        cMap_R(q,:) = cMap(q,:)+.2;
        
    end
    
    %% Compute the PSD
    data_trMean = matr_trMean(tim_indx,q);
    
    tmp_data = data_trMean - movmean(data_trMean,50); % Zero mean signal
        
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

%% Compute mean R
R_mean(1,:) = nanmean(matr_R(tim_indx,:));

%% Compute mean radius
Rad_mean(1,:) = nanmean(matr_Rad(tim_indx,:));


%% Print panel a
F_SFIG4a_ = figure('Position', [1 1 540 360], 'DefaultAxesFontSize', 16);
hold on;
tmp_b = bar(cat_VarNames, R_mean.');
tmp_b.FaceColor = 'Flat';
tmp_b.CData = cMap_R;
ylabel('R');
print(F_SFIG4a_, './Figures/SuppFig4_a', '-dpng')


%% Print panel c
F_SFIG4c_ = figure('Position', [1 1 540 360], ...
    'DefaultAxesFontSize', 16);
tmp_b = bar(cat_VarNames, vct_trMean_psd(3,:).');
tmp_b.FaceColor = 'Flat';
tmp_b.CData = cMap;
ylabel('Power (dB)');
print(F_SFIG4c_, './Figures/SuppFig4_c', '-dpng');


%% Print panel e
F_SFIG4e_ = figure('Position', [1 1 540 360], ...
    'DefaultAxesFontSize', 16);
tmp_b = bar(cat_VarNames, vct_trMean_psd(2,:).');
tmp_b.FaceColor = 'Flat';
tmp_b.CData = cMap;
ylim([0,160]);
ylabel('Period (min)');
print(F_SFIG4e_, './Figures/SuppFig4_e', '-dpng');


%% Print panel f
F_SFIG4f_ = figure('Position', [1 1 540 360], 'DefaultAxesFontSize', 16);
hold on;
tmp_b = bar(cat_VarNames, Rad_mean.');
tmp_b.FaceColor = 'Flat';
tmp_b.CData = cMap;
ylabel('Radius (px)');
print(F_SFIG4f_, './Figures/SuppFig4_f', '-dpng');


%%
rmpath('./Code_supporting_main/'); % Remove this subfolder from the path variable