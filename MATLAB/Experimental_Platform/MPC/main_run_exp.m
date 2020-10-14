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
expNAME = 'MPC_Example';


% Define the channels acquired by the microscope
bfsub = 'c1.tif'; % Phase constrast
greensub = 'c2.tif'; % YFP
redsub = 'c3.tif'; % mCherry

%
dimEXP = 500; % Number of frames for the experiment
controlTime = 300; % Number of controlled frames for the experiment


% Image segmentation initialisation
idN = 1;


% Sampling time
smplngTM = 2; % Time units in min


% Actuation initialisation
isIND = false;


% Initialisation of the array containing the input variable
inputLEVELS = isIND*ones(1,dimEXP);


% Control horizon
Ts=50; % Control horizon equals to 100 min


%% Define global variable PhaseMAT
global PhaseMAT

PhaseMAT = struct('trackedCELLS',{},'stimaf',{},'stimaw',{});


%% Define ROI
image=strcat('t000001',bfsub);
cropRECT=CropImage(strcat(pathNAME,image));
close


%% Set calibration phase duration
initTP = 50; % Number of frames for the calibration (100 min)

time=[];


%% Calibration phase
for ITR = 1:initTP
    
    tic

    disp(['Iteration: ', num2str(ITR) '/' num2str(dimEXP)])
    
    %-----------------image analysis---------------
    readIMG
    
    if ITR==1
        
        [trackedCELLS, removedCELLS, idN] = trackingYeastCycling(...
            Bf_Img, Green_Img, Red_Img, ITR, cropRECT, idN);
        
    else
        
        [trackedCELLS, removedCELLS, idN] = trackingYeastCycling(...
            Bf_Img, Green_Img, Red_Img, ITR, cropRECT, idN, ...
            trackedCELLS, removedCELLS);
        
    end
    %-----------------------------------------------
    
    save([pathNAME 'output_data_', expNAME, '.mat'])
    
    time=[time;toc];

end


%% Controlled phase
for ITR = (initTP+1):controlTime
    
    tic
    
    disp(['Iteration: ', num2str(ITR) '/' num2str(dimEXP)])
    
    if mod(ITR-initTP-1,Ts)==0
        
        u = ctrlMPC(ITR,trackedCELLS,smplngTM,inputLEVELS);

        if ITR+54<=length(inputLEVELS)
            inputLEVELS(ITR:ITR+54)=u(smplngTM*ITR:smplngTM:smplngTM*(ITR+54));
        else
            inputLEVELS(ITR:ITR+49)=u(smplngTM*ITR:smplngTM:smplngTM*(ITR+49));
        end
        
    else
        
        fakeCTRL(ITR,trackedCELLS,smplngTM);

    end
    
    isIND = mvSRNGS(inputLEVELS(ITR), smplngTM, isIND);
    
    %-----------------image analysis---------------
    readIMG
 
    [trackedCELLS, removedCELLS, idN] = trackingYeastCycling(Bf_Img, ...
        Green_Img, Red_Img, ITR, cropRECT, idN, trackedCELLS, ...
        removedCELLS);
        
    %-----------------------------------------------
    
    save([pathNAME 'output_data_', expNAME, '.mat'])
    
    time=[time;toc];
    
end


%% Uncontrolled phase in -MET
for ITR = (controlTime+1):dimEXP
    
    tic

    disp(['Iteration: ', num2str(ITR) '/' num2str(dimEXP)])
    
    fakeCTRL(ITR,trackedCELLS,smplngTM);
    
    inputLEVELS(ITR) = 1;
    
    isIND = mvSRNGS(inputLEVELS(ITR), smplngTM, isIND);

    
    %-----------------image analysis---------------
    readIMG
    
    [trackedCELLS, removedCELLS, idN] = trackingYeastCycling(Bf_Img, ...
        Green_Img, Red_Img, ITR, cropRECT, idN, trackedCELLS, ...
        removedCELLS);
       
    %-----------------------------------------------
    
    save([pathNAME 'output_data_', expNAME, '.mat'])
    
    time=[time;toc];

end