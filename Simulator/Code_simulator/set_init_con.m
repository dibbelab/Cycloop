%% set_init_con.m
%%% OCTOBER 22, 2020

function [x0, lineage] = set_init_con(N)

%% Set initial conditions of oscillators' phase.
if N == 1
    
    Theta_0 = 0;
    
else
    
    tmp_Theta_0 = linspace(0, 2*pi, N+1);
    
    Theta_0 = tmp_Theta_0(1:end-1);
    
end


%% Set initial conditions of oscillators' volume.
Volume_0 = ones(1,N);


%% Set state initial conditions and lineage struct
x0 = nan(2*N,1);

lineage = struct('label', {}, 'init', {}, 'root', {}, 'leaf', {});

for z = 1:N
    
    x0((2*z-1:2*z),:) = [Theta_0(z); Volume_0(z)];
    
    lineage(z) = struct('label', z, 'init', 0, 'root', 0, 'leaf', []);
    
end