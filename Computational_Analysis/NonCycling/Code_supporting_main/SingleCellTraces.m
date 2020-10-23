%% 

function [HeatMap_SingleCells,Traces] = SingleCellTraces(Cells,Cells_Reverse)
    
    dimEXP = 500;
    
    FLUO = NaN(dimEXP,length(Cells));

    for index = 1:length(Cells)
        FLUO(Cells(index).frame,index) = Cells(index).MeanGreenFluo;
    end

    FLUO = FLUO(1:dimEXP,:);
    
    clear index
    
    Fluo_temp = reshape(FLUO,[1,size(FLUO,1)*size(FLUO,2)]);
    Fluo_temp(isnan(Fluo_temp)) = [];
    Percentile = quantile(Fluo_temp,[.25 .5 .75]);
    
    STEP = (Percentile(3)-Percentile(1))./2;
    
    clear FLUO Fluo_temp

    for x = 1:length(Cells_Reverse)
        [~,I] = sort(Cells_Reverse(x).frame,'ascend');

        Cells_ReverseSorted(x).LABEL = Cells_Reverse(x).LABEL; 
        Cells_ReverseSorted(x).Centroid = Cells_Reverse(x).Centroid(I,:); 
        Cells_ReverseSorted(x).NucleusIdxPixel = Cells_Reverse(x).NucleusIdxPixel;
        Cells_ReverseSorted(x).MeanRedFluo = Cells_Reverse(x).MeanRedFluo(I);
        Cells_ReverseSorted(x).Area = Cells_Reverse(x).Area(I);
        Cells_ReverseSorted(x).MajorAxis = Cells_Reverse(x).MajorAxis(I);
        Cells_ReverseSorted(x).MinorAxis = Cells_Reverse(x).MinorAxis(I);
        Cells_ReverseSorted(x).Orientation = Cells_Reverse(x).Orientation(I);
        Cells_ReverseSorted(x).MeanGreenFluo = Cells_Reverse(x).MeanGreenFluo(I);
        Cells_ReverseSorted(x).BoundingBox = Cells_Reverse(x).BoundingBox(I,:);
        Cells_ReverseSorted(x).RelativeNucleus = Cells_Reverse(x).RelativeNucleus(I,:);
        Cells_ReverseSorted(x).Mask = Cells_Reverse(x).Mask;
        Cells_ReverseSorted(x).frame = Cells_Reverse(x).frame(I);
        Cells_ReverseSorted(x).parentLABEL = Cells_Reverse(x).parentLABEL;
        Cells_ReverseSorted(x).ROOT = Cells_Reverse(x).ROOT;
        Cells_ReverseSorted(x).LINEAGE = Cells_Reverse(x).LINEAGE;
        Cells_ReverseSorted(x).Phase = [];
    end

    clear Cells_Reverse I x

    Cells_Reverse = Cells_ReverseSorted;
    clear Cells_ReverseSorted
    
    [Cells,Cells_Reverse] = SameCell_Identification(Cells,Cells_Reverse);
    
    [Cells,Cells_Reverse] = OverlappedCells_Identification(Cells,Cells_Reverse);
    
    [Cells,Cells_Reverse] = NoFrameLost_Identification(Cells,Cells_Reverse);
    
    Cells = OneFrameLost_Identification(Cells,Cells_Reverse);
    
    clear Cells_Reverse
    
    Cells = Remove_Duplicates(Cells);
    
    Fluo = NaN(dimEXP,length(Cells));

    INDEX = [];
    Start = [];

    for index = 1:length(Cells)
        Fluo(Cells(index).frame,index) = Cells(index).MeanGreenFluo;
        Start = [Start;Cells(index).frame(1)];
        if length(Cells(index).frame) >= 150
            INDEX = [INDEX;index];
        end
    end
    
    clear Cells index

    Fluo = Fluo(1:dimEXP,INDEX);
    Start = Start(INDEX);
    
    clear INDEX dimEXP

    [~,index] = sort(Start,'ascend');
    Traces = Fluo(:,index)';
    
    HeatMap_SingleCells = Fluo(:,index)';
    HeatMap_SingleCells(HeatMap_SingleCells < Percentile(1)) = Percentile(1)-STEP;
    HeatMap_SingleCells(HeatMap_SingleCells >= Percentile(1) & HeatMap_SingleCells < Percentile(2)) = (Percentile(2)+Percentile(1))/2;
    HeatMap_SingleCells(HeatMap_SingleCells >= Percentile(2) & HeatMap_SingleCells < Percentile(3)) = (Percentile(3)+Percentile(2))/2;
    HeatMap_SingleCells(HeatMap_SingleCells >= Percentile(3)) = Percentile(3)+STEP;
    
    clear Percentile STEP Start index Fluo
    
end