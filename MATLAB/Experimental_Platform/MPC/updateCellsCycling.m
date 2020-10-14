%% updateCellsCycling.m
%%% OCTOBER 14, 2020

function [trackedOBJS, removedOBJS, idN] = updateCellsCycling(M1, ...
    trackedOBJS, removedOBJS, newOBJs, idN, FRAME)

    MAX_MOTHER_DAUGHTER_DISPACEMENT = 36;
    MAX_CIRCLE_DISPLACEMENT = 50;
    N1 = size(M1,1);
    updatedINDEXES = [];
    toREADD = [];

    for k = 1:N1

        INDEX = find(M1(k,:) > 0);
        if length(INDEX) == 1

            Z = INDEX(1);
            
            POS = size(trackedOBJS(k).Centroid,1)+1;
            
            trackedOBJS(k).Centroid(POS,:) = newOBJs(Z).Centroid;
            trackedOBJS(k).NucleusIdxPixel{POS} = newOBJs(Z).NucleusIdxPixel;
            trackedOBJS(k).MeanRedFluo(POS) = newOBJs(Z).MeanRedFluo;
            trackedOBJS(k).frame(POS) = FRAME;
            trackedOBJS(k).Area(POS) = NaN;
            trackedOBJS(k).MajorAxis(POS) = NaN;
            trackedOBJS(k).MinorAxis(POS) = NaN;
            trackedOBJS(k).Orientation(POS) = NaN;
            trackedOBJS(k).MaxGreenFluo(POS) = NaN;
            trackedOBJS(k).BoundingBox(POS,:) = NaN*ones(1,4);
            trackedOBJs(k).RelativeNucleus(POS,:) = NaN*ones(1,2);
            trackedOBJS(k).Mask{POS} = [];
            
            updatedINDEXES(end+1) = k;


        elseif length(INDEX) > 1

            NORMS = [];

            for h = 1:length(INDEX)
                NORMS(h) = norm(trackedOBJS(k).Centroid(end,:) - ...
                    newOBJs(INDEX(h)).Centroid);
            end

            [~,IDS] = sort(NORMS);
            sortedINDEXES = INDEX(IDS);

            POS = size(trackedOBJS(k).Centroid,1)+1;
            
            trackedOBJS(k).Centroid(POS,:) = ...
                newOBJs(sortedINDEXES(1)).Centroid;
            trackedOBJS(k).NucleusIdxPixel{POS} = ...
                ewOBJs(sortedINDEXES(1)).NucleusIdxPixel;
            trackedOBJS(k).MeanRedFluo(POS) = ...
                newOBJs(sortedINDEXES(1)).MeanRedFluo;
            trackedOBJS(k).frame(POS) = FRAME;
            trackedOBJS(k).Area(POS) = NaN;
            trackedOBJS(k).MajorAxis(POS) = NaN;
            trackedOBJS(k).MinorAxis(POS) = NaN;
            trackedOBJS(k).Orientation(POS) = NaN;
            trackedOBJS(k).MaxGreenFluo(POS) = NaN;
            trackedOBJS(k).BoundingBox(POS,:) = NaN*ones(1,4);
            trackedOBJs(k).RelativeNucleus(POS,:) = NaN*ones(1,2);
            trackedOBJS(k).Mask{POS} = [];
            
            updatedINDEXES(end+1) = k;
            
            for D = 2:length(sortedINDEXES)
                
                S = length(trackedOBJS);
                POS = 1;
                
                if POS == 1
                
                    lOBJs.LABEL = idN;
                    idN = idN+1;

                    lOBJs.Centroid = newOBJs(sortedINDEXES(D)).Centroid;
                    lOBJs.NucleusIdxPixel{1} = ...
                        newOBJs(sortedINDEXES(D)).NucleusIdxPixel;
                    lOBJs.MeanRedFluo = ...
                        newOBJs(sortedINDEXES(D)).MeanRedFluo;
                    lOBJs.Area = NaN;
                    lOBJs.MajorAxis = NaN;
                    lOBJs.MinorAxis = NaN;
                    lOBJs.Orientation = NaN;
                    lOBJs.MaxGreenFluo = NaN;
                    lOBJs.BoundingBox = [];
                    lOBJs.RelativeNucleus = [];
                    lOBJs.Mask{1} = [];

                    lOBJs.frame = FRAME;

                    lOBJs.parentLABEL = 0;
                    lOBJs.ROOT = lOBJs.LABEL;
                    lOBJs.LINEAGE = lOBJs.parentLABEL;

                    trackedOBJS(S+1) = lOBJs;

                    if norm([trackedOBJS(k).Centroid(end,1) ...
                            trackedOBJS(k).Centroid(end,2)] - ...
                            [trackedOBJS(S+1).Centroid(end,1) ...
                            trackedOBJS(S+1).Centroid(end,2)]) < ...
                            MAX_MOTHER_DAUGHTER_DISPACEMENT

                        trackedOBJS(S+1).parentLABEL = ...
                            trackedOBJS(k).LABEL;
                        trackedOBJS(S+1).ROOT = trackedOBJS(k).ROOT;
                        trackedOBJS(S+1).LINEAGE = ...
                            [trackedOBJS(k).LINEAGE, trackedOBJS(k).LABEL];

                    end

                    updatedINDEXES(end+1) = S+1;

                end
                
            end

        end

    end

    if ~isempty(toREADD)
        removedOBJS(toREADD)=[];
    end
    
    toREMOVE = [];

    for h = 1:length(trackedOBJS)

        if isempty(find(updatedINDEXES==h,1))

            toREMOVE = [toREMOVE h];

        end

    end


    for h = 1:length(toREMOVE)

        removedOBJS = [removedOBJS trackedOBJS(toREMOVE(h))];

    end


    trackedOBJS(toREMOVE) = [];


end