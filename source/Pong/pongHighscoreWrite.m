function   pongHighscoreWrite(FileName,Name,Score)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

DataBaseCnt=convertCharsToStrings(num2str(length(xlsread(FileName))+1));

Acolum=strcat('A',DataBaseCnt);
Bcolum=strcat('B',DataBaseCnt);
xlswrite(FileName,cellstr(Name),'Sheet1',Acolum);
xlswrite(FileName,Score,'Sheet1',Bcolum);

        
end


