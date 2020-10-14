%% readIMG.m
%%% OCTOBER 14, 2020

bf=strcat(pathNAME,'t',num2str(ITR,'%.6d'),bfsub);
green=strcat(pathNAME,'t',num2str(ITR,'%.6d'),greensub);
red=strcat(pathNAME,'t',num2str(ITR,'%.6d'),redsub);

while true
    
    if exist(bf, 'file') == 2
        
        try
            
            Bf_Img = imread(bf);
            
            break
            
        catch
            
            pause(1)
            
        end
        
    end
    
end

while true
    
    if exist(green, 'file') == 2
        
        try
            
            Green_Img = imread(green);
            
            break
            
        catch
            
            pause(1)
            
        end
        
    end
    
end

while true
    
    if exist(red, 'file') == 2
        
        try
            
            Red_Img = imread(red);
            
            break
            
        catch
            
            pause(1)
            
        end
        
    end
    
end