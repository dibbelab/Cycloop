%% makeMOV_.m
%%% OCTOBER 8, 2020

function makeMOV_(strain_mod, ctrl_name, Theta, Volume, U, t_out, R, ...
    Psi, O, Theta_r)

v = VideoWriter(['./Movies/movie_' strain_mod '_' ctrl_name], 'MPEG-4');

v.FrameRate = 12;

v.Quality = 100;

open(v);


switch strain_mod
    
    case 'Cycling'
        
        Theta_c = .4 * 2 * pi;
        
        a = linspace(Theta_c, 2*pi);
        
    case 'Non-Cycling'
        
        Theta_c = .25 * 2 * pi;
        
        a = linspace(0, Theta_c);
        
end


[x, y] = pol2cart(Theta, Volume);


[KurX, KurY] = pol2cart(Psi, R);


figure('Position', [1 1 480 480], 'DefaultAxesFontSize', 20, ...
        'DefaultAxesLineWidth', 2.5, 'Renderer', 'Painters');

%% Cells evolution subplot
S1 = subplot(8,1,1:6);

t_c = linspace(0, 2*pi, 1000);

r = 1;

x_c = 0 + r * sin(t_c);

y_c = 0 + r * cos(t_c);

line(x_c, y_c, 'LineWidth', 2, 'Color', 'k')

hold on


[lin_x, lin_y] = pol2cart(Theta_c, 4);

line([0 lin_x], [0, lin_y], 'LineWidth', 2, 'LineStyle', '--', 'Color', 'k')

line([0 2.5],[0 0],'LineWidth',2,'LineStyle','-','Color','r')

patch([0 cos(a) 0], [0 sin(a) 0], 'g', 'EdgeAlpha', 0, 'FaceAlpha', 0.2);

axis square % set axis to square

axis([-1 1 -1 1] * 2.5)


S1.XTickLabel = '';

S1.XAxis.Visible = 'off';

S1.YTickLabel = '';

S1.YAxis.Visible = 'off';

s = scatter(x(1,:), y(1,:));

sKur = scatter(KurX(1), KurY(1), 100, 'filled');

switch ctrl_name
    
    case 'RefOsc'
        
        [ReOsX, ReOsY] = pol2cart(Theta_r, ones(size(Theta_r)));
        
        sReOs = scatter(ReOsX(1), ReOsY(1), 200, [.65 .74 .86], 'filled');
        
end


%% Output subplot

S2 = subplot(8, 1, 7, 'LineWidth', 2.5, 'FontSize', 20);

out_plot = stairs(t_out(1) , O(1), 'LineWidth', 2, 'Color', [.35 .70 .67]);

axis([0 t_out(end) -0.1 1.1])

S2.XTickLabel = '';

ylabel('Output')


%% Control input subplot

subplot(8, 1, 8, 'LineWidth', 2.5, 'FontSize', 20)


u_plot = stairs(t_out(1) , U(1), 'LineWidth', 2, 'Color', [1 .25 .25]);

axis([0 t_out(end) -0.1 1.1])

xlabel('Time (min)')

ylabel('Input')


%%
pause(0.01)

frame = getframe(gcf);

writeVideo(v,frame);


%% Update plots
for k = 2:length(t_out)
    
    set(s, 'XData', x(k,:), 'YData', y(k,:))
    
    set(sKur, 'XData', KurX(k), 'YData', KurY(k))
    
    switch ctrl_name
    
        case 'RefOsc'
            
            set(sReOs, 'XData', ReOsX(k), 'YData', ReOsY(k))

    end
    
    set(out_plot, 'XData', t_out(1:k), 'YData', O(1:k))

    set(u_plot, 'XData', t_out(1:k), 'YData', U(1:k))
    
    pause(0.01)
    
    frame = getframe(gcf);
    
    writeVideo(v,frame);
    
end

close(v);

end