%% fun_volume.m
%%% OCTOBER 14, 2020

function [ dxdt ] = fun_volume( t,x,w,Vc,mu )

dxdt(1,1)=w*heaviside(x(2)-Vc);
dxdt(2,1)=mu*x(2);

end

