%% stop_and_go.m 
%%% OCTOBER 12, 2020

function u = stop_and_go(phi, nu)

N = sum(~isnan(phi));

N_G1 = 0;

for z = 1:length(phi) % Check if the cells are in the G1 phase
    
    if (phi(z) >= 0 && phi(z) <= pi/2) || phi(z) == 0
        
        N_G1 = N_G1+1;
    
    end
    
end



if N_G1/N > nu %
    
    u = 1;  % -Met

else
    
    u = 0;  % +Met

end

if (nu == 1) && (N_G1 == N)
    
    u = 1;  % -Met
    
end