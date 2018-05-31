function []= pongengine(app)

%% GAME PARAMETERS

%flags
quit= false;
paused= false;

%Player Speed
PLAYER_SPEED= 0.025;

%evaluate game typ
switch app.GameModeButtonGroup.SelectedObject.Text
    case '1 Player'
        onePlayerMode= true;
        playerLeftName= 'Computer';
    case '2 Players'
        onePlayerMode= false;
        playerLeftName= app.NickPlayer2EditField.Value;
end

%set Computer skill level
switch app.SkillButtonGroup.SelectedObject.Text
    case 'leicht'
        PLAYER_SPEED_COMP_MAX= 0.01; % old 0.02
        scoreSkillFactor= 100;
    case 'mittel'
        PLAYER_SPEED_COMP_MAX= 0.02; % old 0.04
        scoreSkillFactor= 200;
    case 'schwer'
        PLAYER_SPEED_COMP_MAX= 0.03; % old 0.06
        scoreSkillFactor= 300;
end

PLAYER_SPEED_COMP= PLAYER_SPEED_COMP_MAX;

%set rounds
rounds= app.RoundsSpinner.Value;
roundsPlayed= 1;

%player names
playerRightName= app.NickPlayer1EditField.Value;


%define figure
fig= figure;
%Quelle: https://ch.mathworks.com/help/matlab/ref/matlab.ui.figure-properties.html
fig.Name= 'Pong'; %set Name
fig.NumberTitle= 'off'; % turn off number
fig.MenuBar='none'; %turn off menubar
fig.Color= 'k'; %set background color

SCREEN_SCALING_FACTOR= 1;
FIGURE_HEIGHT= 1000/SCREEN_SCALING_FACTOR;
FIGURE_WIDTH= 1920/SCREEN_SCALING_FACTOR;

screenSize = get(0,'ScreenSize');
fig.OuterPosition= [(screenSize(3)-FIGURE_WIDTH)/2, (screenSize(4)-FIGURE_HEIGHT)/2, FIGURE_WIDTH, FIGURE_HEIGHT];

%movegui(fig, 'center');
fig.Resize= 'off';
% fig.WindowState='maximized';

%fig.WindowState='fullscreen';
%fig.WindowStyle= 'modal';%du kannst somit nicht nach MATLAB wechseln.

% Create axes
axes('units', 'normalized', 'position', [0 0 1 1], ...
    'xtick', [], 'ytick', [], 'color', 'k', 'xlim', [0 1], 'ylim',[0 1]);



%% Ball
BALL_MARKER_SIZE = 20; %aesthetic, does not affect physics, see BALL_RADIUS
BALL_COLOR = 'w';
BALL_OUTLINE = 'w';
BALL_SHAPE = 'o';
BALL_RADIUS= 1/FIGURE_WIDTH+1/FIGURE_WIDTH*BALL_MARKER_SIZE/2+0.0005;

ball= plot(0.5,0.5);
set(ball, 'Marker', BALL_SHAPE);
set(ball, 'MarkerEdgeColor', BALL_OUTLINE);
set(ball, 'MarkerFaceColor', BALL_COLOR);
set(ball, 'MarkerSize', BALL_MARKER_SIZE);

% Set ball position and direction first time
if rand>= 0.5
    y=rand;
    x=max(y,rand);
    ballVector= [-x, -y];
else
    y=rand;
    x=max(y,rand);
    ballVector= [x, y];
end

ballPassedPlayer= false;
ballSpeed= 0.01;

%% I have no clue why this works
set(gca,'Color','k','xtick', [], 'ytick', []);

%% Players
playerLeftV = 0; %velocity
playerRightV = 0; %velocity

% Draw left player
playerLeft = patch([0.05 0.07 0.07 0.05], [0.45 0.45 0.55 0.55], [0 0 0 0], ...
    'facecolor', 'w', 'edgecolor', 'w');
yd_playerLeft = get(playerLeft, 'ydata');

% Draw right player
playerRight = patch([0.95 0.93 0.93 0.95], [0.45 0.45 0.55 0.55], [0 0 0 0], ...
    'facecolor', 'w', 'edgecolor', 'w');
yd_playerRight = get(playerRight, 'ydata');

%% Draw boarders
% Draw upper line
patch([0 1 1 0], [0.95 0.95 1 1], [0 0 0 0], 'facecolor', 'w', ...
    'edgecolor', 'w', 'handlevisibility', 'off');

% Draw lower line
patch([0 1 1 0], [0 0 0.05 0.05], [0 0 0 0], 'facecolor', 'w', ...
    'edgecolor', 'w', 'handlevisibility', 'off');

%% Draw Scores & rounds
playerLeftScore= 0;
playerLeftScoreText = text(0.06 , 0.975, num2str(playerLeftScore), 'horizontalAlignment', 'center');
playerRightScore= 0;
playerRightScoreText = text(0.94 , 0.975, num2str(playerRightScore),'horizontalAlignment', 'center');

%quelle https://ch.mathworks.com/matlabcentral/answers/251996-how-to-insert-space-between-strings-while-doing-strcat
textRounds = strcat( 'Round', 32, num2str(roundsPlayed), ' /', 32, num2str(rounds));
t_rounds = text(0.5, 0.975, textRounds, 'horizontalAlignment', 'center');

%player names
t_player1= text(0.975, 0.025, playerRightName, 'horizontalAlignment', 'right');
t_player2= text(0.025, 0.025, playerLeftName, 'horizontalAlignment', 'left');

%% Draw Pause
t_pause = text(0.5, 0.5, 'game paused','visible','off','horizontalAlignment', 'center');

%% Set Text Options
set([playerLeftScoreText playerRightScoreText t_rounds t_player1 t_player2], 'fontname', 'consolas', 'fontsize', 30, 'color', 'k');
set(t_pause, 'fontname', 'consolas', 'fontsize', 30, 'color', 'w');

%% Set Listners
%register keydown and keyup listeners
set(fig,'KeyPressFcn',@keyDown, 'KeyReleaseFcn', @keyUp, 'DeleteFcn', @figureclose)

%% Callback Do on Close
    function figureclose(src,event)
        app.Pong.Visible='on';
        app.UITable.Data= pongHighscoreRead(app.DatabaseName); 
    end

%% Callback -----------keyDown------------
%listener registered in createFigure
%listens for input
%sets appropriate variables and calls functions
    function keyDown(src,event)
        switch event.Key
            case 'w'
                playerLeftV = 1;
            case 's'
                playerLeftV = -1;
            case 'uparrow'
                playerRightV = 1;
            case 'downarrow'
                playerRightV = -1;
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
                if playerLeftV == 1
                    playerLeftV = 0;
                end
            case 's'
                if playerLeftV == -1
                    playerLeftV = 0;
                end
            case 'uparrow'
                if playerRightV == 1
                    playerRightV = 0;
                end
            case 'downarrow'
                if playerRightV == -1
                    playerRightV = 0;
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
        
        
        %if ball past player last time
        %check hit left player
        if ~ballPassedPlayer && (newX - BALL_RADIUS) < playerLeft.XData(2) && (playerLeft.YData(2) - BALL_RADIUS) < yLeft && yLeft < (playerLeft.YData(3) + BALL_RADIUS)
            %         disp('Hit Left')
            ballSpeed= ballSpeed+0.001;
            newX= playerLeft.XData(2)+BALL_RADIUS;
            
            playerLeftCenter= (playerLeft.YData(3)-playerLeft.YData(1))/2+playerLeft.YData(1);
            ballVector(2)= 40*(ball.YData-playerLeftCenter);
            ballVector(1)= sign(ballVector(1))*-1;
            
            %check hit right player
        elseif ~ballPassedPlayer && (newX + BALL_RADIUS) > playerRight.XData(2) && (playerRight.YData(2) - BALL_RADIUS) < yRight && yRight < (playerRight.YData(3) + BALL_RADIUS)
            %         disp('Hit Right')
            ballSpeed= ballSpeed+0.001;
            newX= playerRight.XData(2)-BALL_RADIUS;
            
            playerRightCenter= (playerRight.YData(3)-playerRight.YData(1))/2+playerRight.YData(1);
            ballVector(2)= 40*(ball.YData-playerRightCenter);
            ballVector(1)= sign(ballVector(1))*-1;
            
            %Hit right or left wall
        elseif (newX > 1-BALL_RADIUS || newX < BALL_RADIUS)
            if newX < BALL_RADIUS %player right wins round
                playerRightScore = playerRightScore+1;
                set(playerRightScoreText, 'string', num2str(playerRightScore));
                [newX,newY]=startNewRound(1);
                ballPassedPlayer= false;
            else %player left wins round
                playerLeftScore = playerLeftScore+1;
                set(playerLeftScoreText, 'string', num2str(playerLeftScore));
                [newX,newY]=startNewRound(2);
                ballPassedPlayer= false;
            end
            
            % check for a winner
            checkForWinner();
            
            % show new round
            roundsPlayed= roundsPlayed+1;
            textRounds = strcat( 'Round', 32, num2str(roundsPlayed), ' /', 32, num2str(rounds));
            set(t_rounds,'string',textRounds);
            
            %hit test top wall
        elseif (newY > 0.95-BALL_RADIUS)
            %hit top wall
            newY= 0.95-BALL_RADIUS;
            ballVector(2)= ballVector(2)*(-1);
            
            %hit test bottom wall
        elseif (newY < 0.05+BALL_RADIUS)
            newY= 0.05+BALL_RADIUS;
            ballVector(2)= ballVector(2)*(-1);
            
        else
            %no hits
        end
        
        %move ball to new location
        ball.XData = newX;
        ball.YData = newY;
        
        if ~ballPassedPlayer && ball.XData - BALL_RADIUS < playerLeft.XData(2) || ball.XData + BALL_RADIUS > playerRight.XData(2)
            ballPassedPlayer= true;
        else
           %do fuck all 
        end
        
    end

%% move Computer
    function moveComputer
        playerLeftCenter= (playerLeft.YData(3)-playerLeft.YData(1))/2+playerLeft.YData(1);
        %         PADDLE_SPEED_COMP= min([PADDLE_SPEED_COMP_MAX, sqrt(abs(ball.XData-playerLeft.XData(2)))]);
        PLAYER_SPEED_COMP= PLAYER_SPEED_COMP_MAX;
%         if playerLeftV== 0 && (ball.YData + BALL_RADIUS) > playerLeft.YData(3)
%             playerLeftV= 1;
%         elseif playerLeftV== 0 && (ball.YData - BALL_RADIUS) < playerLeft.YData(1)
%             playerLeftV= -1;
%         elseif playerLeftV==1 && (ball.YData - BALL_RADIUS) < playerLeft.YData(1)
%             playerLeftV= 0;
%          elseif playerLeftV==(-1) && (ball.YData + BALL_RADIUS) > playerLeft.YData(1)
%             playerLeftV= 0;
%         else
% %             playerLeftV= 0;
%         end
        if playerLeftV== 0 && (ball.YData + BALL_RADIUS) > playerLeft.YData(3)
            playerLeftV= 1;
        elseif playerLeftV== 0 && (ball.YData - BALL_RADIUS) < playerLeft.YData(1)
            playerLeftV= -1;
        elseif playerLeftV==1 && (ball.YData - BALL_RADIUS) < playerLeftCenter
            playerLeftV= 0;
         elseif playerLeftV==(-1) && (ball.YData + BALL_RADIUS) > playerLeftCenter
            playerLeftV= 0;
        else
%             playerLeftV= 0;
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
        yd_playerLeft= yd_playerLeft + (PLAYER_SPEED * playerLeftV);
        yd_playerRight= yd_playerRight + (PLAYER_SPEED * playerRightV);
        
        %if player is out of bounds, move in bounds
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
        yd_playerLeft= yd_playerLeft + (PLAYER_SPEED_COMP * playerLeftV);
        yd_playerRight= yd_playerRight + (PLAYER_SPEED * playerRightV);
        
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


%% Start new round
    function [newX,newY]=startNewRound(winner)
        switch winner
            
            %Player 1, right player
            case 1
                ballSpeed= 0.01;
                newX= 0.5; newY= 0.5;
                if rand>= 0.5
                    y=rand;
                    x=max(y,rand);
                    ballVector= [-x, y];
                else
                    y=rand;
                    x=max(y,rand);
                    ballVector= [-x, -y];
                end
                
                %Player 2, left player
            case 2
                ballSpeed= 0.01;
                newX= 0.5; newY= 0.5;
                if rand>= 0.5
                    y=rand;
                    x=max(y,rand);
                    ballVector= [x, y];
                else
                    y=rand;
                    x=max(y,rand);
                    ballVector= [x, -y];
                end
        end
        
    end

%% Check for winner
t_winner= text(0.5, 0.5, 'nobody','visible', 'off', 'horizontalAlignment', 'center', 'color', 'w', 'fontname', 'consolas', 'fontsize', 30);
t_highscore= text(0.5, 0.35, '0','visible', 'off', 'horizontalAlignment', 'center', 'color', 'w', 'fontname', 'consolas', 'fontsize', 30);

    function checkForWinner
        if roundsPlayed==rounds
            %see who won
            if playerRightScore>playerLeftScore
                set(t_winner, 'string',strcat(playerRightName, 32, 'WINS!'),'visible', 'on');
            elseif playerRightScore<playerLeftScore
                set(t_winner, 'string',strcat(playerLeftName, 32, 'WINS!'),'visible', 'on');
            else %draw
                set(t_winner, 'string','DRAW!','visible', 'on');
            end
            if onePlayerMode
                highscore= playerRightScore * scoreSkillFactor;
                set(t_highscore, 'string', strcat(playerRightName, 32, 'Highscore:', 32, num2str(highscore)),'visible', 'on');
                pongHighscoreWrite(app.DatabaseName, playerRightName, highscore);
            else
                %do nothing
            end
            %
            pause(3);
            quit=true;
        else
            %continue game
        end
    end

%% Game

%countdown
% map = gray(256);
countdown= 3;
countdown_t= text(0.5, 0.5, num2str(countdown),'visible', 'on', 'horizontalAlignment', 'center', 'color', 'w', 'fontname', 'consolas', 'fontsize', 300);

for countdown=3:-1:1
    set(countdown_t, 'string', num2str(countdown));
    pause(1)
end

set(countdown_t, 'visible', 'off');

switch app.GameModeButtonGroup.SelectedObject.Text
    case '1 Player'
        onePlayerMode= true;
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
        onePlayerMode=false;
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