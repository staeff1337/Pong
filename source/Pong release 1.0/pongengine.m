%%  MATLAB Funktion: pongengine.m
%   Autoren:    A.Gessler - alex.gessler@students.fhnw.ch
%               M.Steffen - marco.steffen@students.fhnw.ch
%
%   Zweck:      Baut das Spielfeld auf, steuert den Spielablauf und
%               übergibt allenfalls Highscore dem Excelfile.
%
%   Versionskontrolle via Github: https://github.com/staeff1337/Pong.git


function []= pongengine(app)

%%  Spielparameter definieren

%   Game flags
quit= false;
paused= false;

%   Spielmodi evaluieren
switch app.GameModeButtonGroup.SelectedObject.Text
    case '1 Player'
        onePlayerMode= true;
        playerLeftName= 'Computer';
    case '2 Players'
        onePlayerMode= false;
        playerLeftName= app.NickPlayer2EditField.Value;
end

%   Computer skill level setzen
switch app.SkillButtonGroup.SelectedObject.Text
    case 'leicht'
        PLAYER_SPEED_COMP= 0.01;
        scoreSkillFactor= 100;
    case 'mittel'
        PLAYER_SPEED_COMP= 0.02;
        scoreSkillFactor= 200;
    case 'schwer'
        PLAYER_SPEED_COMP= 0.03;
        scoreSkillFactor= 300;
end

%   Anzahl Runden übergeben
rounds= app.RoundsSpinner.Value;
roundsPlayed= 1;

%   Player Speed
PLAYER_SPEED= 0.02;

%   Spieler 1 Name übergeben
playerRightName= app.NickPlayer1EditField.Value;


%%  Figure für Spielfeld definieren
%   Quelle: https://ch.mathworks.com/help/matlab/ref/matlab.ui.figure-properties.html

fig= figure;            % Figure erstellen
fig.Name= 'Pong';       % Figure Name setzen
fig.NumberTitle= 'off'; % Figure Nummer ausblenden
fig.MenuBar='none';     % Menubar ausblenden
fig.Color= 'k';         % Hintergrundfarbe setzen

SCREEN_SCALING_FACTOR= 1;                   % Windows 10 Skalierungsfaktor
FIGURE_HEIGHT= 1000/SCREEN_SCALING_FACTOR;  % Figure Höhe definieren
FIGURE_WIDTH= 1920/SCREEN_SCALING_FACTOR;   % Figure Breite definieren

%   Bildschirm Auflösung ermitteln
%   Quelle: https://ch.mathworks.com/matlabcentral/fileexchange/31177-dave-s-matlab-pong
screenSize= get(0,'ScreenSize');
%   screenSize ist ein Vektor mit 4 Elementen: [links, unten, breite, höhe]
fig.OuterPosition= [(screenSize(3)-FIGURE_WIDTH)/2, (screenSize(4)-FIGURE_HEIGHT)/2, FIGURE_WIDTH, FIGURE_HEIGHT];
%   Veränderung der Figurgrösse verhindern.
fig.Resize= 'off';

%   Achsen erstellen mit normalized für besseres handling bei
%   unterschiedlicher Auflösung.
axes('units', 'normalized', 'position', [0 0 1 1], 'xtick', [], 'ytick', [], 'color', 'k', 'xlim', [0 1], 'ylim',[0 1]);


%%  Ball auf dem Spielfeld erstellen
%   Quelle: https://ch.mathworks.com/matlabcentral/fileexchange/31177-dave-s-matlab-pong

%   Ball Marker für Plot definieren
BALL_MARKER_SIZE= 20;
BALL_COLOR= 'w';
BALL_OUTLINE= 'w';
BALL_SHAPE= 'o';

%   Radius vom Spielball berechnen
BALL_RADIUS= 1/FIGURE_WIDTH+1/FIGURE_WIDTH*BALL_MARKER_SIZE/2+0.0005;

%   Ball ploten
ball= plot(0.5,0.5);
set(ball, 'Marker', BALL_SHAPE);
set(ball, 'MarkerEdgeColor', BALL_OUTLINE);
set(ball, 'MarkerFaceColor', BALL_COLOR);
set(ball, 'MarkerSize', BALL_MARKER_SIZE);

%   Ball Richtung für die erste Runde definieren.
%   Ziel ist einen Winkel von max. 45° zum Spieler.
%   In Richtung linker Spieler
if rand >= 0.5
    y= rand;
    x= max(y,rand);
    ballVector= [-x, -y];
    
    %   In Richtung rechter Spieler
else
    y= rand;
    x= max(y,rand);
    ballVector= [x, y];
end

%   Ball Startgeschwindigkeit setzen
BALL_START_SPEED= 0.0075;
ballSpeed= BALL_START_SPEED;

%   Flag falls Ball an Spieler vorbeigeht setzen
ballPassedPlayer= false;

%   Hintergrund erneut schwarz setzen wegen ball Plot. Achsenmarkierungen
%   ausschalten.
set(gca,'Color','k','xtick', [], 'ytick', []);


%%  Spieler auf dem Spielfeld erstellen
%   Quelle: https://ch.mathworks.com/matlabcentral/fileexchange/12918-pong--a-tribute-to-the-game-created-by-atari-inc

%   Bewegungsrichtung für Start setzen, 0=stillstand, 1=hoch, -1=runter
playerLeftV= 0;
playerRightV= 0;

%   Linker Spieler zeichnen als polygon
playerLeft= patch([0.05 0.07 0.07 0.05], [0.45 0.45 0.55 0.55], [0 0 0 0], 'facecolor', 'w', 'edgecolor', 'w');
%   Y-Vektor von linkem Spieler erstellen
yd_playerLeft= get(playerLeft, 'ydata');

%   Rechter Spieler zeichnen als polygon
playerRight= patch([0.95 0.93 0.93 0.95], [0.45 0.45 0.55 0.55], [0 0 0 0], 'facecolor', 'w', 'edgecolor', 'w');
%   Y-Vektor von rechtem Spieler erstellen
yd_playerRight= get(playerRight, 'ydata');


%%  Ränder oben und unten im Spielfeld zeichnen
%   Quelle: https://ch.mathworks.com/matlabcentral/fileexchange/12918-pong--a-tribute-to-the-game-created-by-atari-inc

%   Rand oben als polygon zeichnen
patch([0 1 1 0], [0.95 0.95 1 1], [0 0 0 0], 'facecolor', 'w', 'edgecolor', 'w', 'handlevisibility', 'off');

%   Rand unten als polygon zeichnen
patch([0 1 1 0], [0 0 0.05 0.05], [0 0 0 0], 'facecolor', 'w', 'edgecolor', 'w', 'handlevisibility', 'off');


%%  Scores, Spielernamen und weitere Texte setzen
%   Quellen:    https://ch.mathworks.com/matlabcentral/fileexchange/12918-pong--a-tribute-to-the-game-created-by-atari-inc
%               https://ch.mathworks.com/matlabcentral/answers/251996-how-to-insert-space-between-strings-while-doing-strcat

%   Anzeige gewonnene Runden pro Spieler setzen
playerLeftScore= 0;
playerLeftScoreText= text(0.06 , 0.975, num2str(playerLeftScore), 'horizontalAlignment', 'center');
playerRightScore= 0;
playerRightScoreText= text(0.94 , 0.975, num2str(playerRightScore),'horizontalAlignment', 'center');

%   Anzeige Runden setzen
textRounds= strcat( 'Round', 32, num2str(roundsPlayed), ' /', 32, num2str(rounds));
t_rounds= text(0.5, 0.975, textRounds, 'horizontalAlignment', 'center');

%	Anzeige Spielernamen setzen
t_player1= text(0.975, 0.025, playerRightName, 'horizontalAlignment', 'right');
t_player2= text(0.025, 0.025, playerLeftName, 'horizontalAlignment', 'left');

%   Anzeige Spiel pausiert, unsichtbar bis Spiel pausiert wird
t_pause= text(0.5, 0.5, 'game paused','visible','off','horizontalAlignment', 'center');

%   Text Optionen (Schriftart, Grösse usw.) setzen
set([playerLeftScoreText playerRightScoreText t_rounds t_player1 t_player2], 'fontname', 'consolas', 'fontsize', 30, 'color', 'k');
set(t_pause, 'fontname', 'consolas', 'fontsize', 30, 'color', 'w');

%   Text countdown setzen
countdown_t= text(0.5, 0.5, '0', 'visible', 'off', 'horizontalAlignment', 'center', 'color', 'w', 'fontname', 'consolas', 'fontsize', 300);

%   Texte estellen für Gewinner und Highscore
t_winner= text(0.5, 0.5, 'nobody','visible', 'off', 'horizontalAlignment', 'center', 'color', 'w', 'fontname', 'consolas', 'fontsize', 30);
t_highscore= text(0.5, 0.35, '0','visible', 'off', 'horizontalAlignment', 'center', 'color', 'w', 'fontname', 'consolas', 'fontsize', 30);


%%  Listeners registrieren und Callback Funktionen definieren
%   Quelle: https://ch.mathworks.com/matlabcentral/fileexchange/31177-dave-s-matlab-pong
%   KeyPressFcn - Taste wird gedrückt listener
%   KeyReleaseFcn - Taste wird losgelassen listener
%   DeleteFcn - function wird beendet listener
set(fig,'KeyPressFcn',@keyDown, 'KeyReleaseFcn', @keyUp, 'DeleteFcn', @closeFigure);


%%  Callback Funktion für KeyPressFcn
%   Quelle: https://ch.mathworks.com/matlabcentral/fileexchange/31177-dave-s-matlab-pong
%   Zweck: Die Funktion wertet die Events vom Listener KeyPressFcn aus.
%   Die Tasten setzen verschieden flags oder lösen verschiendene Funktionen
%   aus.

    function keyDown(~,event)
        switch event.Key
            case 'w'
                playerLeftV= 1;    % Spieler 2 rauf
            case 's'
                playerLeftV= -1;   % Spieler 2 runter
            case 'uparrow'
                playerRightV= 1;   % Spieler 1 rauf
            case 'downarrow'
                playerRightV= -1;  % Spieler 1 runter
            case 'p'
                pauseGame();       % Spiel pausieren
            case 'q'
                quit= true;        % Spiel beenden
        end
    end


%%  Callback Funktion für KeyReleaseFcn
%   Quelle: https://ch.mathworks.com/matlabcentral/fileexchange/31177-dave-s-matlab-pong
%   Zweck: Die Funktion wertet die Events vom Listener KeyReleaseFcn aus.
%   Werden die Tasten losgelassen halten die Spieler an.

    function keyUp(src,event)
        switch event.Key
            case 'w'
                if playerLeftV == 1
                    playerLeftV= 0;    % Spieler 2 anhalten
                end
            case 's'
                if playerLeftV == -1
                    playerLeftV= 0;    % Spieler 2 anhalten
                end
            case 'uparrow'
                if playerRightV == 1
                    playerRightV= 0;   % Spieler 1 anhalten
                end
            case 'downarrow'
                if playerRightV == -1
                    playerRightV= 0;   % Spieler 1 anhalten
                end
        end
    end


%%  Callback Funktion für DeleteFcn
%   Quelle: https://ch.mathworks.com/help/matlab/creating_guis/write-callbacks-using-the-programmatic-workflow.html
%   Zweck: Führt Aufgaben aus vor dem löschen der Figure(Spielfeld).

    function closeFigure(src,event)
        %   App wieder sichtbar machen.
        app.Pong.Visible= 'on';
        %   Highscore Excel-File einlesen und im Highscoremenü anzeigen.
        app.UITable.Data= pongHighscoreRead(app.DatabaseName);
    end


%%  Funktion Spieler bewegen
%   Zweck: Neue Positionen der Spieler auf dem Spielfeld berechnen.

    function movePlayers
        
        % Neue Position Spieler 1 setzen
        yd_playerRight= yd_playerRight + (PLAYER_SPEED * playerRightV);
        
        % Neue Position Spieler 2 setzen
        % 1 Player Modus
        if onePlayerMode
            calcComputer;
            yd_playerLeft= yd_playerLeft + (PLAYER_SPEED_COMP * playerLeftV);
        % 2 Player Modus
        else
            yd_playerLeft= yd_playerLeft + (PLAYER_SPEED * playerLeftV);
        end
        
        % Spieler 1 innerhalb vom Spielfeld behalten
        % oben
        if yd_playerRight(3) > 0.95
            yd_playerRight= [0.85 0.85 0.95 0.95];
        % unten
        elseif yd_playerRight(1) < 0.05
            yd_playerRight= [0.05 0.05 0.15 0.15];
        end
        
        % Spieler 2 innerhalb vom Spielfeld behalten
        % oben
        if yd_playerLeft(3) > 0.95
            yd_playerLeft= [0.85 0.85 0.95 0.95];
            % unten
        elseif yd_playerLeft(1) < 0.05
            yd_playerLeft= [0.05 0.05 0.15 0.15];
        end
        
    end


%%  Funktion Computer Spieler bewegen
%   Zweck: Die neue Position des Computer Spielers wird berechnet.

    function calcComputer
        % Berechnung Mitte vom aktuellen Spielerbalken.
        playerLeftCenter= (playerLeft.YData(3)-playerLeft.YData(1))/2+playerLeft.YData(1);
        
        % Computer Spieler nach oben bewegen
        if playerLeftV == 0 && (ball.YData + BALL_RADIUS) > playerLeft.YData(3)
            playerLeftV= 1;
            
            % Computer Spieler nach unten bewegen
        elseif playerLeftV == 0 && (ball.YData - BALL_RADIUS) < playerLeft.YData(1)
            playerLeftV= -1;
            
            % Computer Spieler anhalten
        elseif playerLeftV == 1 && (ball.YData - BALL_RADIUS) < playerLeftCenter
            playerLeftV= 0;
            
            % Computer Spieler anhalten
        elseif playerLeftV == (-1) && (ball.YData + BALL_RADIUS) > playerLeftCenter
            playerLeftV= 0;
            
        else
            % Richtung bleibt
        end
    end


%%  Funktion Ball bewegen
%   Zweck: Neue Position des Balls berechnen. Falls Berührungen stattfinden
%   nötige Scritte ausführen.

    function moveBall
        
        % Ball Vektor normieren
        ballVector= ballVector ./ (sqrt(ballVector(1)^2 + ballVector(2)^2));
        
        % Neue X-Position vom Ball berechnen
        newX= ball.XData + (ballSpeed * ballVector(1));
        
        % Neue Y-Position vom Ball berechnen
        newY= ball.YData + (ballSpeed * ballVector(2));
        
        % Erstellung lineare Funktion Steigung zwischen neuer und alten Position berechnen
        m= (newY - ball.YData) / (newX - ball.XData);
        b= ball.YData - m * ball.XData;
        % Punkt vom Ball berechnen auf Höhe vom Spieler 2
        yLeft= m * playerLeft.XData(2) + b;
        % Punkt vom Ball berechnen auf Höhe vom Spieler 1
        yRight= m * playerRight.XData(2) + b;
        
        
        % Check: Ball trift Spieler 2
        % Überprüfung ob der Ball nicht am Spieler vorbei ist und
        if ~ballPassedPlayer && (newX - BALL_RADIUS) < playerLeft.XData(2) && (playerLeft.YData(2) - BALL_RADIUS) < yLeft && yLeft < (playerLeft.YData(3) + BALL_RADIUS)
            %         disp('Hit Left')
            ballSpeed= ballSpeed+0.0005;
            newX= playerLeft.XData(2)+BALL_RADIUS;
            
            playerLeftCenter= (playerLeft.YData(3)-playerLeft.YData(1))/2+playerLeft.YData(1);
            ballVector(2)= 40*(ball.YData-playerLeftCenter);
            ballVector(1)= sign(ballVector(1))*-1;
            
            % Check: Ball trift Spieler 1
            % Überprüfung ob der Ball nicht am Spieler vorbei ist und
        elseif ~ballPassedPlayer && (newX + BALL_RADIUS) > playerRight.XData(2) && (playerRight.YData(2) - BALL_RADIUS) < yRight && yRight < (playerRight.YData(3) + BALL_RADIUS)
            ballSpeed= ballSpeed+0.0005;
            newX= playerRight.XData(2)-BALL_RADIUS;
            
            playerRightCenter= (playerRight.YData(3)-playerRight.YData(1))/2+playerRight.YData(1);
            ballVector(2)= 40*(ball.YData-playerRightCenter);
            ballVector(1)= sign(ballVector(1))*-1;
            
            % Check: Ball trifft rechte oder linke Wand
            % Überprüfung ob der Ball nicht am Spieler vorbei ist und
        elseif (newX > 1-BALL_RADIUS || newX < BALL_RADIUS)
            % Spieler 1 gewinnt die Runde
            if newX < BALL_RADIUS
                playerRightScore= playerRightScore+1;
                set(playerRightScoreText, 'string', num2str(playerRightScore));
                [newX,newY]=startNewRound(1);
                ballPassedPlayer= false;
                % Spieler 2 gewinnt die Runde
            else
                playerLeftScore= playerLeftScore+1;
                set(playerLeftScoreText, 'string', num2str(playerLeftScore));
                [newX,newY]=startNewRound(2);
                ballPassedPlayer= false;
            end
            
            % überprüfen ob ein Spieler gewonnen hat
            checkForWinner();
            
            % neue Runde anzeigen
            roundsPlayed= roundsPlayed+1;
            textRounds= strcat( 'Round', 32, num2str(roundsPlayed), ' /', 32, num2str(rounds));
            set(t_rounds,'string',textRounds);
            
            % Check: Ball trifft Wand oben
        elseif (newY > 0.95-BALL_RADIUS)
            newY= 0.95-BALL_RADIUS;
            ballVector(2)= ballVector(2)*(-1);
            
            % Check: Ball trifft Wand unten
        elseif (newY < 0.05+BALL_RADIUS)
            newY= 0.05+BALL_RADIUS;
            ballVector(2)= ballVector(2)*(-1);
            
        else
            % keine Berührungen
            
        end
        
        % Ball an die neue Position setzen
        ball.XData= newX;
        ball.YData= newY;
        
        % Flag ballPassedPlayer setzten falls der Ball an der vorderseite
        % eines Spielers vorbei ist. Wichtig für die nächste Berechnung.
        if ~ballPassedPlayer && ball.XData - BALL_RADIUS < playerLeft.XData(2) || ball.XData + BALL_RADIUS > playerRight.XData(2)
            ballPassedPlayer= true;
        else
            %unternimm nichts
        end
        
    end


%%  Funktion neue Runde starten
%   Zweck: Neue Runde initialisieren, Geschwindigkeit des Balls rücksetzen,
%   Startrichtung vom Ball bestimmmen.

    function [newX,newY]= startNewRound(winner)
        
        % Geschwindigkeit des Balls rücksetzen
        ballSpeed= BALL_START_SPEED;
        
        % Auswertung Gewinner der Runde
        switch winner
            
            % Gewinner Spieler 1
            case 1
                % Ball in die Mitte setzen
                newX= 0.5; newY= 0.5;
                % Ball in Richtung Spieler 2 nach oben
                if rand >= 0.5
                    y= rand;
                    x= max(y,rand);
                    ballVector= [-x, y];
                % Ball in Richtung Spieler 2 nach unten
                else
                    y= rand;
                    x= max(y,rand);
                    ballVector= [-x, -y];
                end
                
            % Gewinner Spieler 2
            case 2
                % Ball in die Mitte setzen
                newX= 0.5; newY= 0.5;
                % Ball in Richtung Spieler 1 nach oben
                if rand >= 0.5
                    y= rand;
                    x= max(y,rand);
                    ballVector= [x, y];
                % Ball in Richtung Spieler 1 nach unten
                else
                    y= rand;
                    x= max(y,rand);
                    ballVector= [x, -y];
                end
        end
    end


%%  Funktion Prüfen ob Gewinner vorhanden
%   Zweck: Prüfen ob die Anzahl definierte Runden gespielt wurden, falls ja
%   stellt Gewinner fest und zeigt diesen an. Anschliessend wird das flag
%   zum beenden des Spiels gesetzt. Wurde im Spielmodi "1 Player"
%   gespielt wird der Highscore anzeigt und in das Excelfile geschrieben.

    function checkForWinner
        if roundsPlayed == rounds
            
            % Spieler 1 gewinnt anzeigen
            if playerRightScore > playerLeftScore
                set(t_winner, 'string',strcat(playerRightName, 32, 'WINS!'),'visible', 'on');
                
            % Spieler 2 gewinnt anzeigen
            elseif playerRightScore < playerLeftScore
                set(t_winner, 'string',strcat(playerLeftName, 32, 'WINS!'),'visible', 'on');
                
            % unentschieden anzeigen
            else
                set(t_winner, 'string','DRAW!','visible', 'on');
                
            end
            
            % Falls 1 Spieler Modus Highscore in Excelfile eintragen.
            if onePlayerMode
                % Highscore berechnen
                highscore= playerRightScore * scoreSkillFactor;
                % Gewinner anzeigen
                set(t_highscore, 'string', strcat(playerRightName, 32, 'Highscore:', 32, num2str(highscore)),'visible', 'on');
                pongHighscoreWrite(app.DatabaseName, playerRightName, highscore);
            else
                % unternimmt nichts
            end
            
            % Gewinner für 3 Sekunden anzeigen
            pause(3);
            
            % Flag Spiel beenden setzen
            quit= true;
            
        else
            % Spiel fortsetzen
            
        end
    end


%%  Funktion Spielfeld aktualisieren
%   Zweck: Spielfeld aktualisieren und neu zeichnen.

    function refreshScreen
        % X und Y-Position vom Ball setzen
        set(ball, 'XData', ball.XData, 'YData', ball.YData);
        
        % Y-Positionen von beiden Spieler setzten, X bleibt immer gleich
        set(playerLeft, 'ydata', yd_playerLeft);
        set(playerRight, 'ydata', yd_playerRight);
        
        % Gemäss Profiler der Speedkiller schlechthin, drawnow aktualisiert
        % die figure
        drawnow;
    end


%%	Funktion Spiel pausieren
%   Zweck: Flag paused setzen und entsetzen, sowie Text "game paused"
%   anzeigen.

    function pauseGame
        if ~paused
            paused= true;
            set(t_pause, 'visible', 'on');
        else
            paused= false;
            set(t_pause, 'visible', 'off');
        end
    end


%% Countdown vor Spielbeginn anzeigen
%   Startpunkt countdown definieren
countdown= 3;

%   Countdown vor Spielbeginn anzeigen
for countdown=countdown:-1:1
    set(countdown_t, 'string', num2str(countdown), 'visible', 'on');
    pause(1);
end

%   Text countdown wieder unsichtbar machen
set(countdown_t, 'visible', 'off');


%%  Main Spiel-Loop
%   Hier wird der main loop ausgeführt der zyklisch die wichtigsten
%   Funktionen für den Spielablauf ausführt.

%   main loop vom engine
while ~quit
    if paused
        % Ausführung unterbrechen bis eine Taste gedrückt wird
        waitforbuttonpress;
    else
        movePlayers;
        moveBall;
        refreshScreen;
    end
end

% Der main loop wurde durch Flag "quit" beendet, Figure wird geschlossen 
% und löst Callback Funktion closeFigure() aus.
close(gcf);

end