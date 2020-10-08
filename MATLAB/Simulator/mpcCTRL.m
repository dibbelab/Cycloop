%% mpcCTRL.m
%%% OCTOBER 8, 2020

function u = mpcCTRL(ITR, smplngTM, inputLEVELS, Theta, Volume, Numb)

N = Numb;

T_p = 100; % prediction horizon (min)

nMaxPul = 10;

inputLEVELS(isnan(inputLEVELS)) = 0;

inputLEVELS = inputLEVELS.';

u = nan(2*length(inputLEVELS),1);

u(1+2*(0:length(inputLEVELS)-1))=~inputLEVELS;
u(2+2*(0:length(inputLEVELS)-1))=~inputLEVELS;

trials = combinations(T_p, nMaxPul);

utent = ones(size(trials,1),1)*u';
    
utent = [utent ones(size(trials,1),11)];

for tt = 1:size(utent,1)
       
    for p = 1:10
            
        if ~trials(tt,1+10*(p-1))
            
            utent(tt,smplngTM*ITR+10*(p-1):smplngTM*ITR+19+10*(p-1)) = 0;

        end
        
    end
    
end

keep = false(1,size(utent,1));

unico = false(1,size(utent,1));

for tt = 1:size(utent,1) % Delete the combinations with pulses longer than 60 min

    keep(tt) = ~contains(strjoin(string(utent(tt,:))), strjoin(string(zeros(1,61))));
    
end

[~, un, ~] = unique(utent,'rows'); % Delete the repeated combinations

unico(un) = true;

keepfinal = keep & unico;

J = NaN(length(trials(:,1)),1);

disp('Check the trials');

for l = 1:length(trials(:,1))
    
    if keepfinal(l)
        
        utentativo = utent(l,:);
        
        J(l) = num_integration(utentativo(smplngTM*ITR:smplngTM*ITR+T_p-1), Theta, Volume, N);
         
    end
    
end
    
[Jopt, ~] = min(J);

indexopt = find((J-Jopt)<(1e-3)); % Find the combination with the lowest number of pulses
    
nzopt = sum(abs(diff(utent(indexopt,:),1,2)),2);
    
indexopt = indexopt(nzopt==min(nzopt)); % Find the combination with less ON/OFF or OFF/ON switches
    
nzopt = sum(trials(indexopt,:),2);

[~,b] = max(nzopt); % Check the combination that keeps the cells in -Met for less time

opttent = indexopt(b);

if isempty(opttent)
    
    opttent = 2^nMaxPul;
    
end

u = utent(opttent,:);

u=~u;

end


function Jtentativo = num_integration(u, Theta, Volume, N)

Theta_c = .4 * 2 * pi;

beta_n = .0083;

omega = 2*pi / 105 .* ones(N,1);


t = 1;

tstop = length(u);

Vc = 0; % Critical volume. Note that we assumed a population of mother cells

ncell = N;

cell(1:ncell) = struct('w', NaN, 't', 1, 'phi', [], 'phic', [], 'vol', [], 'totvol', [], 'tstart', 1, 'th', 2*pi);

est_omega = num2cell(omega);

[cell(1:ncell).w] = est_omega{:};

est_phases = num2cell(Theta);

[cell(1:ncell).phi] = est_phases{:};

[cell(1:ncell).phic] = est_phases{:};

vol = num2cell(Volume);

[cell(1:ncell).vol] = vol{:};

j = 1;

while j <= ncell

        while cell(j).tstart < tstop % while su singola cellula
            
            uevent = u;
            
            if uevent(floor(cell(j).tstart)) == 0
                
                uevent(floor(cell(j).tstart)) = 1;
                
                uevent(floor(cell(j).tstart)+1) = 0;
            
            end
                        
            options = odeset('Events', @(t,x) mpcEVENTS(t, x, cell(j).th, uevent), 'MaxStep', .9);
            
            [tout, xnew, te, ~, ie] = ode45(@(t,x) fun_volume(t, x, cell(j).w), [cell(j).tstart tstop], [cell(j).phi(end) cell(j).vol(end)], options);
            
            if te-cell(j).tstart < 1e-9
                
                ie=[];
                
            end
            
            
            if length(ie)==1 && ie==2 % Pulse event
                
                cell(j).t = [cell(j).t; tout(2:end)];
                
                cell(j).phi = [cell(j).phi; xnew(2:end,1)];
                
                cell(j).phi(end) = cell(j).phi(end) + Theta_c - mod(cell(j).phi(end), 2*pi);
                
                cell(j).vol = [cell(j).vol; xnew(2:end,2)];
                
                cell(j).phic = mod(cell(j).phi, 2*pi);
                
                
                cell(j).tstart=te+1e-3;

            elseif length(ie)==1 && ie==1 % Ending cycle event

                cell(j).t = [cell(j).t; tout(2:end)];
                
                cell(j).phi = [cell(j).phi; xnew(2:end,1)];
                
                cell(j).vol = [cell(j).vol; xnew(2:end,2)];
                
                cell(j).phic = mod(cell(j).phi, 2*pi);
                
                q = find(cell(j).phic(1:end-1)<=Theta_c & cell(j).phic(2:end)>Theta_c); % & cell(j).phic>1e-3);

                if ~isempty(q)
                    
                    q = q(end)+1; %*(cell(j).t(end)~=tfin);
                    
                    cell(j).vol(q:end) = cell(j).vol(q); % Halt the volume
                
                else
                   
                    cell(j).vol(1:end) = cell(j).vol(end)*exp(-(0.6*beta_n*2*pi)/(cell(j).w));
                    
                end
                
                
                cell(j).th = cell(j).th + 2*pi;

                cell(j).tstart = te;

            elseif length(ie)==2

                if abs(te(1)-te(2))<1e-4
                    
                    ie=1;
                    
                    te=te(1);

                else
                    
                    [~, m] = min(te);
                    
                    ie = ie(m);
                    
                    te = te(m);
                    
                    tout = tout(1:2);
                    
                    xnew = xnew(1:2,:);

                end
                
                if ie==2 % Pulse event
                
                    cell(j).t = [cell(j).t; tout(2:end)];

                    cell(j).phi = [cell(j).phi; xnew(2:end,1)];

                    cell(j).phi(end) = cell(j).phi(end) + Theta_c - mod(cell(j).phi(end), 2*pi);

                    cell(j).vol = [cell(j).vol; xnew(2:end,2)];

                    cell(j).phic = mod(cell(j).phi, 2*pi);
  
                elseif ie==1 % Ending event cycle
                
                    cell(j).t = [cell(j).t; tout(2:end)];

                    cell(j).phi = [cell(j).phi; xnew(2:end,1)];

                    cell(j).vol = [cell(j).vol; xnew(2:end,2)];
                    

                    cell(j).phic = mod(cell(j).phi, 2*pi);

                    
                    q = find(cell(j).phic(1:end-1)<=Theta_c & cell(j).phic(2:end)>Theta_c);% & cell(j).phic>1e-3);

                
                    if ~isempty(q)

                        q = q(end)+1;

                        cell(j).vol(q:end) = cell(j).vol(q); % Halt the volume

                    else
                    
                        cell(j).vol(1:end) = cell(j).vol(end)*exp(-(0.6*beta_n*2*pi)/(cell(j).w));
                        
                    end
                    
                    cell(j).th = cell(j).th + 2*pi;

                end
                
                cell(j).tstart = te+.1;

            else % Check if any event has been detected
              
                cell(j).t = [cell(j).t; tout(2:end)];
                
                cell(j).phi = [cell(j).phi; xnew(2:end,1)];
                
                cell(j).vol = [cell(j).vol; xnew(2:end,2)];
                
                cell(j).phic = mod(cell(j).phi, 2*pi);

                q = find(cell(j).phic(1:end-1)<=Theta_c & cell(j).phic(2:end)>Theta_c & cell(j).t(end)==tstop); %ho messo tstop al posto di tfin
                    
                if ~isempty(q) && q(end)~=length(cell(j).vol) && cell(j).phic(end)>Theta_c
                    
                    q = q(end) + 1*(cell(j).t(end)~=tstop); %tstop in lieu of tfin
                    
                    cell(j).vol(q:end) = cell(j).vol(q); % Halt the volume
                
                end
                
                cell(j).tstart = tstop;

            end

        end
  
        j = j+1;

end
 
phi = NaN(length(u), ncell);

vol = NaN(length(u),ncell);
     

for i = 1:ncell
         
    if length(cell(i).t)>1
        
        [cell(i).t,index] = unique(cell(i).t);
        
        phi(:,i) = interp1(cell(i).t, cell(i).phi(index), 1:length(u));
        
        vol(:,i) = interp1(cell(i).t,cell(i).vol(index), 1:length(u));
        
    end
    
end

mask = false(size(vol));

mask(vol>Vc) = 1;

for j = t+1:tstop
    
    R(j-t) = abs((1/sum(mask(j,:)))*nansum((exp(phi(j,:).*1i)).*mask(j,:)));
    
end

Jtentativo = 1-trapz(R.^2)/(length(u)-1);


end


function [value, isterminal, direction] = mpcEVENTS(t, x, th, u)
    
Vol_c = 1;

Theta_c = .4 * 2 * pi;


value(1) = sign(x(1) - th) - 1;

isterminal(1) = 1;

direction(1) = 1;


value(2) = u(floor(t)) + (mod(x(1),2*pi) >= Theta_c) + (x(2) < Vol_c);

isterminal(2) = 1;

direction(2) = 0;

end


function dxdt = fun_volume(~, x, w)

beta_n = .0083;

Vol_c = 1;

dxdt(1,1) = w * heaviside(x(2) - Vol_c);

dxdt(2,1) = beta_n * x(2);

end


function trials = combinations(N, nmaxpul)

ncomb = 2^nmaxpul;

dec = 0:ncomb-1;

comb = de2bi(dec);

trials = ones(ncomb,N);

passo = round(N/nmaxpul);


for i = 1:ncomb
    
    for j = 0:nmaxpul-1
        
        trials(i,1+round(j*passo))=comb(i,j+1);
    
    end
    
end

end

