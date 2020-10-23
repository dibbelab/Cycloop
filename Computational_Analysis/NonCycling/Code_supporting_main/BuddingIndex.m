%% 

function BI = BuddingIndex(Cells)

    dimEXP = 500;

    PHI = NaN(dimEXP,length(Cells));
    
    for index = 1:length(Cells)
        PHI(Cells(index).frame,index) = Cells(index).Phase;
    end
    
    PHI = PHI(1:dimEXP,:);
    
    clear index
    
    BI_matrix = zeros(size(PHI));
    BI_matrix(PHI > 0 & PHI <= 2*pi-pi/2) = 1;
    BI_matrix(isnan(PHI) == 1) = NaN;
    BI = sum(BI_matrix,2,'omitnan')./sum(~isnan(BI_matrix),2);
    BI = 100.*BI(1:dimEXP);

    clear PHI BI_matrix dimEXP Cells
    
end