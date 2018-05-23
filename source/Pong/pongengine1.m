function []= pongengine1(app)
%clc; clear all; close all;

%% GAME PARAMETERS
%1= v CPU
PADDLE_SPEED= 0.02;
quit= false;
paused= false;

%set Computer skill level
switch app.SkillButtonGroup.SelectedObject.Text
    case 'low'
        PADDLE_SPEED_COMP_MAX= 0.02;
    case 'middle'
        PADDLE_SPEED_COMP_MAX= 0.04;
    case 'high'
        PADDLE_SPEED_COMP_MAX= 0.06;
end
PADDLE_SPEED_COMP=PADDLE_SPEED_COMP_MAX;

rounds= app.RoundsEditField.Value;

fig= figure;
%Quelle: https://ch.mathworks.com/help/matlab/ref/matlab.ui.figure-properties.html
fig.Name= 'Pong'; %set Name
fig.NumberTitle= 'off'; % turn off number
fig.MenuBar='none'; %turn off menubar
fig.Color= 'k'; %set background color

% max 1920 x 1080 FULL HD
FIGURE_HEIGHT= 900;
FIGURE_WIDTH= 1700;
verhaeltnis= FIGURE_HEIGHT/FIGURE_WIDTH;

scrsz = get(0,'ScreenSize');
fig.InnerPosition= [(scrsz(3)-FIGURE_WIDTH)/2, (scrsz(4)-FIGURE_HEIGHT)/2, FIGURE_WIDTH, FIGURE_HEIGHT];

%movegui(fig, 'center');
fig.Resize= 'off';
%fig.WindowState='maximized';
%fig.WindowState='fullscreen';
%fig.WindowStyle= 'modal';%du kannst somit nicht nach MATLAB wechseln.

% Create axes
axes('units', 'normalized', 'position', [0 0 1 1], ...
    'xtick', [], 'ytick', [], 'color', 'k', 'xlim', [0 1], 'ylim',[0 1]);

%% Ball
%BALL_RADIUS = 0.2; %radius to calculate bouncing
BALL_MARKER_SIZE = 20; %aesthetic, does not affect physics, see BALL_RADIUS
% BALL_COLOR = [.1, .7, .1];
BALL_COLOR = 'r';
%BALL_OUTLINE = [.7, 1, .7];
BALL_OUTLINE = 'r';
BALL_SHAPE = 'o';
BALL_RADIUS= 1/FIGURE_WIDTH+1/FIGURE_WIDTH*BALL_MARKER_SIZE/2;

ball= plot(0.5,0.5);
if rand>= 0.5
    ballVector= [-rand, -rand];
else
    ballVector= [rand, rand];
end

ballSpeed= 0.01;

set(ball, 'Marker', BALL_SHAPE);
set(ball, 'MarkerEdgeColor', BALL_OUTLINE);
set(ball, 'MarkerFaceColor', BALL_COLOR);
set(ball, 'MarkerSize', BALL_MARKER_SIZE);

set(gca,'Color','k','xtick', [], 'ytick', []);

%% Players
paddle1V = 0; %velocity
paddle2V = 0; %velocity

% Draw left player racket
playerLeft = patch([0.05 0.07 0.07 0.05], [0.45 0.45 0.55 0.55], [0 0 0 0], ...
    'facecolor', 'g', 'edgecolor', 'k');
yd_playerLeft = get(playerLeft, 'ydata');

% Draw right player racket
playerRight = patch([0.95 0.93 0.93 0.95], [0.45 0.45 0.55 0.55], [0 0 0 0], ...
    'facecolor', 'g', 'edgecolor', 'k');
yd_playerRight = get(playerRight, 'ydata');

%% Draw boarders
% Draw upper line
patch([0 1 1 0], [0.95 0.95 1 1], [0 0 0 0], 'facecolor', 'g', ...
    'edgecolor', 'g', 'handlevisibility', 'off');

% Draw lower line
patch([0 1 1 0], [0 0 0.05 0.05], [0 0 0 0], 'facecolor', 'g', ...
    'edgecolor', 'g', 'handlevisibility', 'off');

%% Draw Scores & rounds
sc_left = text(0.425 , 0.96, '0');
sc_right = text(0.575 , 0.96, '0');
//t_rounds = text(


%% Draw Pause
t_pause = text(0.5, 0.5, 'Game paused', 'visible','off');

%% Set Text Options
set([sc_left sc_right t_pause t_rounds], 'fontsize', 25, ...
    'color', 'r', 'hor', 'center');


%% Set Listners
%register keydown and keyup listeners
set(fig,'KeyPressFcn',@keyDown, 'KeyReleaseFcn', @keyUp, 'DeleteFcn', @figureclose)

%% Callback Do on Close
    function figureclose(src,event)
        app.Pong.Visible='on'
    end

%% Callback -----------keyDown------------
%listener registered in createFigure
%listens for input
%sets appropriate variables and calls functions
    function keyDown(src,event)
        switch event.Key
            case 'w'
                paddle1V = 1;
            case 's'
                paddle1V = -1;
            case 'uparrow'
                paddle2V = 1;
            case 'downarrow'
                paddle2V = -1;
                %       case 'p'
                %         if ~paused
                %           pauseGame([MESSAGE_PAUSED MESSAGE_CONTROLS]);
                %         end
                %       case 'r'
                %         newGame;
            case 'p'
                pauseGame();
            case 'q'
                quit=true;
        end
        %     unpauseGame;
    end

%% Callback ------------keyUp------------
% listener registered in createFigure
% used to stop paddles on keyup
    function keyUp(src,event)
        switch event.Key
            case 'w'
                if paddle1V == 1
                    paddle1V = 0;
                end
            case 's'
                if paddle1V == -1
                    paddle1V = 0;
                end
            case 'uparrow'
                if paddle2V == 1
                    paddle2V = 0;
                end
            case 'downarrow'
                if paddle2V == -1
                    paddle2V = 0;
                end
        end
    end

%% ------------moveBall------------
%calculates new ball location
%checks if it will hit any walls or paddles
%if it does, call bounce to change ball vector
%move ball to new location
%called from main loop on every frame
    function moveBall
        %while hit %calculate new vectors until we know it wont hit something
        %temporary new ball location, only apply if ball doesn't hit anything.
        ballVector= ballVector ./ (sqrt(ballVector(1)^2 + ballVector(2)^2));
        newX = ball.XData + (ballSpeed * ballVector(1));
        newY = ball.YData + (ballSpeed * ballVector(2));
        m= (newY - ball.YData) / (newX - ball.XData);
        b= ball.YData - m * ball.XData;
        yLeft= m * playerLeft.XData(2) + b; %XData bei Player immer gleich
        yRight= m * playerRight.XData(2) + b;
        
        %hit test top wall
        if (newY > 0.95-BALL_RADIUS)
            %hit top wall
            newY= 0.95-BALL_RADIUS;
            ballVector(2)= ballVector(2)*(-1);
            ballSpeed= ballSpeed+0.001;
            
            %hit test bottom wall
        elseif (newY < 0.05+BALL_RADIUS)
            newY= 0.05+BALL_RADIUS;
            ballVector(2)= ballVector(2)*(-1);
            ballSpeed= ballSpeed+0.001;
            
            %Hit right or left wall
        elseif (newX > 1-BALL_RADIUS || newX < BALL_RADIUS)
            if rand>= 0.5
                ballVector= [-rand, -rand];
            else
                ballVector= [rand, rand];
            end
            ballSpeed= 0.01;
            newX= 0.5; newY= 0.5;
            if newX < BALL_RADIUS
                score = get(sc_right, 'string');
                set(sc_right, 'string', str2double(score)+1);
            else
                score = get(sc_left, 'string');
                set(sc_left, 'string', str2double(score)+1);
            end
            
            %hit left player
        elseif (ball.XData - BALL_RADIUS) < playerLeft.XData(2) && playerLeft.YData(2) <= yLeft && yLeft <= playerLeft.YData(3)
            %         disp('Hit Left')
            ballSpeed= ballSpeed+0.001;
            newX= playerLeft.XData(2)+BALL_RADIUS;
            
            playerLeftCenter= (playerLeft.YData(3)-playerLeft.YData(1))/2+playerLeft.YData(1);
            ballVector(2)= 20*(ball.YData-playerLeftCenter);
            ballVector(1)= ballVector(1)*(-1);
            
            %hit right player
        elseif (ball.XData + BALL_RADIUS) > playerRight.XData(2) && playerRight.YData(2) <= yRight && yRight <= playerRight.YData(3)
            %         disp('Hit Right')
            ballSpeed= ballSpeed+0.001;
            newX= playerRight.XData(2)-BALL_RADIUS;
            
            playerRightCenter= (playerRight.YData(3)-playerRight.YData(1))/2+playerRight.YData(1);
            ballVector(2)= 20*(ball.YData-playerRightCenter);
            ballVector(1)= ballVector(1)*(-1);
            
        else
            %no hits
        end
        
        %move ball to new location
        ball.XData = newX;
        ball.YData = newY;
        
    end

%% move Computer
    function moveComputer
        %playerLeftCenter= (playerLeft.YData(3)-playerLeft.YData(1))/2+playerLeft.YData(1);
        PADDLE_SPEED_COMP= min([PADDLE_SPEED_COMP_MAX, sqrt(abs(ball.XData-playerLeft.XData(2)))]);
        if ball.YData > playerLeft.YData(3)
            paddle1V= 1;
        elseif ball.YData < playerLeft.YData(1)
            paddle1V= -1;
        else
            paddle1V= 0;
        end
    end

%% ------------refreshPlot------------
%sets data in plots
%calls matlab's drawnow to refresh plots
%uses matlab pause to create animation frame
%called from main loop on every frame
    function refreshPlot
        set(ball, 'XData', ball.XData, 'YData', ball.YData);
        set(playerLeft, 'ydata', yd_playerLeft);
        set(playerRight, 'ydata', yd_playerRight);
        drawnow;
    end

%% ------------movePaddles------------
%uses paddle velocity set paddles
%called from main loop on every frame
    function calc2Players
        %set new paddle y locations
        yd_playerLeft= yd_playerLeft + (PADDLE_SPEED * paddle1V);
        yd_playerRight= yd_playerRight + (PADDLE_SPEED * paddle2V);
        
        %if paddle out of bounds, move it in bounds
        if yd_playerLeft(3) > 0.95
            yd_playerLeft= [0.85 0.85 0.95 0.95];
        elseif yd_playerLeft(1) < 0.05
            yd_playerLeft= [0.05 0.05 0.15 0.15];
        end
        if yd_playerRight(3) > 0.95
            yd_playerRight= [0.85 0.85 0.95 0.95];
        elseif yd_playerRight(1) < 0.05
            yd_playerRight= [0.05 0.05 0.15 0.15];
        end
    end

%% Calc 1 Player
    function calc1Player
        %set new paddle y locations
        yd_playerLeft= yd_playerLeft + (PADDLE_SPEED_COMP * paddle1V);
        yd_playerRight= yd_playerRight + (PADDLE_SPEED * paddle2V);
        
        %if paddle out of bounds, move it in bounds
        if yd_playerLeft(3) > 0.95
            yd_playerLeft= [0.85 0.85 0.95 0.95];
        elseif yd_playerLeft(1) < 0.05
            yd_playerLeft= [0.05 0.05 0.15 0.15];
        end
        if yd_playerRight(3) > 0.95
            yd_playerRight= [0.85 0.85 0.95 0.95];
        elseif yd_playerRight(1) < 0.05
            yd_playerRight= [0.05 0.05 0.15 0.15];
        end
    end

%% Game pause
    function pauseGame
        if ~paused
            paused=true;
            set(t_pause, 'visible', 'on')
        else
            paused=false;
            set(t_pause, 'visible', 'off')
        end
    end

%% Game

switch app.GameMode.Value
    case '1 Player'
        while ~quit
            if paused
                waitforbuttonpress
            else
            moveComputer;
            calc1Player;
            moveBall;
            refreshPlot;
            end
        end
    case '2 Players'
        while ~quit
            if paused
                waitforbuttonpress
            else
            calc2Players;
            moveBall;
            refreshPlot;
            end
        end
end

close(gcf)       %schliesst die Figur

end