%% phaseestRealTime.m
%%% OCTOBER 14, 2020

function [phi,trackedCELLS] = phaseestRealTime(trackedCELLS,tau,ITR)
    w = 2*pi/80; % Angular volocity of cell cycle
    t = (0:2:80)'; % tTime of reference signal

    ref = [zeros(tau,1);(1-cos(w*t))./2]; % Reference signal for correlation
    
    phi = NaN(1,length(trackedCELLS)); % TrackedCELLS is the output of my segmentation
    % it is an array of struct. In each column there is a cell and all the
    % information about that cell is collected in the struct
                                        
    fluo = NaN(ITR-1,length(trackedCELLS)); 
    
    for z = 1:length(trackedCELLS)
        fluo((trackedCELLS(z).frame),z) = trackedCELLS(z).MeanGreenFluo; % Fluorescence
        
        XC = [];
        
        if trackedCELLS(z).frame(end)-tau+1 >= trackedCELLS(z).frame(1)
            XC = fluo(end-tau+1:end,z); % Correlation window
            r = [];
        
            for q = 1:length(ref)-tau+1
                r = [r;corr(XC,ref(q:q+tau-1))];
            end

            [~,ind] = max(r); % Maximum correlation

            % Cell cycle phase in radians
            if ind == 1
                phi(1,z) = 0;
            else
                phi(1,z) = w*t(ind-1);
            end

            clear XC ind
        end
        trackedCELLS(z).Phase(end) = phi(1,z);
    end
end