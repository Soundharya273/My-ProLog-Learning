% Facts: connected(Node1, Node2, Cost)

connected(a, b, 2).
connected(a, c, 1).
connected(a, d, 3).
connected(b, e, 1).
connected(c, f, 2).
connected(c, g, 5).
connected(d, h, 6).
connected(e, h, 2).
connected(g, h, 1).

% BFS
bfs(Start, Goal, Path) :-
    search([[Start]], Goal, RevPath),
    reverse(RevPath, Path).

% Goal found
search([[Goal|Path]|_], Goal, [Goal|Path]).

% Continue searching
search([Path|Paths], Goal, Solution) :-
    extend(Path, NewPaths),
    append(Paths, NewPaths, Queue),
    search(Queue, Goal, Solution).

% Extend the current path
extend([Node|Path], NewPaths) :-
    findall(
        [NewNode, Node|Path],
        (
            connected(Node, NewNode, _),
            \+ member(NewNode, [Node|Path])
        ),
        NewPaths
    ).