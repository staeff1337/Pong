
for i= 0:1:100
fig= app.UIAxes
ballPlot= plot(fig,0+i,0+i);

set(ballPlot, 'Marker', '.');
%set(ballPlot, 'MarkerEdgeColor', 'red');
set(ballPlot, 'Color', 'g');
set(ballPlot, 'MarkerSize', 50);

axis([0 100 0 100]);
axis manual
% BALL_MARKER_SIZE = 10; %aesthetic, does not affect physics, see BALL_RADIUS
% BALL_COLOR = [.1, .7, .1];
% BALL_OUTLINE = [.7, 1, .7];
% BALL_SHAPE = '.';
pause(1)
end