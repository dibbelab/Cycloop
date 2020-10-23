%% phase_estimation.m
%%% OCTOBER 14, 2020

function [stimaf,stimaw,ignore] = phase_estimation(ITR,trackedCELLS,smplngTM)

T0=105; % Nominal cell-cycle period
T0=T0/smplngTM;
phicrit=0.4*2*pi; % Phase value at the G1 to S transition

options = fitoptions('gauss2', 'Lower', [0 0 0 0 0 0]);

fluo=NaN(ITR-1,length(trackedCELLS));
normfluo=NaN(ITR-1,length(trackedCELLS));
rectfluo=NaN(ITR-1,length(trackedCELLS));

for i=1:length(trackedCELLS)
    fluo(end-length(trackedCELLS(i).MaxGreenFluo)+1:end,i)=...
        trackedCELLS(i).MaxGreenFluo;
    normfluo(:,i)=(fluo(:,i)-min(fluo(:,i)))/...
        (max(fluo(:,i))-min(fluo(:,i)));
end

a=1;
b=[.2 .2 .2 .2 .2];
b2=[1/3 1/3 1/3];
ffluo=filter(b,a,fluo,[],1);
ffluo=filter(b2,a,ffluo,[],1);
ffluo=[ffluo(4:end,:);ones(3,1)*ffluo(end,:)];
dffluo=diff(diff(ffluo)>0);

for i=1:length(trackedCELLS)
    if length(trackedCELLS(i).frame)>=3
        ffluo(trackedCELLS(i).frame(1:3),i)=...
            fluo(trackedCELLS(i).frame(1:3),i);
        ffluo(trackedCELLS(i).frame(end-2:end),i)=...
            fluo(trackedCELLS(i).frame(end-2:end),i);
    end
end

if ITR>50
    fluo2=fluo(ITR-50:ITR-1,:);
else
    fluo2=fluo;
end
[N,edges]=histcounts(fluo2);
f=fit(((edges(1:end-1)+edges(2:end))./2)',N','gauss2',options);
coeff=coeffvalues(f);
if coeff(5)<coeff(2)
    coeff=[coeff(4:6) coeff(1:3)];
end
x=floor(coeff(2)):.1:ceil(coeff(5));
y1=coeff(1)*exp(-((x-coeff(2))./coeff(3)).^2);
y2=coeff(4)*exp(-((x-coeff(5))./coeff(6)).^2);
[~,soglia]=min(abs(y1-y2));
soglia=coeff(2)+.1*soglia;
if isempty(soglia)
    soglia=coeff(2)+coeff(3)/2;
end

distp=coeff(5)-coeff(2);

for i=1:length(trackedCELLS)
    rectfluo(:,i)=fluo(:,i)>=soglia;
    
    wrong=find((rectfluo(3:end-2,i)~=rectfluo(1:end-4,i) & ...
        rectfluo(3:end-2,i)~=rectfluo(2:end-3,i) & ...
        rectfluo(3:end-2,i)~=rectfluo(4:end-1,i) & ...
        rectfluo(3:end-2,i)~=rectfluo(5:end,i)));
    rectfluo(2+wrong,i)=(~rectfluo(2+wrong,i));
    for v=1:2
        wrong=find((1*(rectfluo(3:end-2,i)~=rectfluo(1:end-4,i)) + ...
            1*(rectfluo(3:end-2,i)~=rectfluo(2:end-3,i)) + ...
            1*(rectfluo(3:end-2,i)~=rectfluo(4:end-1,i)) + ...
            1*(rectfluo(3:end-2,i)~=rectfluo(5:end,i)))>=3);
        rectfluo(2+wrong,i)=(~rectfluo(2+wrong,i));
    end
    
    
    a=diff(rectfluo(:,i));
    b=find(a);
    if length(b)>=2
        c=find(diff(b)<floor(15/smplngTM));
        for j=1:length(c)
            rectfluo(b(c(j))+1:b(c(j)+1),i)=rectfluo(b(c(j)),i);
        end
    end
    
    
    a=diff(rectfluo(:,i));
    b=find(a);
    b=[b;length(a)];
    for j=1:length(b)-1
        
        if a(b(j))==1
            
            lastc=find(dffluo(b(j):b(j+1)-1,i)==-1);
            lastd=find(dffluo(b(j):b(j+1)-1,i)==1);
            
            if ~isempty(lastc)
                
                lastd=lastd(lastd>lastc(1));
                
                lastc=[lastc;b(j+1)-b(j)];
                lastd=[lastd;b(j+1)-b(j)];
                
                for l=1:length(lastc)-1

                    if any(ffluo(b(j)+lastc(l),i)-ffluo(b(j)+...
                            lastd(l:end),i)>2*distp)
                        st=find(ffluo(b(j)+lastc(l),i)-ffluo(b(j)+...
                            lastd(l:end),i)>2*distp,1,'first');
                        wrong=find(ffluo(b(j)+lastc(l):b(j)+...
                            lastd(l+st-1)+1,i)<ffluo(b(j)+...
                            lastc(l),i)-2*distp);
                        rectfluo(b(j)+lastc(l)-1+wrong,i)=0;
                        wrong=find(ffluo(b(j)+lastd(l+st-1):b(j)+...
                            lastc(l+st-1+1),i)<ffluo(b(j)+...
                            lastd(l+st-1),i)+distp/2);
                        rectfluo(b(j)+lastd(l+st-1)-1+wrong,i)=0;
                    end
                end
            end
        end
    end
    
        wrong=find((rectfluo(3:end-2,i)~=rectfluo(1:end-4,i) & ...
            rectfluo(3:end-2,i)~=rectfluo(2:end-3,i) & ...
            rectfluo(3:end-2,i)~=rectfluo(4:end-1,i) & ...
            rectfluo(3:end-2,i)~=rectfluo(5:end,i)));
    rectfluo(2+wrong,i)=(~rectfluo(2+wrong,i));
    for v=1:2
        wrong=find((1*(rectfluo(3:end-2,i)~=rectfluo(1:end-4,i)) + ...
            1*(rectfluo(3:end-2,i)~=rectfluo(2:end-3,i)) + ...
            1*(rectfluo(3:end-2,i)~=rectfluo(4:end-1,i)) + ...
            1*(rectfluo(3:end-2,i)~=rectfluo(5:end,i)))>=3);
        rectfluo(2+wrong,i)=(~rectfluo(2+wrong,i));
    end
    
    a=diff(rectfluo(:,i));
    b=find(a);
    if length(b)>=2
        c=find(diff(b)<floor(15/smplngTM));
        for j=1:length(c)
            rectfluo(b(c(j))+1:b(c(j)+1),i)=rectfluo(b(c(j)),i);
        end
    end
    

    if length(trackedCELLS(i).MaxGreenFluo)~=ITR-1
        rectfluo(1:ITR-1-length(trackedCELLS(i).MaxGreenFluo),i)=...
            rectfluo(ITR-length(trackedCELLS(i).MaxGreenFluo),i);
    end
    
end

ignore=false(1,length(trackedCELLS));
stimaf=NaN(1,length(trackedCELLS));
stimaw=NaN(1,length(trackedCELLS));
stimafluo=NaN(1,length(trackedCELLS));

for i=1:length(trackedCELLS)
    [a,~,b]=find(diff(rectfluo(:,i)));
    c=diff(b);
    if ~isempty(a)
        if any(c==-2)
            d=diff(a);
            T=(5/3)*median(d(c==-2)); 
            if T<T0-30/smplngTM || T>T0+30/smplngTM
               T=T0;
            end
            stimaw(i)=2*pi/T;
            stimaf(i)=((ITR-a(end))/T)*2*pi+(b(end)==1)*phicrit;
        else
            stimaw(i)=2*pi/T0;
            stimaf(i)=((ITR-a(end))/T0)*2*pi+(b(end)==1)*phicrit;
        end
        stimafluo(i)=mod(stimaf(i),2*pi)>=phicrit;
        if stimafluo(i)~=rectfluo(end,i)
            stimaf(i)=phicrit-2*pi/100+2*pi*(3/5)*(rectfluo(end,i)==1);
        end
        if b(end)==-1 && a(end)<ITR-1-2*10
            ignore(i)=true;
            stimaf(i)=NaN;
        end
    else
        ignore(i)=true;
    end
end

stimaf=mod(stimaf,2*pi);
stimaw=stimaw./smplngTM;

end