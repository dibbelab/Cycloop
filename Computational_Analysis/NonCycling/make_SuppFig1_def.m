%% make_SuppFig1_def.m
%%% OCTOBER 23, 2020

clear all

close all

%% Single-cell traces from experiment shown in Fig. 2a-e
exp_name = 'Fig2_abcde_-MET';

%% Loading the total number of frames in the experiment
load(['./Workspaces/' exp_name], 'dimEXP');

%% Loading the single-cell traces
load(['./Cell_traces/cell_traces_' exp_name]);

%% Indices of the single-cell traces shown in Supplementary Fig. 1d-f
trace_indx = [45, 48, 58];

%% Colormap
cmap = [.7451 .7294 .8549
        .9843 .5020 .4471
        .5020 .6941 .8275];

%% Generate the figure
F = figure('Position', [1 1 720 540], 'DefaultAxesFontSize', 20, ...
    'DefaultAxesLineWidth', 2.5, 'Renderer', 'Painters');

%% Generate each panel containing the illustrative trace
for z = 1:numel(trace_indx)
    
    subplot(numel(trace_indx),1,z);
    
    plot((0:dimEXP-1)*2, SingleCells(trace_indx(z),:), 'LineWidth', ...
        2.5, 'Color', cmap(z,:));
    
    xlim([0,dimEXP*2]);
    
    ylim([0,150]);
    
    if z == 2
        
        ylabel('Fluorescence (a.u.)');
        
    end
    
    legend(['Example trace ' num2str(z)],'Location','southeast');
    
end

xlabel('Time (min)')


%% Print the SuppFig1_def
print(F, './Figures/SuppFig1_def', '-dpng')