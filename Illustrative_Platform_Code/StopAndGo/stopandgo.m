%% stopandgo.m
%%% OCTOBER 14, 2020

function u = stopandgo(phi)

N = 0;

for z = 1:length(phi) % check if the cells are in G1
    
    if (phi(z) > 2*pi-pi/2 && phi(z) <= 2*pi) || phi(z) == 0
        
        N = N+1;
    
    end
    
end

if N > sum(~isnan(phi))/2 % If more than 50% of the cells are in G1, give a pulse
    
    u = 1;  % -Met

else
    
    u = 0;  % +Met

end

end