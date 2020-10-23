%% ref_osc.m
%%% MARCH 27, 2020

function [u, Theta_r_next] = ref_osc(x, Theta_r)

%%
Theta_c = 0.4*2*pi;

Vol_c = 1;


Theta = mod(x(end,1:2:end).', 2*pi);
Volume = x(end,2:2:end).';


%%
indX = Volume >= Vol_c;

Theta_m = Theta(indX);


s = sum(sin(Theta_m - Theta_r) .* (Theta_m < Theta_c));

if s >= 0
    
    u = 0;
    
else
    
    u = 1;
end


%%
options = odeset('RelTol', 1e-08, 'AbsTol', 1e-06, 'MaxStep', 1e-01);

[~, xs] = ode23s(@RefOscODE, [0 2], Theta_r, options, Theta_m);


%%
Theta_r_next = xs(end);

end


function dxdt = RefOscODE(t, x, Theta_init)

%%
omega = 2*pi / 105; % First controller parameter

gamma = 1; % Second controller parameter


%%
Theta_m = Theta_init + omega .* t;

dxdt = omega + gamma .* sum(sin(Theta_m - x));

end