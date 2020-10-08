%% InitController_.m
%%% OCTOBER 8, 2020

function [U, Theta_r] = InitController_(ctrl_name, tSPAN)

dim_tSPAN = length(tSPAN);

U = nan(dim_tSPAN,1);

Theta_r = nan(dim_tSPAN,1);

%% Set controller parameters
switch ctrl_name
    
    case 'RefOsc'
        
        Theta_r(1) = 0;
        
    case 'MPC'
        
    case 'Stop&Go'
        
    case 'Unforced'
        
        U = zeros(dim_tSPAN,1);
        
    case 'Forced'
        
        U = ones(dim_tSPAN,1);
        
    case 'OpenLoop'
        
    otherwise
        
        error('Unknown controller...');
        
end

end