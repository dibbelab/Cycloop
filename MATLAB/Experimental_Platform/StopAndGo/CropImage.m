%% CropImage.m
%%% OCTOBER 14, 2020

function CropRect=CropImage(file)

Im=imread(file);
i=imadjust(Im);
[Icrop,CropRect]=imcrop(i);
clear Im i Icrop;
    
end