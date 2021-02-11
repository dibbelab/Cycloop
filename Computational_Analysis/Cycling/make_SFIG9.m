%% make_SFIG9.m
%%% FEBRUARY 7, 2021

clear all

close all

%% List of microfluidics experiments of the cycling strain
exp_list = {'FIG4_fghij_RefOsc_I', 'SFIG8_abcde_RefOsc_II', ...
    'SFIG8_fghij_RefOsc_III', 'FIG4_pqrst_RefOscG'};


%% Define the labels associated to each experiment
VarLabels = {'Ref. osc. I','Ref. osc. II','Ref. osc. III', 'Ref. osc. G'};


%% Define the time interval for processing the data
tim_indx = 51:300; % Time frames to be considered


%% Allocate an array for Spearman's correlation
rho = nan(1,numel(exp_list)); % Time frames to be considered


%%
F = figure('Position', [1 1 1440 720], 'DefaultAxesFontSize', 20, ...
    'DefaultAxesLineWidth', 2.5, 'Renderer', 'Painters');


%%
for q = 1:numel(exp_list)
    
    exp_name = exp_list{q};
    
    disp(['I am generating the figure: ' exp_name]);
    
    %% Try to loading the processed data
    try
        
        load(['./Processed_data/proc_data_' exp_name '.mat']);
        
    catch % Otherwise, process the output data
        
        process_output_data(exp_name);
        
        load(['./Processed_data/proc_data_' exp_name '.mat']);
        
    end
    
    
    %% Comparison between reference oscillator and average phase
    subplot(2, 2, q)
    
    hold on;
    
    plot(vct_time(tim_indx), Theta_ref(tim_indx), 'LineWidth', 2.5, ...
        'Color', [.9373 .5412 .3843]);
    
    plot(vct_time(tim_indx), Psi(tim_indx), 'LineWidth', 2.5, 'Color', ...
        [.4039 .6627 .8118]);
    
    set(gca, 'YLim', [0,2*pi], 'YTick', 0:pi:2*pi, 'YTickLabel', ...
        {'0','\pi','2\pi'});
    
    xlabel('Time (min)');
    
    ylabel('Phase (rad)');
    
    title(VarLabels{q});
    
    legend('\vartheta_r', '\psi')

    tmp_rho = corr(Theta_ref(tim_indx).',Psi(tim_indx).', ...
        'Type', 'Spearman');
    
    rho(q) = tmp_rho;
    
end


%% Print the figure
print(F, './Figures/SFIG9', '-dpng')