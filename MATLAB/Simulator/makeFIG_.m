%% makeFIG_.m
%%% OCTOBER 14, 2020

function makeFIG_(sim_name, strain_mod, t_out, fake_out, mean_out, ...
    budd_indx, U)

% This is the code used to draw the third panel
switch strain_mod
    case 'Cycling'
        
        cmap = parula(2);
        
        dim_bin = 2;
        
        ideal_bi_pc = 60;
        
    case 'Non-Cycling'
        
        cmap = parula(4);
        
        dim_bin = 4;
        
        ideal_bi_pc = 75;
        
end

F = figure('Position', [1 1 720 640], 'DefaultAxesFontSize', 20, ...
        'DefaultAxesLineWidth', 2.5, 'Renderer', 'Painters');

fake_out = fake_out.';

[dim_m,dim_n] = size(fake_out);


%% First panel containing the total cells measured in each frame
subplot(6,1,1:2);

% imALPHA denotes the points in the matrix fluo_Arr that are valid
imALPHA = ones(dim_m, dim_n);

imALPHA(isnan(fake_out)) = 0;

% This is the code used to draw the first panel
imagesc(fake_out, 'AlphaData', imALPHA);

caxis([0,1]);

CB = colorbar;

colormap(gca, cmap);

CB.Location = 'Eastoutside';

CB.LineWidth = 2.5;

CB.Ticks = linspace(0,1,dim_bin+1);

CB.Label.String = 'Fluorescence (n.u.)';

ylabel('Cell (#)')
    
set(gca, 'XLim', [0,dim_n], 'XTick', 0:50:dim_n, 'XTickLabel', {}, ...
    'YLim', [0,+Inf], 'YDir', 'Normal');


%% Second panel containing the average fluorescence signal
subplot(6,1,3:4)

plot(t_out, mean_out, 'LineWidth', 2.5, 'Color', [.4 .76 .65]);
    
set(gca, 'XLim', [0,t_out(end)], 'YLim', [-.5 1.5], 'XTick', 0:100:1000, ...
    'XTickLabel', {}, 'YTick', 0:.5:1);

ylabel('Mean fluo (n.u.)');

CB = colorbar;

CB.Visible = 'Off';


%% Third panel containing the budding index
subplot(6,1,5);

hold on;

line([0 t_out(end)], ideal_bi_pc.*ones(1,2), 'LineWidth', 2.5, ...
    'Color', [1 .45 .45]);

plot(t_out, budd_indx, 'LineWidth', 2.5, 'Color', [.55 .63 .80]);

set(gca, 'XLim', [0,t_out(end)], 'YLim', [0,100], 'XTick', 0:100:1000, ...
    'XTickLabel', {}, 'YTick', 0:50:100, 'YTickLabel', {'0%','50%','100%'});

ylabel('B.I. (%)');

CB = colorbar;

CB.Visible = 'Off';


%% Fourth panel containing the input
subplot(6,1,6);

input_Arr = [zeros(1,dim_n); U.'];

% This is the code used to draw the first panel
imagesc(input_Arr, 'AlphaData', input_Arr);

colormap(gca,[.99 .55 .38]);

CB = colorbar;

CB.Visible = 'Off';

set(gca, 'XLim', [0,dim_n], 'YLim', [1.25,2.5], 'XTick', 0:50:350, ...
        'XTickLabel', 0:100:700, 'YTick', [1.5,2.5], 'YTickLabel', ...
        {'-MET','+MET'});

xlabel('Time (min)');

ylabel('Input');


%% Saving the figure
print(F, ['./Images/' sim_name], '-dsvg')
print(F, ['./Images/' sim_name], '-dpng')
