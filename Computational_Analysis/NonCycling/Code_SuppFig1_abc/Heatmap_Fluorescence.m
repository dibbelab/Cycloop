%% 

function [HeatMap_Fluo,Ticks,Ticks_Lbs,Ext] = Heatmap_Fluorescence(Cells)

    dimEXP = 500;

    FLUO = NaN(dimEXP,length(Cells));

    for index = 1:length(Cells)
        FLUO(Cells(index).frame,index) = Cells(index).MeanGreenFluo;
    end

    FLUO = FLUO(1:dimEXP,:);
    
    clear index
    
    % Cell number:
    N = zeros(dimEXP,1);
    for t = 1:dimEXP
        for z = 1:length(Cells)
            N(t) = N(t)+sum(Cells(z).frame == t);
        end
    end
    
    clear t z
    
    % HEATMAP NO SORTED:
    Fluo = NaN(dimEXP,max(N));
    for t = 1:dimEXP
        temp = NaN(1,max(N));
        ind = 1;
        for z = 1:length(Cells)
            if ~isnan(FLUO(t,z))
                temp(ind) = FLUO(t,z);
                ind = ind+1;
            end
        end
        Fluo(t,:) = temp;
        clear temp
    end
    
    HeatMap_temp = Fluo';
    
    clear Fluo ind Cells dimEXP N t z 
    
    Fluo_temp = reshape(FLUO,[1,size(FLUO,1)*size(FLUO,2)]);
    Fluo_temp(isnan(Fluo_temp)) = [];
    Percentile = quantile(Fluo_temp,[.25 .5 .75]);
    
    clear Fluo_temp FLUO
    
    STEP = (Percentile(3)-Percentile(1))./2;
    Ticks = [Percentile(1), Percentile(1)+STEP, Percentile(3)];
    Ticks_Lbs = {num2str(round(Percentile(1).*9)),num2str(round(Percentile(2).*9)),num2str(round(Percentile(3).*9))};
    Ext = [Percentile(1)-STEP, Percentile(3)+STEP];
    
    HeatMap_Fluo = HeatMap_temp;
    HeatMap_Fluo(HeatMap_temp < Percentile(1)) = Percentile(1)-STEP;
    HeatMap_Fluo(HeatMap_temp >= Percentile(1) & HeatMap_temp < Percentile(2)) = (Percentile(2)+Percentile(1))/2;
    HeatMap_Fluo(HeatMap_temp >= Percentile(2) & HeatMap_temp < Percentile(3)) = (Percentile(3)+Percentile(2))/2;
    HeatMap_Fluo(HeatMap_temp >= Percentile(3)) = Percentile(3)+STEP;
    
    clear STEP Percentile HeatMap_temp
    
end