function []= pongengine(app)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
fig=figure
plot(3,3)

title (app.NickPlayer2EditField.Value)
set(fig,'KeyPressFcn',@keyDown)  %Weisst die KeyPressFcn der Figur zu

    function keyDown(src,event)  %Wertet den event Key aus.
        switch event.Key
            case 'q'             %Taste q
                
                %app.Pong.Visible='on'
                close(gcf)       %schliesst die Figur
        end
    end
set(fig, 'DeleteFcn', @figureclose) 

    function figureclose(src,event)
        app.Pong.Visible='on'
        
    end

end

