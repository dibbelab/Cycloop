%% StopAndGoCTRL.m 
%%% OCTOBER 9, 2020

function u = StopAndGoCTRL(phi, nu)

if nargin == 1
    
    nu = .5;
    
end

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