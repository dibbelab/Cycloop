%% compute_fakeFluo_BI.m
%%% OCTOBER 22, 2020

function [out_mtrx, mean_out, budd_indx] = compute_fakeFluo_BI(strain_mod, t_out, Theta, Volume)

Vol_c = 1;

switch strain_mod
    
    case 'Cycling'
        
        Theta_c = .4 * 2 * pi;
        
    case 'Non-Cycling'
        
        Theta_c = .25 * 2 * pi;
        
end
    

dim_m = length(t_out);

out_mtrx = nan(size(Theta));
mean_out = nan(dim_m,1);
budd_indx = nan(dim_m,1);


for z = 1:length(t_out)
    
    out_temp = Theta(z,:);
    
    vol_temp = Volume(z,:);

    indx_temp = out_temp < Theta_c;
    
    UNB_temp = sum(indx_temp & (vol_temp >= Vol_c));

    switch strain_mod
        
        case 'Cycling'
            
            out_temp(indx_temp) = 0;
            
        otherwise
            
    end

    indx_temp = out_temp > Theta_c;
    
    B_temp = sum(indx_temp & (vol_temp >= Vol_c));
    
    switch strain_mod
        
        case 'Cycling'
            
            out_temp(indx_temp) = 1;
            
        case 'Non-Cycling'
            
            out_temp = sin(out_temp)./2 + .5;
            
    end
    
    out_mtrx(z,:) = out_temp;

    mean_out(z) = nanmean(out_temp);
    
    budd_indx(z) = B_temp / (UNB_temp + B_temp) * 100;

end