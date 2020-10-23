%% 

function [MeanFluo,y_lim] = Mean_Fluorescence(Cells)

    dimEXP = 500;

    FLUO = NaN(dimEXP,length(Cells));

    for index = 1:length(Cells)
        FLUO(Cells(index).frame,index) = Cells(index).MeanGreenFluo;
    end

    FLUO = FLUO(1:dimEXP,:);
    
    clear index
    
    % MEAN FLUORESCENCE:
    MeanFluo = mean(FLUO,2,'omitnan');

    clear FLUO dimEXP Cells
    
    % SATURATION:
    y_lim = [10*floor(min(MeanFluo)/10), 10*ceil(max(MeanFluo)/10)];
    
end