%% compute_input_SFIG2_ce.m
%%% OCTOBER 22, 2020

function [U, Theta_r] = compute_input_SFIG2_ce(ITR, nu, ctrl_name, Theta_r, x_out, U)

switch ctrl_name
    
    case 'Stop&Go'
        
        if isnan(U(ITR))
            
            u = stop_and_go(x_out(end,1:2:end), nu);
            
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

end