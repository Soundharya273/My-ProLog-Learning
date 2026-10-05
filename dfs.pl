% Facts
connected(a, b).
connected(a, c).
connected(b, d).
connected(b, e).
connected(c, f).
connected(c, g).
connected(d, h).
connected(e, h).
connected(g, h).
connected(a, h).

% Depth First Search
dfs(Start, Goal, Path) :-
    search(Start, Goal, [Start], RevPath),
    reverse(RevPath, Path).

% Goal reached
search(Goal, Goal, Visited, Visited).

% Continue searching
search(Node, Goal, Visited, Path) :-
    connected(Node, Next),
    \+ member(Next, Visited),
    search(Next, Goal, [Next|Visited], Path).