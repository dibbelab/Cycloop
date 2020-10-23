%% div_events.m
%%% OCTOBER 22, 2020

function [value, isterminal, direction] = div_events(~, z, u, N)

%%
value = zeros(N,1);

isterminal = ones(N,1); % stop the integration

direction = ones(N,1); % positive direction


%% Detect event: z-th cell has reached phase 2pi
for q = 1:N
    
    value(q) = z(2*q-1) - 2*pi; % detect cell phase = 2*k*pi
    
end