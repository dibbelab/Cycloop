%% retrieve_data.m
%%% OCTOBER 22, 2020

function [Theta, Volume, R, Psi] = retrieve_data(t_out, x_out)

Vol_c = 1;


Theta = x_out(:,1:2:end);
Volume = x_out(:,2:2:end);


%% Compute the mean phase coherence R
R = nan(length(t_out),1);
Psi = nan(length(t_out),1);

for z = 1:length(t_out)
    
    vol_temp = Volume(z,:);
    
    tempTheta = Theta(z,vol_temp>= Vol_c); % Consider only those cells that exist at time t_out(z).
    
    tempN = numel(tempTheta); % Number of cells at time t_out(z).
    
    KOP = 1 ./ tempN .* sum(exp(1i .* tempTheta));
    
    R(z) = abs(KOP);
    
    Psi(z) = angle(KOP);
    
end