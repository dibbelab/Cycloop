%% Compute_OpenLoop_.m
%%% OCTOBER 12, 2020

function [U, Theta_r] = Compute_OpenLoop_(ITR, T, d_p, ctrl_name, ...
    Theta_r, U, sampl_time)

switch ctrl_name
    
    case 'OpenLoop'
        
        tmp_ = mod(ITR*sampl_time,T);
        
        U(ITR) = tmp_ >= (T-d_p) || tmp_ == 0;
        
end

end