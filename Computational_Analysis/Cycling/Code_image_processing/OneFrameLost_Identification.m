%% OneFrameLost_Identification.m
%%% OCTOBER 15, 2020

function Cells = OneFrameLost_Identification(Cells,Cells_Reverse)

dimEXP = 500;

TwoFrame = false;

while ~TwoFrame
    toDELETE_Forward = []; toDELETE_Reverse = [];
    CELLS_Recovered = [];
    
    CELLS = [Cells,Cells_Reverse];
    
    for x = 1:length(CELLS)
        StartFrame(x) = CELLS(x).frame(1);
        EndFrame(x) = CELLS(x).frame(end);
    end
    
    for i = 1:length(EndFrame)
        ind = find(StartFrame == EndFrame(i)+2);
        INDEX{i} = ind;
    end
    
    for k = 1:length(INDEX)
        for m = 1:length(INDEX{k})
            if k ~= INDEX{k}(m) && norm(CELLS(k).Centroid(end,:)-...
                    CELLS(INDEX{k}(m)).Centroid(1,:)) <= 5
                
                temp.LABEL = [CELLS(k).LABEL;CELLS(INDEX{k}(m)).LABEL];
                temp.Centroid = [CELLS(k).Centroid;[NaN,NaN];...
                    CELLS(INDEX{k}(m)).Centroid];
                temp.NucleusIdxPixel = {};
                temp.MeanRedFluo = [CELLS(k).MeanRedFluo,...
                    mean([CELLS(k).MeanRedFluo(end),...
                    CELLS(INDEX{k}(m)).MeanRedFluo(1)]),...
                    CELLS(INDEX{k}(m)).MeanRedFluo];
                temp.Area = [CELLS(k).Area,mean([CELLS(k).Area(end),...
                    CELLS(INDEX{k}(m)).Area(1)]),CELLS(INDEX{k}(m)).Area];
                temp.MajorAxis = [CELLS(k).MajorAxis,NaN,...
                    CELLS(INDEX{k}(m)).MajorAxis];
                temp.MinorAxis = [CELLS(k).MinorAxis,NaN,...
                    CELLS(INDEX{k}(m)).MinorAxis];
                temp.Orientation = [CELLS(k).Orientation,NaN,...
                    CELLS(INDEX{k}(m)).Orientation];
                temp.MaxGreenFluo = [CELLS(k).MaxGreenFluo,...
                    mean([CELLS(k).MaxGreenFluo(end),...
                    CELLS(INDEX{k}(m)).MaxGreenFluo(1)]),...
                    CELLS(INDEX{k}(m)).MaxGreenFluo];
                temp.BoundingBox = [CELLS(k).BoundingBox;...
                    [NaN,NaN,NaN,NaN];CELLS(INDEX{k}(m)).BoundingBox];
                temp.RelativeNucleus = [CELLS(k).RelativeNucleus;...
                    [NaN,NaN];CELLS(INDEX{k}(m)).RelativeNucleus];
                temp.Mask = {};
                temp.frame = [CELLS(k).frame,CELLS(k).frame(end)+1,...
                    CELLS(INDEX{k}(m)).frame];
                temp.parentLABEL = [];
                temp.ROOT = [];
                temp.LINEAGE = [];
                
                CELLS_Recovered = [CELLS_Recovered,temp];
                if k <= length(Cells)
                    toDELETE_Forward = [toDELETE_Forward,k];
                else
                    toDELETE_Reverse = [toDELETE_Reverse,(k-length(Cells))];
                end
                
                if INDEX{k}(m) <= length(Cells)
                    toDELETE_Forward = [toDELETE_Forward,INDEX{k}(m)];
                else
                    toDELETE_Reverse = [toDELETE_Reverse,...
                        (INDEX{k}(m)-length(Cells))];
                end
            end
        end
    end
    
    Cells(toDELETE_Forward) = [];
    Cells_Reverse(toDELETE_Reverse) = [];
    
    Cells = [Cells,CELLS_Recovered];
    
    clear x ind INDEX StartFrame EndFrame CELLS
    
    if isempty(toDELETE_Forward) && isempty(toDELETE_Reverse)
        TwoFrame = true;
    end
end

end