%% fakeCTRL.m
%%% OCTOBER 14, 2020

function fakeCTRL(ITR,trackedCELLS,smplngTM)

global PhaseMAT

% Phase estimation
[stimaf,~,ignore] = phase_estimation(ITR,trackedCELLS,smplngTM);
stimaw=(2*pi/105)*ones(1,length(stimaf));

Theta = mod(stimaf(~ignore),2*pi); 
omega = stimaw(~ignore);

PhaseMAT(ITR) = struct('trackedCELLS',[trackedCELLS(~ignore).LABEL],...
    'stimaf',Theta,'stimaw',omega);

end

