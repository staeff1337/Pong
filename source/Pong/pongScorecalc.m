function [score] =pongScorecalc(cnt, skillclass)
    
    if skillclass=='leicht'
        score=cnt
    elseif skillclass=='mittel'
        score=cnt*2
    elseif skillclass=='schwer'
        score=cnt*3

 
       
    end
end
