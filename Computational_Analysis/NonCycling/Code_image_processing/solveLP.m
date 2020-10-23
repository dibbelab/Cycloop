%% trackingYEA.m
%%% APRIL 14, 2017
% GIANSIMONE

function [M, STATUS] = solveLP(oldP, newP)

N1 = size(oldP,1);

N2 = size(newP,1);

COST = zeros(1,N1*N2);

Aeq = sparse(N2,N1*N2);


for i = 1:N1
    
    for j = 1:N2
        
        COST(1,(((i-1)*N2)+j)) = norm(oldP(i,:) - newP(j,:));
        
    end
    
end


for i = 1:N2
    
    Aeq(i,i:N2:N1*N2) = 1;

end


Beq = ones(1,N2);


LB = sparse(N1*N2,1);

UB = [];

[xMIN, ~, STATUS] = linprog(COST, [], [], Aeq, Beq, LB, UB);

M = reshape(xMIN, N2, N1)';

M = uint32(M);

end