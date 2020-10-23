%% main_code.m
%%% OCTOBER 22, 2020

clear all

close all

addpath('./Code_simulator/'); % Add this subfolder to the path variable


%%
sims_list = {{'FIG3_be', true, 'Non-Cycling', 'Stop&Go', 3, 800, 2}, ...
    {'FIG4_lo', true, 'Cycling', 'RefOsc', 3, 800, 2}, ...
    {'SFIG7_be', true, 'Cycling', 'MPC', 3, 800, 2}};


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
    [t_out, x_out, U, Theta_r] = simulator(bool_div, strain_mod, ...
        ctrl_name, N_init, t_i, t_f, sampl_time);
    
    
    %% Retrieve the cells' phase Theta and the cells' Volume
    [Theta, Volume, R, Psi] = retrieve_data(t_out, x_out);
    
    
    %% Compute the fake output and the budding index
    [fake_out, mean_out, BI] = compute_fakeFluo_BI(strain_mod, t_out, Theta, ...
        Volume);
    
    
    %% Save the simulation data
    save(['./Output_simulations/' sim_name], 'sim_name', 'bool_div', 'strain_mod', ...
        'ctrl_name', 'N_init', 't_i', 't_f', 'sampl_time', 't_out', ...
        'x_out', 'U', 'Theta_r', 'Theta', 'Volume', 'R', 'Psi', ...
        'fake_out', 'mean_out', 'BI');
    
    
    %% Make image
    make_fig(sim_name, strain_mod, t_out, fake_out, mean_out, BI, U);
    
    
    %% Make movie
    make_mov(sim_name, strain_mod, ctrl_name, Theta, Volume, U, t_out, ...
        R, Psi, mean_out, Theta_r);
    
    %%
    clearvars -except sims_list z
    
end


%%
rmpath('./Code_simulator/');