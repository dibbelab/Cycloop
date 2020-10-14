%% generate_SFIG2ce.m
%%% OCTOBER 14, 2020

clear all

close all


%% Set the division flag, the controller and the strain
bool_div = true;

strain_mod = 'Non-Cycling'; % strain_mod := 'Non-Cycling'

ctrl_name = 'Stop&Go'; % ctrl_name := 'Stop&Go'


%% Set initial number of cells N_init
N_init = 3;


%% Set initial conditions
[x0, lineage] = InitCon_(N_init);


%% Set simulation time and tSPAN
t_i = 0; % Initial simulation time (min)

t_f = 600; % Final simulation time (min)

sampl_time = 2; % Sampling time (min)

tSPAN = t_i:sampl_time:t_f;


%% Set threshold ni' array
vct_nu = 0:.05:1;


%%
for z = vct_nu
    
    disp(['I am simulating nu = ', num2str(z)]);
    
    if isfile(['./SFIG2ce_MAT/closedLoop_nu' num2str(z) '_' ...
            strain_mod '_' ctrl_name '_.mat'])
        
        continue
    
    end
    
    
    %% Set initial number of cells N
    N = N_init;
    
    
    %% Set the time vector and the state vector
    t_out = t_i;
    x_out = x0.';
    
    
    %% Set controller's parameters and input vector
    [U, Theta_r] = InitController_(ctrl_name, tSPAN);
    
    %% Simulate the population of N(t) oscillators
    for ITR = 1:length(tSPAN)-1
        
        ts_i = tSPAN(ITR);
        ts_f = tSPAN(ITR+1);
        
        disp(['I am integrating at t = ', num2str(ts_i), ' min; N = ', ...
            num2str(N)]);
        
        if isnan(U(ITR))
            
            [U, Theta_r] = Compute_ClosedLoop_(ITR, z, ctrl_name, ...
                Theta_r, x_out, U);
            
        end
        
        [N, t_out, x_out, lineage] = excODEs_(N, ts_i, ts_f, U(ITR,:), ...
            t_out, x_out, lineage, bool_div, strain_mod, 1e-02);
        
    end
    
    
    %% Save the simulation data
    save(['./SFIG2ce_MAT/closedLoop_nu' num2str(z) '_' strain_mod ...
            '_' ctrl_name '_.mat'], 't_out', 'x_out')
        
end


%%
vctR = nan(1, numel(vct_nu));
vctV = nan(1, numel(vct_nu));


for z = 1:numel(vct_nu)
    
    %%
    disp(['I am analysing nu = ', num2str(vct_nu(z))]);
    
    if ~isfile(['./SFIG2ce_MAT/closedLoop_nu' num2str(vct_nu(z)) '_' ...
            strain_mod '_' ctrl_name '_.mat'])
        
        continue
    
    end
    
    
    %% Load the simulation data
    load(['./SFIG2ce_MAT/closedLoop_nu' num2str(vct_nu(z)) '_' ...
        strain_mod '_' ctrl_name '_.mat'], 't_out', 'x_out');
    
    %% Retrieve the cells' phase Theta and the cells' Volume
    [tempTheta, tempVolume, tempR] = compute_Th_Vol_(t_out, x_out);
    
    vctR(1,z) = nanmean(tempR(end-100+1:end));
    
    tempV = nanmean(tempVolume(end-100+1:end,:),2);
    vctV(1,z) = nanmean(tempV);

end

%%
F = figure('Position', [1 1 720 640], 'DefaultAxesFontSize', 20, ...
    'DefaultAxesLineWidth', 2.5, 'Renderer', 'Painters');

subplot(2,1,1);
hold on;
scatter(vct_nu*100,vctR, 60, 'filled');
ylim([0,1]);
yticks(0:.25:1);
xlabel('\nu_%');
ylabel('$\bar{R}$', 'interpreter', 'latex');

subplot(2,1,2);
hold on;
scatter(vct_nu*100, vctV, 60, 'filled');
ylim([1.2,2]);
xlabel('\nu_%');
ylabel('$\bar{V}$', 'interpreter', 'latex');

print(F, './Images/SFIG2ce', '-dsvg');
print(F, './Images/SFIG2ce', '-dpng');