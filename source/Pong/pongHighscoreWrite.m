function   pongHighscoreWrite(FileName,Name,Score)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

         fid = fopen(FileName,'a');    %csv Datei öffnen im Modus 'a' für Anhängen von Inhalt.
         fprintf(fid,'%s \t %d', Name, Score);
         fprintf(fid, '\n' );
         fclose(fid); 
        
end

