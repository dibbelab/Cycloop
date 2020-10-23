%% event.m
%%% OCTOBER 14, 2020

function [ value,isterminal,direction ] = event( t,x,th,u,phicrit,Vc )
    
    value(1)=sign(x(1)-th)-1;
    isterminal(1)=1;
    direction(1)=1;
    value(2)=u(floor(t))+(mod(x(1),2*pi)>=phicrit)+(x(2)<Vc);
    isterminal(2)=1;
    direction(2)=0;

end

