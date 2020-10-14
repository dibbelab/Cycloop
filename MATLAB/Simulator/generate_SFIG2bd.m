%% generate_SFIG2bd.m
%%% OCTOBER 14, 2020

clear all

close all


%% Set the division flag, the controller and the strain
bool_div = true;

strain_mod = 'Non-Cycling'; % strain_mod := 'Non-Cycling'

ctrl_name = 'OpenLoop'; % ctrl_name := 'OpenLoop'


%% Set initial number of cells N_init
N_init = 3;


%% Set initial conditions
[x0, lineage] = InitCon_(N_init);


%% Set simulation time and tSPAN
t_i = 0; % Initial simulation time (min)

t_f = 600; % Final simulation time (min)

sampl_time = 2; % Sampling time (min)

tSPAN = t_i:sampl_time:t_f;


%% Set open-loop periods' array
vctT = 50:1:150;


%% Set open-loop pulses' array
vctP = 20:5:30;


%%
for z = vctT
    
    for q = vctP
        
        disp(['I am simulating T = ', num2str(z), ...
                ' min; P = ', num2str(q)]);
            
            if isfile(['./SFIG2bd_MAT/openLoop_T' num2str(z) '_P' ...
                    num2str(q) '_' strain_mod '_' ctrl_name '_.mat'])
                
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
            
            disp(['I am integrating at t = ', num2str(ts_i), ...
                ' min; N = ', num2str(N)]);
            
            if isnan(U(ITR))
                
                [U, Theta_r] = Compute_OpenLoop_(ITR, z, q, ...
                    ctrl_name, Theta_r, U, sampl_time);
            
            end
            
            [N, t_out, x_out, lineage] = excODEs_(N, ts_i, ...
                ts_f, U(ITR,:), t_out, x_out, lineage, bool_div, ...
                strain_mod, 1e-02);
        
        end
        
        
        %% Save the simulation data
        save(['./SFIG2bd_MAT/openLoop_T' num2str(z) '_P' num2str(q) ...
            '_' strain_mod '_' ctrl_name '_'], 't_out', 'x_out')
    
    
    end

end


%%
vctR = nan(numel(vctT), numel(vctP));
vctV = nan(numel(vctT), numel(vctP));

for z = 1:numel(vctT)
    
    for q = 1:numel(vctP)
        
        %%
        disp(['I am analysing T = ', num2str(vctT(z)), ...
                ' min; P = ', num2str(vctP(q))]);
            
            if ~isfile(['./SFIG2bd_MAT/openLoop_T' num2str(vctT(z)) '_P' ...
                    num2str(vctP(q)) '_' strain_mod '_' ctrl_name '_.mat'])
                
                continue
                
            end
        
        
        %% Load the simulation data
        load(['./SFIG2bd_MAT/openLoop_T' num2str(vctT(z)) '_P' num2str(vctP(q)) ...
            '_' strain_mod '_' ctrl_name '_'], 't_out', 'x_out');
        
        %% Retrieve the cells' phase Theta and the cells' Volume
        [tempTheta, tempVolume, tempR] = compute_Th_Vol_(t_out, x_out);
        
        vctR(z,q) = nanmean(tempR(end-100+1:end));
        
        tempV = nanmean(tempVolume(end-100+1:end,:),2);
        vctV(z,q) = nanmean(tempV);
 
        
    end

end

%%
F = figure('Position', [1 1 720 640], 'DefaultAxesFontSize', 20, ...
    'DefaultAxesLineWidth', 2.5, 'Renderer', 'Painters');

subplot(2,1,1);
hold on;
for q = 1:numel(vctP)
    scatter(vctT,vctR(:,q), 60, 'filled');
end
xlim([50,150]);
xticks(50:25:150)
ylim([0,1]);
yticks(0:.25:1);
xlabel('T_u (min)');
ylabel('$\bar{R}$', 'interpreter', 'latex');
legend(['D_{-Met} = ' num2str(vctP(1)) ' min'], ...
    ['D_{-Met} = ' num2str(vctP(2)) ' min'], ...
    ['D_{-Met} = ' num2str(vctP(3)) ' min'], 'Location', 'southeast');

    
subplot(2,1,2);
hold on;
for q = 1:numel(vctP)
    scatter(vctT,vctV(:,q), 60, 'filled');
end
xlim([50,150]);
xticks(50:25:150)
ylim([0,8]);
xlabel('T_u (min)');
ylabel('$\bar{V}$', 'interpreter', 'latex');

print(F, './Images/SFIG2bd', '-dsvg');
print(F, './Images/SFIG2bd', '-dpng');