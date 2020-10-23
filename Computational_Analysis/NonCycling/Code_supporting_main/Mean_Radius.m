%% Mean_Radius.m
%%% OCTOBER 23, 2020

function radMEAN = Mean_Radius(Cells)

dimEXP = 500;

N = numel(Cells);

objsRAD = nan(dimEXP,N);
    
for z = 1:N
    
    traceTP = Cells(z).frame;
    
    objsRAD(traceTP, z) = (Cells(z).MajorAxis)./2;

end

objsRAD = objsRAD(1:dimEXP,:);

objsRAD(objsRAD>40) = NaN;

radMEAN = nanmean(objsRAD,2);

end