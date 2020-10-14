%% ctrlRefOsc.m
%%% OCTOBER 14, 2020

function u = ctrlRefOsc(ITR, trackedCELLS, smplngTM)

global Theta omega Theta_r PhaseMAT

Theta_c = 0.4*2*pi;

% Estimation phase
[stimaf,stimaw,ignore] = phase_estimation(ITR, trackedCELLS, smplngTM);

Theta = mod(stimaf(~ignore),2*pi); 
omega = stimaw(~ignore);

s = sum(sin(Theta - Theta_r) .* (Theta < Theta_c));

if s >= 0
    
    u = 0; % +Met
    
else
    
    u = 1; % -Met
end

options = odeset('RelTol', 1e-08, 'AbsTol', 1e-06, 'MaxStep', 1e-01);

[~,xs] = ode45(@ReferenceODE, [0 2], Theta_r, options);

Theta_r = xs(end);

PhaseMAT(ITR) = struct('trackedCELLS',[trackedCELLS(~ignore).LABEL],...
    'stimaf',Theta,'stimaw',omega,'Theta_r',Theta_r);


function dxdt = ReferenceODE(t,x)

global Theta omega

omega_r = 2*pi./105;

gamma = 1;

Theta_a = Theta + omega .* t;

dxdt = omega_r + gamma.*sum(sin(Theta_a - x));