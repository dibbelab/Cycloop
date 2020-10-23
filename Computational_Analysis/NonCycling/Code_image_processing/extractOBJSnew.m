%% trackingYEA.m
%%% APRIL 14, 2017
% GIANSIMONE

function OBJS = extractOBJS(trackedOBJS)

for q = 1:length(trackedOBJS)
        
    OBJS(q,1) = trackedOBJS(q).Centroid(end,1);
        
    OBJS(q,2) = trackedOBJS(q).Centroid(end,2);
    
end

end
