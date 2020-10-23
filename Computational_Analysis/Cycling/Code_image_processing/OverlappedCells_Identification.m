%% OverlappedCells_Identification.m
%%% OCTOBER 15, 2020

function [Cells,Cells_Reverse] = OverlappedCells_Identification(Cells, ...
    Cells_Reverse)
    
dimEXP = 500;

for frameOverlap = 1:dimEXP-1
    Overlap = false;
    
    while ~Overlap
        toDELETE_Forward = []; toDELETE_Reverse = [];
        CELLS_Recovered = [];
        
        CELLS = [Cells,Cells_Reverse];
        
        for x = 1:length(CELLS)
            StartFrame(x) = CELLS(x).frame(1);
            EndFrame(x) = CELLS(x).frame(end);
        end
        
        for i = 1:length(EndFrame)
            ind = find(StartFrame == EndFrame(i)-frameOverlap+1);
            INDEX{i} = ind;
        end
        
        for k = 1:length(INDEX)
            for m = 1:length(INDEX{k})
                if length(CELLS(INDEX{k}(m)).frame) > frameOverlap && ...
                        length(CELLS(k).frame) > frameOverlap-1
                    if k ~= INDEX{k}(m) && norm(CELLS(k).Centroid(end-...
                            frameOverlap+1:end,:)-CELLS(INDEX{k}(m)).Centroid(1:frameOverlap,:)) <= 1
                        
                        temp.LABEL = [CELLS(k).LABEL;...
                            CELLS(INDEX{k}(m)).LABEL];
                        temp.Centroid = [CELLS(k).Centroid;...
                            CELLS(INDEX{k}(m)).Centroid(frameOverlap+1:end,:)];
                        temp.NucleusIdxPixel = {};
                        temp.MeanRedFluo = [CELLS(k).MeanRedFluo,...
                            CELLS(INDEX{k}(m)).MeanRedFluo(frameOverlap+1:end)];
                        temp.Area = [CELLS(k).Area,...
                            CELLS(INDEX{k}(m)).Area(frameOverlap+1:end)];
                        temp.MajorAxis = [CELLS(k).MajorAxis,...
                            CELLS(INDEX{k}(m)).MajorAxis(frameOverlap+1:end)];
                        temp.MinorAxis = [CELLS(k).MinorAxis,...
                            CELLS(INDEX{k}(m)).MinorAxis(frameOverlap+1:end)];
                        temp.Orientation = [CELLS(k).Orientation,...
                            CELLS(INDEX{k}(m)).Orientation(frameOverlap+1:end)];
                        temp.MaxGreenFluo = [CELLS(k).MaxGreenFluo,...
                            CELLS(INDEX{k}(m)).MaxGreenFluo(frameOverlap+1:end)];
                        temp.BoundingBox = [CELLS(k).BoundingBox;...
                            CELLS(INDEX{k}(m)).BoundingBox(frameOverlap+1:end,:)];
                        temp.RelativeNucleus = [CELLS(k).RelativeNucleus;...
                            CELLS(INDEX{k}(m)).RelativeNucleus(frameOverlap+1:end,:)];
                        temp.Mask = {};
                        temp.frame = [CELLS(k).frame,...
                            CELLS(INDEX{k}(m)).frame(frameOverlap+1:end)];
                        temp.parentLABEL = [];
                        temp.ROOT = [];
                        temp.LINEAGE = [];
                        
                        CELLS_Recovered = [CELLS_Recovered,temp];
                        if k <= length(Cells)
                            toDELETE_Forward = [toDELETE_Forward,k];
                        else
                            toDELETE_Reverse = [toDELETE_Reverse,...
                                (k-length(Cells))];
                        end
                        
                        if INDEX{k}(m) <= length(Cells)
                            toDELETE_Forward = [toDELETE_Forward,...
                                INDEX{k}(m)];
                        else
                            toDELETE_Reverse = [toDELETE_Reverse,...
                                (INDEX{k}(m)-length(Cells))];
                        end
                    end
                end
            end
        end
        
        Cells(toDELETE_Forward) = [];
        Cells_Reverse(toDELETE_Reverse) = [];
        
        Cells = [Cells,CELLS_Recovered];
        
        clear x ind INDEX StartFrame EndFrame CELLS
        
        if isempty(toDELETE_Forward) && isempty(toDELETE_Reverse)
            Overlap = true;
        end
    end
end

end