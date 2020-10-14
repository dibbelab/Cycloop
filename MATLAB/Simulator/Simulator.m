%% Simulator.m
%%% OCTOBER 14, 2020

function [t_out, x_out, U, Theta_r] = Simulator(bool_div, strain_mod, ...
    ctrl_name, N_init, t_i, t_f, sampl_time)

%% Set initial conditions
[x0, lineage] = InitCon_(N_init);
    
    
%% Set tSPAN
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
    
    disp(['I am integrating at t = ', num2str(ts_i), ' min; N = ', ...
        num2str(N)]);
    
    if isnan(U(ITR))
        
        [U, Theta_r] = ComputeInput_(ITR, N, ctrl_name, Theta_r, x_out, ...
            U, sampl_time);
        
    end
    
    [N, t_out, x_out, lineage] = excODEs_(N, ts_i, ts_f, U(ITR,:), ...
        t_out, x_out, lineage, bool_div, strain_mod, 1e-01);
    
end

end