%% simulator_main.m
%%% OCTOBER 12, 2020

clear all

close all


%% Set the division flag, the controller and the strain
bool_div = true; % bool_div := 'true' | 'false'

strain_mod = 'Non-Cycling'; % strain_mod := 'Cycling' | 'Non-Cycling'

ctrl_name = 'Stop&Go'; % ctrl_name := 'RefOsc' | 'MPC' | 'Stop&Go'


%% Set initial number of cells N_init
N_init = 3;


%% Set initial conditions
[x0, lineage] = InitCon_(N_init);


%% Set simulation time and tSPAN
t_i = 0; % Initial simulation time (min)

t_f = 800; % Final simulation time (min)

sampl_time = 2; % Sampling time (min)

tSPAN = t_i:sampl_time:t_f;


%% Set initial number of cells N.
N = N_init;


%% Set the time vector and the state vector.
t_out = t_i;
x_out = x0.';


%% Set controller's parameters and input vector
[U, Theta_r] = InitController_(ctrl_name, tSPAN);


%% Simulate the population of N(t) oscillators
for ITR = 1:length(tSPAN)-1
    
    ts_i = tSPAN(ITR);
    ts_f = tSPAN(ITR+1);
    
    disp(['I am integrating at t = ', num2str(ts_i), ' min; N = ', num2str(N)]);
    
    if isnan(U(ITR))
        
        [U, Theta_r] = ComputeInput_(ITR, N, ctrl_name, Theta_r, x_out, ...
            U, sampl_time);
        
    end
    
    [N, t_out, x_out, lineage] = excODEs_(N, ts_i, ts_f, U(ITR,:), ...
        t_out, x_out, lineage, bool_div, strain_mod);
    
end


%% Retrieve the cells' phase Theta and the cells' Volume
[Theta, Volume, R, Psi] = compute_Th_Vol_(t_out, x_out);


%% Compute the fake output and the budding index
[fake_out, mean_out, BI] = fakeOUT_BI_(strain_mod, t_out, Theta, Volume);


%% Save the simulation data
save(['./MAT/sim_' strain_mod '_' ctrl_name '_'])


%% Make image
makeFIG_(strain_mod, ctrl_name, t_out, fake_out, mean_out, BI, U)


%% Make movie
makeMOV_(strain_mod, ctrl_name, Theta, Volume, U, t_out, R, Psi, mean_out, Theta_r)