%% 

function [Cells,Cells_Reverse] = SameCell_Identification(Cells,Cells_Reverse)
    
    dimEXP = 500; SameCell = false; LFor = length(Cells);
    
    while ~SameCell
        toDELETE_Reverse = [];

        CELLS = [Cells,Cells_Reverse];

        for x = 1:length(CELLS)
            StartFrame(x) = CELLS(x).frame(1);
            EndFrame(x) = CELLS(x).frame(end);
        end

        for i = 1:length(CELLS)
            ind = find(StartFrame == StartFrame(i));
            INDEX{i} = ind;
            clear ind
        end

        for k = 1:length(INDEX)
            for m = 1:length(INDEX{k})
                if k ~= INDEX{k}(m)
                    if length(CELLS(k).frame) == length(CELLS(INDEX{k}(m)).frame)
                        if norm(CELLS(INDEX{k}(m)).Centroid - CELLS(k).Centroid) <= 1
                            if k > LFor
                                toDELETE_Reverse = [toDELETE_Reverse,k - LFor];
                            end

                            if INDEX{k}(m) > LFor
                                toDELETE_Reverse = [toDELETE_Reverse,INDEX{k}(m) - LFor];
                            end
                        end
                    end
                end
            end
        end

        Cells_Reverse(toDELETE_Reverse) = [];

        clear x ind INDEX StartFrame EndFrame CELLS

        if isempty(toDELETE_Reverse)
            SameCell = true;
        end
    end
    
end