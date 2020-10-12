%% ComputeInput_.m
%%% OCTOBER 12, 2020

function [U, Theta_r] = ComputeInput_(ITR, N, ctrl_name, Theta_r, x_out, U, sampl_time)

switch ctrl_name
    
    case 'RefOsc'
        
        [u, Theta_r_next] = RefOscCTRL_(x_out, Theta_r(ITR));
        
        
        U(ITR) = u;
        
        Theta_r(ITR+1,1) = Theta_r_next;
    
    case 'MPC'

        T_c = 50;
        
        if mod(ITR-1, T_c)==0
            
            u = mpcCTRL(ITR, sampl_time, U, x_out(end,1:2:end), ...
                x_out(end,2:2:end), N);
            
            
            if ITR+T_c-1 <= length(U)
                
                U(ITR:(ITR+T_c-1)) = u(sampl_time*ITR:sampl_time:sampl_time*(ITR+T_c-1));

            end
            
        end
        
    case 'Stop&Go'
        
        nu = .5;
        
        if isnan(U(ITR))
            
            u = StopAndGoCTRL(x_out(end,1:2:end), nu);
            
            if u == 0
                
                U(ITR) = 0;
            
            else
                
                if ITR+15 <= length(U)
                    
                    U(ITR:ITR+15) = u*ones(16,1);
                
                else
                    
                    k_trnk = length(U) - ITR;
                    
                    U(ITR:ITR+k_trnk) = u*ones(k_trnk+1,1);
                
                end
                
            end
            
        end
        
    case 'OpenLoop'
        
        T = 75;
        
        d_p = 30;
        
        tmp_ = mod(ITR*sampl_time,T);
        
        U(ITR) = tmp_ >= (T-d_p) || tmp_ == 0;
        
end

end