%% num_integration.m
%%% OCTOBER 14, 2020

function Jtentativo = num_integration(u, ignore, stimaf, stimaw, vol)

t=1;
tstop=length(u);
Vc=0;
vol=vol*1e-3;
mu=(log(2))/84;
T0=105;
phicrit=0.4*2*pi;

ncell=sum(~ignore);
nmax=ncell;

cell(1:nmax)=struct('w',NaN,'t',1,'phi',[],'phic',[],'vol',[],'totvol',...
    [],'tstart',1,'th',2*pi);

stimaw=num2cell(stimaw(~ignore));
[cell(1:ncell).w]=stimaw{:};

stimaf=num2cell(stimaf(~ignore));
[cell(1:ncell).phi]=stimaf{:};
[cell(1:ncell).phic]=stimaf{:};

vol=num2cell(vol(~ignore));
[cell(1:ncell).vol]=vol{:};

j=1;
while j<=ncell

        while cell(j).tstart<tstop
            
            uevent=u;
            if uevent(floor(cell(j).tstart))==0
                uevent(floor(cell(j).tstart))=1;
                uevent(floor(cell(j).tstart)+1)=0;
            end
                        
            options=odeset('Events',@(t,x)event(t,x,cell(j).th,uevent,...
                phicrit,Vc),'MaxStep',.9);
            [tout,xnew,te,~,ie] = ode45(@(t,x)fun_volume(t,x,cell(j).w,...
                Vc,mu),[cell(j).tstart tstop],[cell(j).phi(end) ...
                cell(j).vol(end)],options);
            
            if te-cell(j).tstart<1e-9
                ie=[];
            end
            
            if length(ie)==1 && ie==2
                cell(j).t=[cell(j).t;tout(2:end)];
                cell(j).phi=[cell(j).phi;xnew(2:end,1)];
                cell(j).phi(end)=cell(j).phi(end)+phicrit-...
                    mod(cell(j).phi(end),2*pi);
                cell(j).vol=[cell(j).vol;xnew(2:end,2)];
                cell(j).phic=mod(cell(j).phi,2*pi);
                cell(j).tstart=te+1e-3;
                
            elseif length(ie)==1 && ie==1

                cell(j).t=[cell(j).t;tout(2:end)];
                cell(j).phi=[cell(j).phi;xnew(2:end,1)];
                cell(j).vol=[cell(j).vol;xnew(2:end,2)];
                cell(j).phic=mod(cell(j).phi,2*pi);
                
                q=find(cell(j).phic(1:end-1)<=phicrit & ...
                    cell(j).phic(2:end)>phicrit);

                if ~isempty(q)
                    q=q(end)+1;
                    cell(j).vol(q:end)=cell(j).vol(q);
                else
                   cell(j).vol(1:end) = ...
                       cell(j).vol(end)*exp(-(0.6*mu*2*pi)/(cell(j).w));
                end
                
                
                cell(j).th=cell(j).th+2*pi;
                
                cell(j).tstart=te;

            elseif length(ie)==2
                
                if abs(te(1)-te(2))<1e-4
                    ie=1;
                    te=te(1);
                    
                else
                    
                    [~,m]=min(te);
                    ie=ie(m);
                    te=te(m);
                    tout=tout(1:2);
                    xnew=xnew(1:2,:);
                    
                end
                
                if ie==2
                cell(j).t=[cell(j).t;tout(2:end)];
                cell(j).phi=[cell(j).phi;xnew(2:end,1)];
                cell(j).phi(end)=cell(j).phi(end)+phicrit-...
                    mod(cell(j).phi(end),2*pi);
                cell(j).vol=[cell(j).vol;xnew(2:end,2)];
                cell(j).phic=mod(cell(j).phi,2*pi);
                
                elseif ie==1
                    
                cell(j).t=[cell(j).t;tout(2:end)];
                cell(j).phi=[cell(j).phi;xnew(2:end,1)];
                cell(j).vol=[cell(j).vol;xnew(2:end,2)];
                cell(j).phic=mod(cell(j).phi,2*pi);
                
                
                q=find(cell(j).phic(1:end-1)<=phicrit & ...
                    cell(j).phic(2:end)>phicrit);

                
                if ~isempty(q)
                    q=q(end)+1;
                    cell(j).vol(q:end)=cell(j).vol(q);
                else
                    cell(j).vol(1:end) = cell(j).vol(end)*exp(...
                        -(0.6*mu*2*pi)/(cell(j).w));
                end
                
                cell(j).th=cell(j).th+2*pi;
            
                end
                

                    cell(j).tstart=te+.1;

            else
                
                cell(j).t=[cell(j).t;tout(2:end)];
                cell(j).phi=[cell(j).phi;xnew(2:end,1)];
                cell(j).vol=[cell(j).vol;xnew(2:end,2)];
                cell(j).phic=mod(cell(j).phi,2*pi);
                
                q=find(cell(j).phic(1:end-1)<=phicrit & ...
                    cell(j).phic(2:end)>phicrit & cell(j).t(end)==tstop);
                    
                if ~isempty(q) && q(end)~=length(cell(j).vol) && ...
                        cell(j).phic(end)>phicrit
                    q=q(end)+1*(cell(j).t(end)~=tstop);
                    cell(j).vol(q:end)=cell(j).vol(q);
                end
                    
                cell(j).tstart=tstop;
                
            end
            
        end
  
        j=j+1;
     
end

phi=NaN(length(u),ncell);
vol=NaN(length(u),ncell);
     
for i=1:ncell
    if length(cell(i).t)>1
        [cell(i).t,index]=unique(cell(i).t);
        phi(:,i)=interp1(cell(i).t,cell(i).phi(index),[1:length(u)]);
        vol(:,i)=interp1(cell(i).t,cell(i).vol(index),[1:length(u)]);
    end
end

phic=mod(phi,2*pi);
    
[row,col]=size(vol);
mask=false(row,col);
mask(vol>Vc)=1;

for j=t+1:tstop
    R(j-t)=abs((1/sum(mask(j,:)))*nansum((exp(phi(j,:).*1i)).*mask(j,:)));
end

Jtentativo=1-trapz(R.^2)/(length(u)-1);

end

