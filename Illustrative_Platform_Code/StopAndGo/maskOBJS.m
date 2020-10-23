%% maskOBJS.m
%%% OCTOBER 14, 2020

function [MASK, singleMASK] = maskOBJS(greenIMG, xyPOS, RADIUS)

if nargout < 2
    
    singleMASK = NaN;

    singleFLAG = false;

elseif nargout == 2
    
    singleFLAG = true;

end

imSIZE = size(greenIMG);

[XX,YY] = meshgrid(1:imSIZE(2),1:imSIZE(1));

greenIMG = imadjust(greenIMG);

falseMASK = false(imSIZE);

MASK = falseMASK;   

THETA = 0:(2*pi/30):(2*pi);

if singleFLAG

    singleMASK.PIXEL = [];

    for indexOBJ = 1:length(RADIUS)
        
        cellPIXEL = hypot(XX - xyPOS(indexOBJ,1), ...
            YY - xyPOS(indexOBJ,2)) <= RADIUS(indexOBJ);
	
        plineX = RADIUS(indexOBJ)*cos(THETA)+xyPOS(indexOBJ,1);
        
        plineY = RADIUS(indexOBJ)*sin(THETA)+xyPOS(indexOBJ,2);
    
        M = poly2mask(plineX, plineY, imSIZE(1), imSIZE(2));
     
        croppedIMG = imcrop(greenIMG, [xyPOS(indexOBJ,1)-RADIUS(indexOBJ) xyPOS(indexOBJ,2)-RADIUS(indexOBJ) 2*RADIUS(indexOBJ) 2*RADIUS(indexOBJ)]);   % croppo l'immagine attorno al cerchio (che ho reso una rect grazie alle due linee di codice di prima)
    
        croppedIMG = imadjust(croppedIMG);

        BW = im2bw(croppedIMG, graythresh(croppedIMG));
        
        L = bwlabel(BW, 4);
        
        S = regionprops(L, 'Area');
        
        [~, IND] = max(cat(1, S.Area));

        if ~isempty(IND)

            startX = round(xyPOS(indexOBJ,2)-RADIUS(indexOBJ));
        
            startY = round(xyPOS(indexOBJ,1)-RADIUS(indexOBJ));
        
            countX = size(BW,1);
        
            countY = size(BW,2);
           
            if startX<=0
                
                startX = 1;

            end
            
            if startY<=0
            
                startY = 1;
        
            end
            
            M(startX:startX+countX-1,startY:startY+countY-1) = M(...
                startX:startX+countX-1,startY:startY+countY-1) & BW;
      
            MASK = MASK | M | cellPIXEL;

            singleMASK(indexOBJ).PIXEL = falseMASK | M | cellPIXEL;
            
        else
            
            singleMASK(indexOBJ).PIXEL = falseMASK;

        end
    
    end

else
    
    for indexOBJ = 1:length(RADIUS)
        
        cellPIXEL = hypot(XX - xyPOS(indexOBJ,1), ...
            YY - xyPOS(indexOBJ,2)) <= RADIUS(indexOBJ);
        
        plineX = RADIUS(indexOBJ)*cos(THETA)+xyPOS(indexOBJ,1);
        
        plineY = RADIUS(indexOBJ)*sin(THETA)+xyPOS(indexOBJ,2);
    
        M = poly2mask(plineX, plineY, imSIZE(1), imSIZE(2));
     
        croppedIMG = imcrop(greenIMG, [xyPOS(indexOBJ,1)-RADIUS(indexOBJ) xyPOS(indexOBJ,2)-RADIUS(indexOBJ) 2*RADIUS(indexOBJ) 2*RADIUS(indexOBJ)]);
    
        croppedIMG = imadjust(croppedIMG);

        BW = im2bw(croppedIMG, graythresh(croppedIMG));
        
        L = bwlabel(BW, 4);

        S = regionprops(L, 'Area');
        
        [~, IND] = max(cat(1, S.Area));

        if ~isempty(IND)

            startX = round(xyPOS(indexOBJ,2)-RADIUS(indexOBJ));
        
            startY = round(xyPOS(indexOBJ,1)-RADIUS(indexOBJ));
        
            countX = size(BW,1);
        
            countY = size(BW,2);
           
            if startX<=0
                
                startX = 1;

            end
            
            if startY<=0
            
                startY = 1;
        
            end
            
            M(startX:startX+countX-1,startY:startY+countY-1) = ...
                M(startX:startX+countX-1,startY:startY+countY-1) & BW;
      
            MASK = MASK | M | cellPIXEL;
     
        end
        
    end

end

end