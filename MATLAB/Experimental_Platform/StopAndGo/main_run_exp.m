%% main_run_exp.m
%%% OCTOBER 14, 2020

clear all

close all

clc

%%
% -------------------------------------------------------------------------
% Script's inputs
% -------------------------------------------------------------------------
% pathNAME is a variable denoting where the microscope saves the images in real-time:
pathNAME = './Example_Path/';

% Assign a name for the experiment
expNAME = 'StopAndGo_Example';


% Define the channels acquired by the microscope
bfsub = 'c1.tif'; % Phase constrast
greensub = 'c2.tif'; % YFP
redsub = 'c3.tif'; % mCherry

%
dimEXP = 500; % Number of frames for the experiment
controlTime = 250; % Number of controlled frames for the experiment

% Image segmentation initialisation
idN = 1;

% Sampling time
smplngTM = 2; % Time units in min

% Actuation initialisation
isIND = false;

initTP = 15;    % Number of frames for the calibration (30 min)
inputTime = 15; % Minimum duration of -Met pulse (30 min)
InputCount = 0;

% Array of timestamps
time=zeros(1,dimEXP);

% Initialisation of the array containing the input variable
inputLEVELS = isIND*ones(1,dimEXP);

%%
% -------------------------------------------------------------------------
% Define the ROI
% -------------------------------------------------------------------------
image=strcat('t000001',bfsub);
cropRECT=CropImage(strcat(pathNAME,image));
close

%%
% -------------------------------------------------------------------------
% Calibration phase
% -------------------------------------------------------------------------
% The controller gives a -Met pulse for the first 30 min
inputLEVELS(1:inputTime) = 1;

for ITR = 1:initTP
    
    tic

    disp(['Iteration: ', num2str(ITR) '/' num2str(dimEXP)])

    readIMG
    
    isIND = mvSRNGS(inputLEVELS(ITR), smplngTM, isIND);
    
    %-----------------image analysis---------------
    if ITR==1
        [trackedCELLS, removedCELLS, idN] = trackingYeastNonCycling(...
            Bf_Img, Green_Img, Red_Img, ITR, cropRECT, idN);
    else
        [trackedCELLS, removedCELLS, idN] = trackingYeastNonCycling(...
            Bf_Img, Green_Img, Red_Img, ITR, cropRECT, idN, ...
            trackedCELLS, removedCELLS);
    end
    %-----------------------------------------------
    
    
    save([pathNAME 'output_data_', expNAME, '.mat'])
    
    time(ITR) = toc;

end

%%
% -------------------------------------------------------------------------
% Control phase
% -------------------------------------------------------------------------
for ITR = (initTP+1):controlTime+initTP
    
    tic
    
    disp(['Iteration: ', num2str(ITR) '/' num2str(dimEXP)])
    
    [phi,trackedCELLS] = phaseestRealTime(trackedCELLS,initTP,ITR);
    
    if inputLEVELS(ITR) == 0
        
        u = stopandgo(phi(end,:));
        
        if ITR+inputTime-1 <= dimEXP
            inputLEVELS(ITR:ITR+inputTime-1) = u.*ones(1,inputTime);
        else
            inputLEVELS(ITR:end) = u.*ones(1,dimEXP-ITR+1);
        end
        
    end
    
    isIND = mvSRNGS(inputLEVELS(ITR), smplngTM, isIND);
    
    readIMG
    
    %-----------------image analysis---------------
    if ITR == 1
        [trackedCELLS, removedCELLS, idN] = trackingYeastNonCycling(...
            Bf_Img, Green_Img, Red_Img, ITR, cropRECT, idN);
    else
        [trackedCELLS, removedCELLS, idN] = trackingYeastNonCycling(...
            Bf_Img, Green_Img, Red_Img, ITR, cropRECT, idN, ...
            trackedCELLS, removedCELLS);
    end
    %-----------------------------------------------

    save([pathNAME 'output_data_', expNAME, '.mat'])

    time(ITR) = toc;
    
end


%%
% -------------------------------------------------------------------------
% Uncontrolled phase
% -------------------------------------------------------------------------
inputLEVELS(ITR+1:end) = ones(1,dimEXP-ITR); % -Met 

for ITR = (controlTime+1):dimEXP
    
    tic
    
    disp(['Iteration: ', num2str(ITR) '/' num2str(dimEXP)])
    
    [phi,trackedCELLS] = phaseestRealTime(trackedCELLS,initTP,ITR);
    
    isIND = mvSRNGS(inputLEVELS(ITR), smplngTM, isIND);
    
    readIMG
    
    %-----------------image analysis---------------
    if ITR == 1
        [trackedCELLS, removedCELLS, idN] = trackingYeastNonCycling(...
            Bf_Img, Green_Img, Red_Img, ITR, cropRECT, idN);
    else
        [trackedCELLS, removedCELLS, idN] = trackingYeastNonCycling(...
            Bf_Img, Green_Img, Red_Img, ITR, cropRECT, idN, ...
            trackedCELLS, removedCELLS);
    end
    %-----------------------------------------------

    save([pathNAME 'output_data_', expNAME, '.mat'])

    time(ITR) = toc;
    
end

[phi,trackedCELLS] = phaseestRealTime(trackedCELLS,initTP,ITR);

save([pathNAME 'output_data_', expNAME, '.mat'])