%% make_SuppFig1_abc.m
%%% OCTOBER 23, 2020

clear all

close all

addpath('./Code_SuppFig1_abc/'); % Add this subfolder to the path variable


%% ------------------------------------------------------------------------
% INPUT DATA
load('./Workspaces/SupplFig1_abc_+MET', 'trackedCELLS', 'removedCELLS', ...
    'inputLEVELS','cropRECT');

Cells = [trackedCELLS,removedCELLS];
clear trackedCELLS removedCELLS

dimEXP = 500;

% COLORMAP FOR THE HISTOGRAMS:
mymap = [0.24 0.15 0.66
         0.15 0.59 0.92
         0.51 0.80 0.35
         0.98 0.98 0.08];

% COLORMAP INPUT:
input_map = [.99 .55 .38
              1   1   1];

%% ------------------------------------------------------------------------
% PANEL A -> HEAT MAP FLUORESCENCE
[HeatMap_Fluo,Ticks,Ticks_Lbs,Ext] = Heatmap_Fluorescence(Cells);

%% ------------------------------------------------------------------------
% PANEL B -> MEAN FLUORESCENCE
disp('Computing the mean fluorescence')
[MeanFluo,y_lim] = Mean_Fluorescence(Cells);

%% ------------------------------------------------------------------------
% CREATE FIGURE
F = figure('Position', [1 1 720 450], 'DefaultAxesFontSize', 20, ...
            'DefaultAxesLineWidth', 2.5, 'Renderer', 'Painters');

% FIRST PANEL: Heat Map Fluorescence
subplot(5,1,1:2);

for z = 1:dimEXP % Removing the swirl effect        
    HeatMap_temp = HeatMap_Fluo(:,z);
    tmp_dim = sum(~isnan(HeatMap_temp));
    p = randperm(tmp_dim);
    HeatMap_Fluo(1:tmp_dim,z) = HeatMap_temp(p);
end

imALPHA = ones(size(HeatMap_Fluo));
imALPHA(isnan(HeatMap_Fluo)) = 0;
imagesc(HeatMap_Fluo,'AlphaData',imALPHA), 
caxis(Ext);
CB = colorbar;
CB.Location = 'Eastoutside';
CB.Label.String = 'Fluorescence (a.u.)';
CB.Ticks = Ticks;
CB.TickLabels = Ticks_Lbs;
ylabel('Cell (#)')
set(gca, 'XLim', [0,dimEXP], 'XTick', 0:50:dimEXP, 'XTickLabel', {}, ...
    'YLim', [0,+Inf], 'YDir', 'Normal', 'ColorMap', mymap,...
    'Box','off');

% SECOND PANEL: Mean Fluorescence
subplot(5,1,3:4);
plot([0:dimEXP-1]*2, MeanFluo, 'LineWidth', 2.5, 'Color', [.4 .76 .65]);
set(gca, 'XLim', [0,dimEXP*2], 'YLim', y_lim, 'XTick',...
    0:100:1000, 'XTickLabel', {},'Box','off', 'YTick',...
    y_lim(1):2:y_lim(2)-1, 'YTickLabel', y_lim(1).*9:20:y_lim(2).*9);
ylabel('Mean fluo (a.u.)');
CB = colorbar;
CB.Visible = 'Off';

% THIRD PANEL: Input
subplot(5,1,5);
imagesc(1-inputLEVELS);
CB = colorbar;
CB.Visible = 'Off';
caxis([0,1])
ylabel('Input');
xlabel('Time (min)');

set(gca, 'XLim', [0,dimEXP], 'XTick', 0:50:dimEXP-50, 'XTickLabel', ...
    {(0:50:dimEXP)*2}, 'YLim', [0.2,1.5], 'Box', 'off', 'YTick', ...
    [0.5,1.5], 'YTickLabel', {'-MET','+MET'}, 'ColorMap', input_map);

%% Print the SuppFig1_abc
print(F, './Figures/SuppFig1_abc', '-dpng')

%%
rmpath('./Code_SuppFig1_abc/'); % Remove this subfolder from the path variable