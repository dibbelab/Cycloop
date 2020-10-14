%% fakeCTRL.m
%%% OCTOBER 14, 2020

function fakeCTRL(ITR,trackedCELLS,smplngTM)

global PhaseMAT

% Phase estimation
[stimaf,stimaw,ignore] = phase_estimation(ITR,trackedCELLS,smplngTM);

Theta = mod(stimaf(~ignore),2*pi); 
omega = stimaw(~ignore);

PhaseMAT(ITR) = struct('trackedCELLS',[trackedCELLS(~ignore).LABEL], ...
    'stimaf',Theta,'stimaw',omega,'Theta_r',NaN);

end

