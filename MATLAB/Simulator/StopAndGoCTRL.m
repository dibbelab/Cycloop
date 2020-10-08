%% StopAndGoCTRL.m 
%%% OCTOBER 8, 2020

function u = StopAndGoCTRL(phi)

N = 0;
    
for z = 1:length(phi) % Check if the cells are in the G1 phase
    
    if (phi(z) >= 0 && phi(z) <= pi/2) || phi(z) == 0
        
        N = N+1;
    
    end
    
end

if N > sum(~isnan(phi))/2 % Check if more than 50% of the cells are in G1
    
    u = 1;  % -Met

else
    
    u = 0;  % +Met

end