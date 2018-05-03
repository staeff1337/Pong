function []= pongengine(app)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
fig=figure
plot(3,3)

title (app.NickPlayer2EditField.Value)
set(fig,'KeyPressFcn',@keyDown)

    function keyDown(src,event)
        switch event.Key
            case 'q'
                app.Pong.Visible='on'
                close(gcf)
        end
    end

end

