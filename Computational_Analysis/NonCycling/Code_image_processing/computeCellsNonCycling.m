% Sara Napolitano
% 20/7/2018

function [trackedOBJs] = computeCellsNonCycling(brightIMG, greenIMG, trackedOBJs)  %, redIMG)
    
    X = []; Y = [];

    for i = 1:length(trackedOBJs)
        X = [X;trackedOBJs(i).Centroid(end,1)];
        Y = [Y;trackedOBJs(i).Centroid(end,2)];
    end

    mask = voronoi2mask(X,Y,size(brightIMG));
    clear X Y
    
    for k = 1:length(trackedOBJs)
        
        POS = length(trackedOBJs(k).Area);
        xyPOS = []; RADIUS = [];

        BW = false(size(brightIMG));
        BW(mask==k) = 1;
        
        MASKnuclei = false(size(brightIMG));
        MASKnuclei(trackedOBJs(k).NucleusIdxPixel{end}) = 1;
        
        L = regionprops(BW,'boundingbox','area');
    
        if ~isempty(L)
            BB = ceil(L(1).BoundingBox);
            rect = [BB(1)-BB(3) BB(2)-BB(4) 3*BB(3) 3*BB(4)];

            if BB(1)-BB(3) <= 0
                rect(1) = BB(1);
            end
            if BB(2)-BB(4) <= 0
                rect(2) = BB(2);
            end
            if BB(1)+2*BB(3) > size(BW,1)
                rect(3) = 2*BB(3);
            end
            if BB(2)+2*BB(4) > size(BW,2)
                rect(4) = 2*BB(4);
            end

            tempIMG = imcrop(brightIMG,rect);   %cropping the filtered image
            tempGREEN = imcrop(greenIMG,rect);
            tempNUCLEI = imcrop(MASKnuclei,rect);
            
            clear BB rect

            h = fspecial('gaussian',3,.5);
            tempIMG = imfilter(tempIMG,h);  % filtering the cropped image with the gaussian filter.
            tempBW = ~niblack(tempIMG, [10 10]);    %15
            tempBW = imfill(tempBW,'holes');
            
            clear h tempIMG

            D = bwdist(~tempBW);
            D = -D;
            D(~tempBW) = Inf;

            tempL = watershed(D);
            tempL(~tempBW) = 0;
            finalBW = tempL;
            
            clear D tempBW tempL

            statsBW = regionprops(finalBW,tempGREEN,'Centroid','Area','MajorAxisLength','MinorAxisLength','Orientation','BoundingBox','MeanIntensity','Image','PixelIdxList');  %,'MaxIntensity','MinIntensity'

            statsNucleus = regionprops(tempNUCLEI,'Centroid');

            for j = 1:length(statsBW)
                temp = imcrop(tempNUCLEI,statsBW(j).BoundingBox);
                nuc = regionprops(temp,'Centroid');
                clear temp
                
                if ~isempty(nuc)
                    tempOBJs = [];
        
                    if norm(statsBW(j).Centroid-statsNucleus.Centroid) <= statsBW(j).MajorAxisLength/2
%                     if norm(statsBW(j).Centroid-statsNucleus(1).Centroid) <= statsBW(j).MajorAxisLength/2
                        tempOBJs = [tempOBJs;statsBW(j)];
                        
                        if length(tempOBJs)==1
                            
                            trackedOBJs(k).Area(POS) = tempOBJs.Area;
                            trackedOBJs(k).MajorAxis(POS) = tempOBJs.MajorAxisLength;
                            trackedOBJs(k).MinorAxis(POS) = tempOBJs.MinorAxisLength;
                            trackedOBJs(k).Orientation(POS) = tempOBJs.Orientation;
                            trackedOBJs(k).MeanGreenFluo(POS) = tempOBJs.MeanIntensity;  %Mean
%                             trackedOBJs(k).MaxGreenFluo(POS) = tempOBJs.MaxIntensity;
%                             trackedOBJs(k).MinGreenFluo(POS) = tempOBJs.MinIntensity;
                            trackedOBJs(k).BoundingBox(POS,:) = tempOBJs.BoundingBox;
                            trackedOBJs(k).RelativeNucleus(POS,:) = nuc.Centroid;
                            trackedOBJs(k).Mask{POS} = tempOBJs.Image;
                            
                        elseif length(tempOBJs)==2
                            
                            tempMASK = false(size(tempIMG));
                            
                            for l = 1:length(tempOBJs(1).PixelIdxList)
                                for m = 1:length(tempOBJs(2).PixelIdxList)
                                    dis(l,m) = norm(tempOBJs(1).PixelList(l,:) - tempOBJs(2).PixelList(m,:));
                                end
                            end
                            
                            [row,col] = find(dis==2);
                            
                            tempMASK(tempOBJs(1).PixelIdxList) = 1;
                            tempMASK(tempOBJs(2).PixelIdxList) = 1;
                            tempMASK((tempOBJs(1).PixelList(row,2)+tempOBJs(2).PixelList(col,2))./2,(tempOBJs(1).PixelList(row,1)+tempOBJs(2).PixelList(col,1))./2) = 1;
                        
                            tempstats = regionprops(tempMASK,tempGREEN,'Area','MajorAxisLength','MinorAxisLength','Orientation','BoundingBox','MeanIntensity','Image'); %'MaxIntensity','MinIntensity',
                            temp = imcrop(tempNUCLEI,tempstats(j).BoundingBox);
                            nucpos = regionprops(temp,'Centroid');
                            
                            clear temp
                            
                            trackedOBJs(k).Area(POS) = tempstats.Area;
                            trackedOBJs(k).MajorAxis(POS) = tempstats.MajorAxisLength;
                            trackedOBJs(k).MinorAxis(POS) = tempstats.MinorAxisLength;
                            trackedOBJs(k).Orientation(POS) = tempstats.Orientation;
                            trackedOBJs(k).MeanGreenFluo(POS) = tempstats.MeanIntensity; % Mean
%                             trackedOBJs(k).MaxGreenFluo(POS) = tempstats.MaxIntensity;
%                             trackedOBJs(k).MinGreenFluo(POS) = tempstats.MinIntensity;
                            trackedOBJs(k).BoundingBox(POS,:) = tempstats.BoundingBox;
                            trackedOBJs(k).RelativeNucleus(POS,:) = nucpos.Centroid;
                            trackedOBJs(k).Mask{end} = tempstats.Image;
                        
                            clear tempstats tempMASK
                        end    
                    end
                    clear tempOBJs
                end
                clear nuc
            end
            clear statsBW
        end

        % if the segmentation did not work:
        if isnan(trackedOBJs(k).Area(end))  
            
            if length(trackedOBJs(k).Area) >= 2
                tempBW = trackedOBJs(k).Mask{POS-1};

                BB = trackedOBJs(k).BoundingBox(POS-1,:);
                Xdist = trackedOBJs(k).RelativeNucleus(POS-1,1);
                Ydist = trackedOBJs(k).RelativeNucleus(POS-1,2);
                rect = [abs(trackedOBJs(k).Centroid(POS,1)-Xdist),abs(trackedOBJs(k).Centroid(POS,2)-Ydist),BB(3)-1,BB(4)-1];
                
                if rect(1)<0.5
                    rect(3) = rect(3)+1;
                end
            
                if rect(2)<0.5
                    rect(4) = rect(4)+1;
                end
            
                clear BB Xdist Ydist

                tempGREEN = imcrop(greenIMG,rect);

                if size(tempGREEN,1) < size(tempBW,1)
                    if rect(2) <= size(tempGREEN,1)-size(tempBW,1)
                        tempBW = tempBW(size(tempGREEN,1)-size(tempBW,1):end,:);
                    else
                        tempBW = tempBW(1:size(tempGREEN,1),:);
                    end
                end

                if size(tempGREEN,2) < size(tempBW,2)
                    if rect(1) <= size(tempGREEN,2)-size(tempBW,2)
                        tempBW = tempBW(:,size(tempGREEN,2)-size(tempBW,2):end);                     
                    else
                        tempBW = tempBW(:,1:size(tempGREEN,2));
                    end
                end
                            
                if size(tempBW,1) < size(tempGREEN,1)
                    if rect(2) <= size(tempBW,1)-size(tempGREEN,1)
                        tempGREEN = tempGREEN(size(tempBW,1)-size(tempGREEN,1):end,:);
                    else
                        tempGREEN = tempGREEN(1:size(tempBW,1),:);
                    end
                end

                if size(tempBW,2) < size(tempGREEN,2)
                    if rect(1) <= size(tempBW,2)-size(tempGREEN,2)
                        tempGREEN = tempGREEN(:,size(tempBW,2)-size(tempGREEN,2):end);                     
                    else
                        tempGREEN = tempGREEN(:,1:size(tempBW,2));
                    end
                end



                statsBW = regionprops(tempBW,tempGREEN,'Area','MajorAxisLength','MinorAxisLength','Orientation','BoundingBox','MeanIntensity','Image'); %,'MaxIntensity','MinIntensity'

                if ~isempty(statsBW)
                    trackedOBJs(k).Area(POS) = statsBW.Area;
                    trackedOBJs(k).MajorAxis(POS) = statsBW.MajorAxisLength;
                    trackedOBJs(k).MinorAxis(POS) = statsBW.MinorAxisLength;
                    trackedOBJs(k).Orientation(POS) = statsBW.Orientation;
                    trackedOBJs(k).MeanGreenFluo(POS) = statsBW.MeanIntensity;   %Mean
    %                 trackedOBJs(k).MaxGreenFluo(POS) = statsBW.MaxIntensity;
    %                 trackedOBJs(k).MinGreenFluo(POS) = statsBW.MinIntensity;
                    trackedOBJs(k).BoundingBox(POS,:) = statsBW.BoundingBox;
                    trackedOBJs(k).RelativeNucleus(POS,:) = trackedOBJs(k).RelativeNucleus(POS-1,:);
                    trackedOBJs(k).Mask{POS} = statsBW.Image;
                end
            
            else
                MASK = maskOBJS(greenIMG, trackedOBJs(k).Centroid(POS,:), 3);
                statsBW = regionprops(MASK,greenIMG,'Area','MajorAxisLength','MinorAxisLength','Orientation','BoundingBox','MeanIntensity','Image');    %,'MaxIntensity','MinIntensity'
                
                trackedOBJs(k).Area(POS) = statsBW.Area;
                trackedOBJs(k).MajorAxis(POS) = statsBW.MajorAxisLength;
                trackedOBJs(k).MinorAxis(POS) = statsBW.MinorAxisLength;
                trackedOBJs(k).Orientation(POS) = statsBW.Orientation;
                trackedOBJs(k).MeanGreenFluo(POS) = statsBW.MeanIntensity;   %Mean
%                 trackedOBJs(k).MaxGreenFluo(POS) = statsBW.MaxIntensity;
%                 trackedOBJs(k).MinGreenFluo(POS) = statsBW.MinIntensity;
                trackedOBJs(k).BoundingBox(POS,:) = statsBW.BoundingBox;
                trackedOBJs(k).RelativeNucleus(POS,:) = trackedOBJs(k).Centroid(POS,:);
                trackedOBJs(k).Mask{POS} = statsBW.Image;
            end
            
        end
        
        
        if (length(trackedOBJs(k).Area)>=2) && ((trackedOBJs(k).Area(end)<trackedOBJs(k).Area(end-1)/1.5) || (trackedOBJs(k).Area(end)>trackedOBJs(k).Area(end-1)*1.5))
            
            tempBW = trackedOBJs(k).Mask{POS-1};

            BB = trackedOBJs(k).BoundingBox(POS-1,:);
            Xdist = trackedOBJs(k).RelativeNucleus(POS-1,1);
            Ydist = trackedOBJs(k).RelativeNucleus(POS-1,2);
            rect = [abs(trackedOBJs(k).Centroid(POS,1)-Xdist),abs(trackedOBJs(k).Centroid(POS,2)-Ydist),BB(3)-1,BB(4)-1];
            
            if rect(1)<0.5
                rect(3) = rect(3)+1;
            end
            
            if rect(2)<0.5
                rect(4) = rect(4)+1;
            end
            
            clear BB Xdist Ydist

            tempGREEN = imcrop(greenIMG,rect);
            
            if size(tempGREEN,1) < size(tempBW,1)
                if rect(2) <= size(tempGREEN,1)-size(tempBW,1)
                    tempBW = tempBW(size(tempGREEN,1)-size(tempBW,1):end,:);
                else
                    tempBW = tempBW(1:size(tempGREEN,1),:);
                end
            end
            
            if size(tempGREEN,2) < size(tempBW,2)
                if rect(1) <= size(tempGREEN,2)-size(tempBW,2)
                    tempBW = tempBW(:,size(tempGREEN,2)-size(tempBW,2):end);                     
                else
                    tempBW = tempBW(:,1:size(tempGREEN,2));
                end
            end
                    
            if size(tempBW,1) < size(tempGREEN,1)
                if rect(2) <= size(tempBW,1)-size(tempGREEN,1)
                    tempGREEN = tempGREEN(size(tempBW,1)-size(tempGREEN,1):end,:);
                else
                    tempGREEN = tempGREEN(1:size(tempBW,1),:);
                end
            end
            
            if size(tempBW,2) < size(tempGREEN,2)
                if rect(1) <= size(tempBW,2)-size(tempGREEN,2)
                    tempGREEN = tempGREEN(:,size(tempBW,2)-size(tempGREEN,2):end);                     
                else
                    tempGREEN = tempGREEN(:,1:size(tempBW,2));
                end
            end
            


            statsBW = regionprops(tempBW,tempGREEN,'Area','MajorAxisLength','MinorAxisLength','Orientation','BoundingBox','MeanIntensity','Image'); %'MaxIntensity','MinIntensity',

            if ~isempty(statsBW)
                trackedOBJs(k).Area(POS) = statsBW.Area;
                trackedOBJs(k).MajorAxis(POS) = statsBW.MajorAxisLength;
                trackedOBJs(k).MinorAxis(POS) = statsBW.MinorAxisLength;
                trackedOBJs(k).Orientation(POS) = statsBW.Orientation;
                trackedOBJs(k).MeanGreenFluo(POS) = statsBW.MeanIntensity;   %Mean
    %             trackedOBJs(k).MaxGreenFluo(POS) = statsBW.MaxIntensity;
    %             trackedOBJs(k).MinGreenFluo(POS) = statsBW.MinIntensity;
                trackedOBJs(k).BoundingBox(POS,:) = statsBW.BoundingBox;
                trackedOBJs(k).RelativeNucleus(POS,:) = trackedOBJs(k).RelativeNucleus(POS-1,:);
                trackedOBJs(k).Mask{POS} = statsBW.Image;
            end
            
        end
        
        clear stats

    end

end