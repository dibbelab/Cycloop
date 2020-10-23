%% CropImage.m
%%% OCTOBER 14, 2020

function CropRect=CropImage(imgNM)

disp('I am waiting a phase contrast image...')

while true
    
    if exist(imgNM, 'file')
        
        break
        
    end
    
    pause(1)
    
end

disp('Crop area')

Im=imread(imgNM);
i=imadjust(Im);
[Icrop,CropRect]=imcrop(i);

clear Im i Icrop;
    
end