%% noncycling_odes.m
%%% OCTOBER 22, 2020

function dxdt = noncycling_odes(~, x, u, N)

omega = 2*pi / 75;

Theta_c = .25 * 2 * pi;

beta = .0083;

Vol_c = 1; % Critical volume


%%
Theta = nan(N,1);
Volume = nan(N,1);

for z = 1:N
    Theta(z,1) = mod(x(2*z-1), 2*pi);
    Volume(z,1) = x(2*z);
end


%%
dxdt = nan(2*N,1);

for z = 1:N
    
    if Volume(z) >= Vol_c
        dxdt(2*z-1,1) = omega .* ((Theta(z) >= Theta_c) + (Theta(z) < Theta_c) * u);
    else
        dxdt(2*z-1,1) = 0;
    end
    
    dxdt(2*z,1) = beta .* Volume(z) .* (Theta(z) < Theta_c);
    
end