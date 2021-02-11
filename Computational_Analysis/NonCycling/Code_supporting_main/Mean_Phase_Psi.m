%% Mean_Phase_Psi.m
%%% FEBRUARY 11, 2021

function Psi = Mean_Phase_Psi(Cells)

dimEXP = 500;

N = numel(Cells);

objsPHASE = nan(dimEXP,N);
    
for z = 1:N
    
    traceTP = Cells(z).frame;
    
    objsPHASE(traceTP, z) = Cells(z).Phase;

end

Psi = nan(dimEXP,1);

for p = 1:dimEXP
    
    tmp_phases = objsPHASE(p,~isnan(objsPHASE(p,:)));
    
    Psi(p) = angle(1./numel(tmp_phases).*sum(exp(1i*tmp_phases))); 
    
end

end