% N-Queen Problem

n_queens(N, Solution) :-
    range(1, N, Rows),
    permutation(Rows, Solution),
    safe(Solution),
    write(Solution), nl.

% Generate numbers from 1 to N
range(N, N, [N]).

range(Start, N, [Start|Rest]) :-
    Start < N,
    Next is Start + 1,
    range(Next, N, Rest).

% Check that all queens are safe
safe([]).

safe([Queen|Queens]) :-
    check(Queen, Queens, 1),
    safe(Queens).

% Check that queens do not attack each other
check(_, [], _).

check(Q, [Q1|Queens], Distance) :-
    Q =\= Q1,
    abs(Q - Q1) =\= Distance,
    NextDistance is Distance + 1,
    check(Q, Queens, NextDistance).