% Generic Water Jug Problem
% Usage: find(Cap1, Cap2, Goal, Path).
% Example: find(4, 7, 3, P).

move(C1,_,(X,Y),(C1,Y)) :- X < C1.            % Fill jug1
move(_,C2,(X,Y),(X,C2)) :- Y < C2.            % Fill jug2
move(_,_,(X,_),(X,0)).                        % Empty jug2
move(_,_,(_,Y),(0,Y)).                        % Empty jug1

move(C1,_,(X,Y),(X1,Y1)) :-                   % Pour jug2 into jug1
    T is X + Y,
    (T > C1 -> X1 = C1, Y1 is T - C1 ; X1 = T, Y1 = 0).

move(_,C2,(X,Y),(X1,Y1)) :-                   % Pour jug1 into jug2
    T is X + Y,
    (T > C2 -> Y1 = C2, X1 is T - C2 ; Y1 = T, X1 = 0).

search(_,_,Goal,(Goal,_),Visited,Visited) :- !.
search(C1,C2,Goal,State,Visited,Path) :-
    move(C1,C2,State,Next),
    \+ member(Next,Visited),
    search(C1,C2,Goal,Next,[Next|Visited],Path).

find(C1,C2,Goal,Path) :-
    search(C1,C2,Goal,(0,0),[(0,0)],RevPath),
    reverse(RevPath,Path).