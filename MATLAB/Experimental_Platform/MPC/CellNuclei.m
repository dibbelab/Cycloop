%% CellNuclei.m
%%% OCTOBER 14, 2020

function [OBJs] = CellNuclei(redIMG)

    MIN_FLUO = 45;

    OBJs = [];
    toREMOVE = [];
    
    [xyPOS, RADIUS] = findNUCLEI(redIMG);
    
    [MASK, ~] = maskOBJS(redIMG, xyPOS, RADIUS);
    stats = regionprops(MASK,redIMG,'Centroid','PixelIdxList',...
        'MeanIntensity');
    

    for i = 1:length(stats)
        OBJs(i).Centroid = stats(i).Centroid;
        OBJs(i).NucleusIdxPixel = stats(i).PixelIdxList;
        OBJs(i).MeanRedFluo = stats(i).MeanIntensity;
    end
    
    for i = 1:length(OBJs)
        if OBJs(i).MeanRedFluo < MIN_FLUO
            toREMOVE = [toREMOVE;i];
        end
    end
    
    OBJs(toREMOVE) = [];
    
end