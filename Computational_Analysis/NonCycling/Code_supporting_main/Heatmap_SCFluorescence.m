%% 

function [HeatMap_SingleCells] = Heatmap_SCFluorescence(SingleCellTraces)
    
    dimEXP = 500;

    Fluo_temp = reshape(SingleCellTraces,[1,size(SingleCellTraces,1)*size(SingleCellTraces,2)]);
    Fluo_temp(isnan(Fluo_temp)) = [];
    Percentile = quantile(Fluo_temp,[.25 .5 .75]);
    
    STEP = (Percentile(3)-Percentile(1))./2;
    
    clear Fluo_temp
    
    HeatMap_SingleCells = SingleCellTraces;
    HeatMap_SingleCells(HeatMap_SingleCells < Percentile(1)) = Percentile(1)-STEP;
    HeatMap_SingleCells(HeatMap_SingleCells >= Percentile(1) & HeatMap_SingleCells < Percentile(2)) = (Percentile(2)+Percentile(1))/2;
    HeatMap_SingleCells(HeatMap_SingleCells >= Percentile(2) & HeatMap_SingleCells < Percentile(3)) = (Percentile(3)+Percentile(2))/2;
    HeatMap_SingleCells(HeatMap_SingleCells >= Percentile(3)) = Percentile(3)+STEP;
    
    clear Percentile STEP SingleCellTraces
    
end