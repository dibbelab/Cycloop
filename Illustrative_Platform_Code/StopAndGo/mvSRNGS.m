%% mvSRNGS.m
%%% OCTOBER 14, 2020

function isON = mvSRNGS(INP, smplngTM, isON)

tMX = 60*smplngTM;

TON = floor(INP*tMX);

if TON == 0
    
    if isON
        
        [~, isON] = indOFF;
        
    end
    
elseif TON > 0 && TON < tMX
    
    
    if isON
        
        pause(TON)
        
    else
        
        [TIME, isON] = indON;
        
        pause(TON-TIME)
        
    end
    
    
    if isON
        
        [~, isON] = indOFF;
        
    end
    
    
elseif TON == tMX
    
    
    if ~isON
        
        [~, isON] = indON;
        
    end
   
    
end