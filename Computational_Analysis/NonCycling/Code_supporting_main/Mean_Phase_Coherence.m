%% Mean_Phase_Coherence.m
%%% OCTOBER 23, 2020

function R = Mean_Phase_Coherence(Cells)

dimEXP = 500;

N = numel(Cells);

objsPHASE = nan(dimEXP,N);
    
for z = 1:N
    
    traceTP = Cells(z).frame;
    
    objsPHASE(traceTP, z) = Cells(z).Phase;

end

R = nan(dimEXP,1);

for p = 1:dimEXP
    
    tmp_phases = objsPHASE(p,~isnan(objsPHASE(p,:)));
    
    R(p) = abs(1./numel(tmp_phases).*sum(exp(1i*tmp_phases))); 
    
end

end