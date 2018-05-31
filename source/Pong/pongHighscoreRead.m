function [HighscoreTabelData] = pongHighscoreRead(FileName)






          
          
 
[pongHighscoreDatabaseScore,pongHighscoreDatabaseName]=xlsread(FileName,'sheet1') ;
 

  name=char(pongHighscoreDatabaseName); 
        score=pongHighscoreDatabaseScore; 
       highscoretable=table(name,score); 
       sortmap=sortrows(highscoretable,'score', 'descend'); 



    HighscoreTabelData={1,char(sortmap{1,1}),sortmap{1,2};
                        2,char(sortmap{2,1}),sortmap{2,2};
                        3,char(sortmap{3,1}),sortmap{3,2};
                        4,char(sortmap{4,1}),sortmap{4,2};
                        5,char(sortmap{5,1}),sortmap{5,2};
                        6,char(sortmap{6,1}),sortmap{6,2};
                        7,char(sortmap{7,1}),sortmap{7,2};
                        8,char(sortmap{8,1}),sortmap{8,2};
                        9,char(sortmap{9,1}),sortmap{9,2};
                        10,char(sortmap{10,1}),sortmap{10,2};
                        };

    
end

