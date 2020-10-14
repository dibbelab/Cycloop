%% trackingYeastNonCycling.m
%%% OCTOBER 14, 2020

function [trackedOBJS, removedOBJS, idN] =  trackingYeastNonCycling(...
    brightIMG, greenIMG, redIMG, imINDEX, cropRECT, idN, trackedOBJS, ...
    removedOBJS)

    warning off

    if nargin == 6
        
        removedOBJS  = [];
        
    end
    
    brightIMG = imcrop(brightIMG, cropRECT);
    brightIMG = imadjust(brightIMG);
    H = fspecial('gaussian', [5,5], 0.7); % Gaussian filter
    brightIMG = imfilter(brightIMG, H); % Filtered phase contrast image
    
    % Remove the background
    greenIMG = imcrop(greenIMG, cropRECT);
    background = imopen(greenIMG,strel('disk',10));
    greenIMG = imsubtract(greenIMG,background);
    
    redIMG = imcrop(redIMG, cropRECT);
    background = imopen(redIMG,strel('disk',5));
    redIMG = imsubtract(redIMG,background);
    
    newOBJs = CellNuclei(redIMG);
    
    if imINDEX > 1
        
        OLDCentroids = extractOBJSnew(trackedOBJS);
        NEWCentroids = extractOBJSnew(newOBJs);
        
        [M1, STATUS1] = solveLP(OLDCentroids,NEWCentroids); 
        
        if STATUS1 == 1
            
            [trackedOBJS, removedOBJS, idN] = updateCellsNonCycling(M1,...
                trackedOBJS,removedOBJS,newOBJs,idN,imINDEX);
            trackedOBJS = computeCellsNonCycling(brightIMG,greenIMG,...
                trackedOBJS);
            
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
            lOBJs.Area = NaN;
            lOBJs.MajorAxis = NaN;
            lOBJs.MinorAxis = NaN;
            lOBJs.Orientation = NaN;
            lOBJs.MeanGreenFluo = NaN;
            lOBJs.BoundingBox = [];
            lOBJs.RelativeNucleus = [];
            lOBJs.Phase = NaN;
            lOBJs.Mask{1} = [];
            
            lOBJs.frame = imINDEX;
            
            lOBJs.parentLABEL = 0;
            lOBJs.ROOT = lOBJs.LABEL;
            lOBJs.LINEAGE = lOBJs.parentLABEL;
            
            trackedOBJS(k) = lOBJs;
            
        end
        
        trackedOBJS = computeCellsNonCycling(brightIMG, greenIMG, ...
            trackedOBJS);
        
    end
    
end