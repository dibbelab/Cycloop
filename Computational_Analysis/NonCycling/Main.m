%% Main.m
%%% OCTOBER 23, 2020

clear all

close all

addpath('./Code_supporting_main/'); % Add this subfolder to the path variable


%% List of microfluidics experiments of the non-cycling strain
exp_list = {'Fig2_abcde_-MET', 'Fig2_fghij_Openloop60', ...
    'Fig2_klmno_Openloop75', 'Fig2_pqrst_Openloop150', ...
    'Fig3_fghij_Stop&goI', 'Fig3_klmno_Openloop75G', ...
    'Fig3_pqrst_Stop&goG', 'SupplFig3_abcde_Openloop75D20', ...
    'SupplFig5_abcde_Openloop75T', 'SupplFig5_fghij_Stop&goT', ...
    'SupplFig6_abcde_Stop&goII', 'SupplFig6_fghij_Stop&goIII'};

for exp = 1:length(exp_list)
    
    disp(['I am generating the figure: ' exp_list{exp}]);

    %% --------------------------------------------------------------------
    % INPUT DATA
    load(strcat(pwd,'/Workspaces/',exp_list{exp}), 'trackedCELLS', ...
        'removedCELLS', 'inputLEVELS', 'cropRECT');

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

    %% --------------------------------------------------------------------
    % PANEL A -> HEAT MAP FLUORESCENCE
    [HeatMap_Fluo,Ticks,Ticks_Lbs,Ext] = Heatmap_Fluorescence(Cells);

    %% --------------------------------------------------------------------
    % PANEL B -> MEAN FLUORESCENCE
    disp('Computing the mean fluorescence')
    [MeanFluo,y_lim] = Mean_Fluorescence(Cells);

    %% --------------------------------------------------------------------
    % PANEL C -> SINGLE CELL TRACES
    try % Try to loading the single-cell traces
        
        load(strcat(pwd,'/Cell_traces/cell_traces_',exp_list{exp}));
        
        [HeatMap_SingleCells] = Heatmap_SCFluorescence(SingleCells);
        
    catch % Single-cell trace dataset not found
        % if you would performe the reverse segmentation, run this branch
        
        disp('Performing the reverse segmentation...');
        
        addpath('./Code_image_processing/'); % Add this subfolder to the path variable
        
        Im_Path = strcat(pwd, '/Raw_images/', exp_list{exp});
        
        Cells_Reverse = Reverse_Segmentation(Im_Path, cropRECT, dimEXP);
        
        disp('Recovering the single-cell traces');
        
        [HeatMap_SingleCells,Traces] = SingleCellTraces(Cells, ...
            Cells_Reverse);
        
        rmpath('./Code_image_processing/');
        
    end
    
    %% --------------------------------------------------------------------
    % PANEL D -> BUDDING INDEX
    disp('Computing the budding index')
    BI = BuddingIndex(Cells);

    %% --------------------------------------------------------------------
    % CREATE FIGURE
    F = figure('Position', [1 1 720 720], 'DefaultAxesFontSize', 20, ...
                'DefaultAxesLineWidth', 2.5, 'Renderer', 'Painters');

    % FIRST PANEL: Heat Map Fluorescence
    subplot(8,1,1:2);
    
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
    subplot(8,1,3:4);
    plot([0:dimEXP-1]*2, MeanFluo, 'LineWidth', 2.5, 'Color', [.4 .76 .65]);
    set(gca, 'XLim', [0,dimEXP*2], 'YLim', y_lim, 'XTick',...
        0:100:1000, 'XTickLabel', {},'Box','off', 'YTick',...
        y_lim(1):20:y_lim(2), 'YTickLabel', y_lim(1):20:y_lim(2));
    ylabel('Mean fluo (a.u.)');
    CB = colorbar;
    CB.Visible = 'Off';

    % THIRD PANEL: Single-cell signals
    subplot(8,1,5:6);
    imALPHA = ones(size(HeatMap_SingleCells));
    imALPHA(isnan(HeatMap_SingleCells)) = 0;
    imagesc(HeatMap_SingleCells,'AlphaData',imALPHA), colorbar
    caxis(Ext);
    CB = colorbar;
    CB.Location = 'Eastoutside';
    CB.Label.String = 'Fluorescence (a.u.)';
    CB.Ticks = Ticks;
    CB.TickLabels = Ticks_Lbs;
    ylabel('Cell trace (#)')
    set(gca, 'XLim', [0,dimEXP], 'XTick', 0:50:dimEXP, 'XTickLabel', {}, ...
        'YLim', [0,+Inf], 'YDir', 'Normal', 'ColorMap', mymap,...
        'Box','off');

    % FOURTH PANEL: Budding Index
    subplot(8,1,7);
    plot([0:dimEXP-1]*2, BI, 'LineWidth', 2.5, 'Color', [.55 .63 .80]);
    hold on, plot([0:dimEXP-1]*2, 75*ones(dimEXP,1), 'LineWidth', 2.5);
    set(gca, 'XLim', [0,dimEXP*2], 'YLim', [0 100], 'XTick',...
        0:100:1000, 'YTick', 0:50:100, 'YTickLabel', {'0%','50%',...
        '100%'}, 'XTickLabel', {},'Box','off');
    ylabel('B.I. (%)');
    CB = colorbar;
    CB.Visible = 'Off';

    % FIFTH PANEL: Input
    subplot(8,1,8);
    imagesc(1-inputLEVELS);
    CB = colorbar;
    CB.Visible = 'Off';
    caxis([0,1])
    ylabel('Input');
    xlabel('Time (min)');

    if exp == 2 || exp == 3 || exp == 4 || exp == 6 || exp == 8 || exp == 9
        set(gca, 'XLim', [0,dimEXP*2], 'XTick', 0:100:dimEXP*2-100, 'XTickLabel', ...
            {(0:50:dimEXP)*2}, 'YLim', [0.2,1.5], 'Box', 'off', 'YTick', ...
            [0.5,1.5], 'YTickLabel', {'-MET','+MET'}, 'ColorMap', input_map);
    else
        set(gca, 'XLim', [0,dimEXP], 'XTick', 0:50:dimEXP-50, 'XTickLabel', ...
            {(0:50:dimEXP)*2}, 'YLim', [0.2,1.5], 'Box', 'off', 'YTick', ...
            [0.5,1.5], 'YTickLabel', {'-MET','+MET'}, 'ColorMap', input_map);
    end
    
    %% Print the figure
    print(F, ['./Figures/' exp_list{exp}], '-dpng')
    
end


%%
rmpath('./Code_supporting_main/'); % Remove this subfolder from the path variable