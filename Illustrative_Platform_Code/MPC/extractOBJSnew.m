%% extractOBJSnew.m
%%% OCTOBER 14, 2020

function OBJS = extractOBJSnew(trackedOBJS)

for q = 1:length(trackedOBJS)
        
    OBJS(q,1) = trackedOBJS(q).Centroid(end,1);
        
    OBJS(q,2) = trackedOBJS(q).Centroid(end,2);
    
end

end
