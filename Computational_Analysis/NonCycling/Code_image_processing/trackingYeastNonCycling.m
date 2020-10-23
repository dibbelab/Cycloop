%% trackingYEAST.m
% Sara Napolitano
% 20/7/2018

function [trackedOBJS, removedOBJS, idN] =  trackingYeastNonCycling(brightIMG, greenIMG, redIMG, imINDEX, cropRECT, idN, dimITR, trackedOBJS, removedOBJS)

    warning off

    if nargin == 7
        removedOBJS  = [];
    end
    
    brightIMG = imcrop(brightIMG, cropRECT);
    brightIMG = imadjust(brightIMG);
    H = fspecial('gaussian', [5,5], 0.7);
    brightIMG = imfilter(brightIMG, H);
    
    greenIMG = imcrop(greenIMG, cropRECT);
    background = imopen(greenIMG,strel('disk',10));
    greenIMG = imsubtract(greenIMG,background);
    
    redIMG = imcrop(redIMG, cropRECT);
    background = imopen(redIMG,strel('disk',5));
    redIMG = imsubtract(redIMG,background);
    
    newOBJs = CellNuclei(redIMG);
    
    if imINDEX < dimITR
        
        OLDCentroids = extractOBJSnew(trackedOBJS);
        NEWCentroids = extractOBJSnew(newOBJs);
        
        [M1, STATUS1] = solveLP(OLDCentroids,NEWCentroids); 
        
        if STATUS1 == 1
            
            [trackedOBJS, removedOBJS, idN] = updateCellsNonCycling(M1,trackedOBJS,removedOBJS,newOBJs,idN,imINDEX);
            trackedOBJS = computeCellsNonCycling(brightIMG,greenIMG,trackedOBJS);
            
        end
        
    else
        
        if isempty(newOBJs)
            
            return
            
        end
        
        for k = 1:length(newOBJs)
            
            lOBJs.LABEL = idN;
            idN = idN + 1;
            
            lOBJs.Centroid = newOBJs(k).Centroid;
            lOBJs.NucleusIdxPixel{1} = newOBJs(k).NucleusIdxPixel;
            lOBJs.MeanRedFluo = newOBJs(k).MeanRedFluo;
            lOBJs.Area = NaN;    %newOBJs(k).Area;
            lOBJs.MajorAxis = NaN;   %newOBJs(k).MajorAxis;
            lOBJs.MinorAxis = NaN;   %newOBJs(k).MinorAxis;
            lOBJs.Orientation = NaN; %newOBJs(k).Orientation;
            lOBJs.MeanGreenFluo = NaN;   %newOBJs(k).MeanGreenFluo;
            lOBJs.BoundingBox = []; %newOBJs(k).IdxPixel;
            lOBJs.RelativeNucleus = [];
            lOBJs.Mask{1} = [];    %newOBJs(k).Pixel;
            
            lOBJs.frame = imINDEX;
            
            lOBJs.parentLABEL = 0;
            lOBJs.ROOT = lOBJs.LABEL;
            lOBJs.LINEAGE = lOBJs.parentLABEL;
            
            trackedOBJS(k) = lOBJs;
            
        end
        
        trackedOBJS = computeCellsNonCycling(brightIMG, greenIMG, trackedOBJS);  %, redIMG);
        
    end
    
end