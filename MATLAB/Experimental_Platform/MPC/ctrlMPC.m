%% ctrlMPC.m
%%% OCTOBER 14, 2020

function u = ctrlMPC(ITR,trackedCELLS,smplngTM,inputLEVELS)

global PhaseMAT

% Phase estimation
[stimaf,~,ignore] = phase_estimation(ITR,trackedCELLS,smplngTM);
stimaw=(2*pi/105)*ones(1,length(stimaf));

Theta = mod(stimaf(~ignore),2*pi); 
omega = stimaw(~ignore);
  
N=100; % Prediction horizon equals to 100 min
nmaxpul=10; % Max number of pulses in the prediction horizon
u=NaN(2*length(inputLEVELS),1);
u(1+2*(0:length(inputLEVELS)-1))=~inputLEVELS;
u(2+2*(0:length(inputLEVELS)-1))=~inputLEVELS;

trials=combinations(N,nmaxpul);

vol=NaN(1,length(trackedCELLS));
for i=1:length(trackedCELLS)
    vol(i)=(trackedCELLS(i).Area(end)^(3/2))*4/(3*sqrt(pi));
end

if sum(~ignore)>=2
    
    utent=ones(size(trials,1),1)*u';
    utent=[utent ones(size(trials,1),11)];
    
    for tt=1:size(utent,1)
        for p=1:10
            if ~trials(tt,1+10*(p-1))
                utent(tt,smplngTM*ITR+10*(p-1):smplngTM*ITR+19+10*(p-1))=0;
            end
        end
    end
    
    keep=false(1,size(utent,1));
    unico=false(1,size(utent,1));
    for tt=1:size(utent,1)
        keep(tt)=~contains(strjoin(string(utent(tt,:))),...
            strjoin(string(zeros(1,61))));
    end
    [~,un,~]=unique(utent,'rows');
    unico(un)=true;
    keepfinal=keep & unico;
    
    J=NaN(length(trials(:,1)),1);
    disp('Try combinations');
    for l=1:length(trials(:,1))
        if keepfinal(l)
        utentativo=utent(l,:);
        [J(l)]=num_integration(...
            utentativo(smplngTM*ITR:smplngTM*ITR+N-1),ignore,stimaf,stimaw,vol);
         end
    end
    
    [Jopt,~]=min(J);
    indexopt=find((J-Jopt)<(1e-3));
    nzopt=sum(abs(diff(utent(indexopt,:),1,2)),2);
    indexopt=indexopt(nzopt==min(nzopt));
    nzopt=sum(trials(indexopt,:),2);
    [~,b]=max(nzopt);
    opttent=indexopt(b);
    
    if isempty(opttent)
        opttent=2^nmaxpul;
    end
    
    u=utent(opttent,:);
end

u=~u;

PhaseMAT(ITR) = struct('trackedCELLS',[trackedCELLS(~ignore).LABEL],...
    'stimaf',Theta,'stimaw',omega);

end