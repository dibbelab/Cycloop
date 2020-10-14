%% main_code.m
%%% OCTOBER 14, 2020

clear all

close all


%%
sims_list = {{'FIG3be_', true, 'Non-Cycling', 'Stop&Go', 3, 800, 2}, ...
    {'FIG4lo_', true, 'Cycling', 'RefOsc', 3, 800, 2}, ...
    {'SFIG7be_', true, 'Cycling', 'MPC', 3, 800, 2}};


%%
for z = sims_list
    
    sim_name = z{1}{1};
    
    %% Set the division flag, the controller and the strain
    bool_div = z{1}{2}; % bool_div := 'true' | 'false'
    
    strain_mod = z{1}{3}; % strain_mod := 'Cycling' | 'Non-Cycling'
    
    ctrl_name = z{1}{4}; % ctrl_name := 'RefOsc' | 'MPC' | 'Stop&Go'
    
    
    %% Set initial number of cells N_init
    N_init = z{1}{5};
    
    
    %% Set simulation time
    t_i = 0; % Initial simulation time (min)
    
    t_f = z{1}{6}; % Final simulation time (min)
    
    sampl_time = z{1}{7}; % Sampling time (min)
    
    
    %% Simulate function
    [t_out, x_out, U, Theta_r] = Simulator(bool_div, strain_mod, ...
        ctrl_name, N_init, t_i, t_f, sampl_time);
    
    
    %% Retrieve the cells' phase Theta and the cells' Volume
    [Theta, Volume, R, Psi] = compute_Th_Vol_(t_out, x_out);
    
    
    %% Compute the fake output and the budding index
    [fake_out, mean_out, BI] = fakeOUT_BI_(strain_mod, t_out, Theta, ...
        Volume);
    
    
    %% Save the simulation data
    save(['./MAT/' sim_name], 'sim_name', 'bool_div', 'strain_mod', ...
        'ctrl_name', 'N_init', 't_i', 't_f', 'sampl_time', 't_out', ...
        'x_out', 'U', 'Theta_r', 'Theta', 'Volume', 'R', 'Psi', ...
        'fake_out', 'mean_out', 'BI');
    
    
    %% Make image
    makeFIG_(sim_name, strain_mod, t_out, fake_out, mean_out, BI, U);
    
    
    %% Make movie
    makeMOV_(sim_name, strain_mod, ctrl_name, Theta, Volume, U, t_out, ...
        R, Psi, mean_out, Theta_r);
    
    %%
    clearvars -except sims_list z
    
end