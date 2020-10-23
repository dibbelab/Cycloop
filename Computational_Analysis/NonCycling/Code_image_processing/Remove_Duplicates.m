%% 

function Cells = Remove_Duplicates(Cells)
    
    temp1 = Cells;
    Cells = [];
    L = [];

    for z = 1:length(temp1)
        L(z) = length(temp1(z).frame);
    end

    [~,index] = sort(L,'descend');
    Cells = temp1(index);

    clear temp1 L index

    Labels = [];

    for k = 1:length(Cells)
        L = Cells(k).LABEL;
        for m = 1:length(L)
            ind = find(Labels == L(m));
            if isempty(ind)
                Labels = [Labels;L(m)];
            end
            clear ind
        end
    end

    clear L k m

    for k = 1:length(Labels)
        INDEX = [];
        for c = 1:length(Cells)
            ind = find(Cells(c).LABEL == Labels(k));
            if ~isempty(ind)
                INDEX = [INDEX;c];
            end
        end
        Cells(INDEX(2:end)) = [];
    end
    
end