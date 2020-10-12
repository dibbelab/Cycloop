%% excODEs_.m
%%% OCTOBER 12, 2020

function [N, t_out, x_out, lineage] = excODEs_(N, ts_i, ts_f, u, t_out, x_out, ...
    lineage, bool_div, strain_mod)

%% Set variables and options for odesolver
options = odeset('Events', @div_Events_, 'RelTol', 1e-5, 'AbsTol', ...
    1e-8, 'MaxStep', 1e-02, 'InitialStep', 1e-16);

tSPAN = [ts_i ts_f];

x0 = x_out(end,:).';


%% Event driven simulation
while true
    
    
    %% Handle to strain's ODE function.
    switch strain_mod
        
        case 'Cycling'
            
            PhaseODE_ = @CyclingODEs_;
            
        case 'Non-Cycling'
            
            PhaseODE_ = @NonCyclingODEs_;
            
    end
    
    
    %% Solve until the first terminal event.
    [t_s, x_s, ~, ~, ie] = ode15s(PhaseODE_, tSPAN, x0, options, u, N);

    
    x0 = x_s(end,:).';
        
    %% Set the new initial condition for each cell
    if ~isempty(ie)
        
        for s = 1:numel(ie)
        
            ie_stop = ie(s);  % Simulation stops always at the last reported event (see documentation)

            q = ie_stop;

            x0(q*2-1) = mod(x0(q*2-1), 2*pi);
            
            
            if bool_div

                N = N + 1;
                
                lineage(N) =  struct('label', N, 'init', t_s(end), ...
                    'root', q, 'leaf', []);
                
                lineage(q).leaf(end+1) =  N;
            
                
                % % Volume for daughter cell
                tempV_d = .61 * x0(2*q);

                x0((2*N-1:2*N),:) = [0; tempV_d];

                clear tempV_d

            end
            
        end
        
    end
    
    
    %% If the following condition is true, then simulation ends.
    if t_s(end) == ts_f
        break;
    end
    
    
    %% Update solver options
    % A good guess of a valid first timestep is the length of the last valid 
    % timestep, so use it for faster computation.
    options = odeset(options, 'InitialStep', t_s(end)-t_s(end-1)); 
    
    
    %% Set new tSPAN
    tSPAN = [t_s(end), tSPAN(tSPAN > t_s(end))];

end


x_out = [x_out, nan(size(x_out,1),size(x0,1)-size(x_out,2)); x0.'];

t_out(end+1) = t_s(end);