       % Button pushed function: Button
          function ButtonPushed(app, event)
              figure('KeyPressFcn', @KeyFcn, 'Name', 'Key Press Demo'); % new traditional figure with interactive features
              set(0,'DefaultFigureVisible','on')
              plot(1:100);
              a=4
              function KeyFcn(~, ~)
                  plot(100:-1:1);   
                  a=2
              end
          end