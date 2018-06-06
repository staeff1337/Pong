function   pongHighscoreWrite(FileName,Name,Score)


DataBaseCnt=convertCharsToStrings(num2str(length(xlsread(FileName))+1)); %Ermittelt die nächste freie Zeile in der Excel Datei.

Acolum=strcat('A',DataBaseCnt);                             %Erstellt ein String mit dem Excel Index der Zelle in der der neue Nickname geschrieben wird.
Bcolum=strcat('B',DataBaseCnt);                             %Erstellt ein String mit dem Excel Index der Zelle in der der neue Score geschrieben wird.
xlswrite(FileName,cellstr(Name),'Sheet1',Acolum);           %Schreibt den Nicknamen in die entsprechende Zelle vom Excel File        
xlswrite(FileName,Score,'Sheet1',Bcolum);                   %Schreibt den Score in die entsprechende Zelle vom Excel File   

end


