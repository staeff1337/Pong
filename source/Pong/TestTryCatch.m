%check for excel file

FileName= 'TestThisShit.xlsx';

try 
    xlsread(FileName,'sheet1');
catch exception
    disp(exception)
    A={'Pong!',0; 'Pong!',0; 'Pong!',0; 'Pong!',0; 'Pong!',0; 'Pong!',0; 'Pong!',0; 'Pong!',0; 'Pong!',0; 'Pong!',0};
    xlswrite(FileName,A)
%     xlswrite(FileName,cellstr('Pong!'),'sheet1','A1');
%     xlswrite(FileName,0,'sheet1','B1');
%     for i=1:1:9
%     pongHighscoreWrite(FileName,'Pong!',0)
%     end
end


    