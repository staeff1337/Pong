function   pongHighscoreWrite(FileName,Name,Score)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

         fid = fopen(FileName,'a');    %csv Datei �ffnen im Modus 'a' f�r Anh�ngen von Inhalt.
         fprintf(fid,'%s \t %d', Name, Score);
         fprintf(fid, '\n' );
         fclose(fid); 
        
end

