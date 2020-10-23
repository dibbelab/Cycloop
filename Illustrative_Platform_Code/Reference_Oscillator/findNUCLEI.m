%% findNUCLEI.m
%%% OCTOBER 14, 2020

function [xyPOS,RADIUS] = findNUCLEI(redIMG)

    MEAN_NUCLEI_AREA = 20;
    MIN_CIRCLE_DISPLACEMENT = 6;
    xyPOS = [];
    RADIUS = [];

    
    BW = imbinarize(redIMG,'adaptive','Sensitivity',0.01);
    
    bw = bwareaopen(BW,MEAN_NUCLEI_AREA);
    
    [C, R] = imfindcircles(bw, [1 5], 'OBJectPolarity', 'bright', ...
        'Method', 'TwoStage');

    for q = 1:length(R)

        X = C(q,1);

        Y = C(q,2);

        toADD = true;

        for h = 1:length(RADIUS)

            if norm(xyPOS(h,:)-[X Y]) < MIN_CIRCLE_DISPLACEMENT

                toADD = false;

            end

        end

        if toADD

            xyPOS = [xyPOS; [X Y]];

            RADIUS = [RADIUS; R(q)];

        end

    end
    
end