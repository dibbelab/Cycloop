%% 

function [Cells,Cells_Reverse] = NoFrameLost_Identification(Cells,Cells_Reverse)
    
    dimEXP = 500; OneFrame = false; 

    while ~OneFrame
        toDELETE_Forward = []; toDELETE_Reverse = [];
        CELLS_Recovered = [];

        CELLS = [Cells,Cells_Reverse];

        for x = 1:length(CELLS)
            StartFrame(x) = CELLS(x).frame(1);
            EndFrame(x) = CELLS(x).frame(end);
        end

        for i = 1:length(EndFrame)
            ind = find(StartFrame == EndFrame(i)+1);
            INDEX{i} = ind;
        end

        for k = 1:length(INDEX)
            for m = 1:length(INDEX{k})
                if k ~= INDEX{k}(m) && norm(CELLS(k).Centroid(end,:)-CELLS(INDEX{k}(m)).Centroid(1,:)) <= 5     % && length(CELLS(INDEX{k}(m)).Area) > 1

                    temp.LABEL = [CELLS(k).LABEL;CELLS(INDEX{k}(m)).LABEL];
                    temp.Centroid = [CELLS(k).Centroid;CELLS(INDEX{k}(m)).Centroid];
                    temp.NucleusIdxPixel = {};  %[CELLS(k).NucleusIdxPixel;CELLS(INDEX{k}(m)).NucleusIdxPixel];
                    temp.MeanRedFluo = [CELLS(k).MeanRedFluo,CELLS(INDEX{k}(m)).MeanRedFluo];
                    temp.Area = [CELLS(k).Area,CELLS(INDEX{k}(m)).Area];
                    temp.MajorAxis = [CELLS(k).MajorAxis,CELLS(INDEX{k}(m)).MajorAxis];
                    temp.MinorAxis = [CELLS(k).MinorAxis,CELLS(INDEX{k}(m)).MinorAxis];
                    temp.Orientation = [CELLS(k).Orientation,CELLS(INDEX{k}(m)).Orientation];
                    temp.MeanGreenFluo = [CELLS(k).MeanGreenFluo,CELLS(INDEX{k}(m)).MeanGreenFluo];
    %                 temp.MaxGreenFluo = [CELLS(k).MaxGreenFluo,CELLS(INDEX{k}(m)).MaxGreenFluo];
                    temp.BoundingBox = [CELLS(k).BoundingBox;CELLS(INDEX{k}(m)).BoundingBox];
                    temp.RelativeNucleus = [CELLS(k).RelativeNucleus;CELLS(INDEX{k}(m)).RelativeNucleus];
                    temp.Mask = {}; %[CELLS(k).Mask;CELLS(INDEX{k}(m)).Mask];
                    temp.frame = [CELLS(k).frame,CELLS(INDEX{k}(m)).frame];
                    temp.Phase = [];
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
                        toDELETE_Reverse = [toDELETE_Reverse,(INDEX{k}(m)-length(Cells))];
                    end
                end
            end
        end

        Cells(toDELETE_Forward) = [];
        Cells_Reverse(toDELETE_Reverse) = [];

        Cells = [Cells,CELLS_Recovered];

        clear x ind INDEX StartFrame EndFrame CELLS

        if isempty(toDELETE_Forward) && isempty(toDELETE_Reverse)
            OneFrame = true;
        end
    end
    
end