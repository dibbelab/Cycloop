%% ComputePulse_.m
%%% OCTOBER 8, 2020

function [U, Theta_r] = ComputePulse_(ITR, T, d_p, ctrl_name, ...
    Theta_r, U, sampl_time)

switch ctrl_name
    
    case 'OpenLoop'
        
        tmp_ = mod(ITR*sampl_time,T);
        
        U(ITR) = tmp_ >= (T-d_p) || tmp_ == 0;
        
end

end