%% 

function Cells_Reverse = Reverse_Segmentation(Im_Path,cropRECT,dimITR)
    
    bfsub = 'c1.tif';
    greensub = 'c2.tif';
    redsub = 'c3.tif';
    
    idN = 1;
    
    for ITR = dimITR:-1:1
        disp(['ITR:' num2str(ITR) '/' num2str(dimITR)])

        bf=strcat(Im_Path,'t',num2str(ITR,'%.6d'),bfsub);
        green=strcat(Im_Path,'t',num2str(ITR,'%.6d'),greensub);
        red=strcat(Im_Path,'t',num2str(ITR,'%.6d'),redsub);

        Bf_Img = imread(bf);
        Green_Img = imread(green);
        Red_Img = imread(red);

        if ITR == dimITR
            [trackedCELLS, removedCELLS, idN] = trackingYeastNonCycling(Bf_Img, Green_Img, Red_Img, ITR, cropRECT, idN, dimITR);
        else
            [trackedCELLS, removedCELLS, idN] = trackingYeastNonCycling(Bf_Img, Green_Img, Red_Img, ITR, cropRECT, idN, dimITR, trackedCELLS, removedCELLS);
        end

    end
    
    Cells_Reverse = [trackedCELLS,removedCELLS];
    
end