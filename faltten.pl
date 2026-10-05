% Flatten a list

flatten_list([], []).

flatten_list([H|T], FlatList) :-
    is_list(H),
    flatten_list(H, NewH),
    flatten_list(T, NewT),
    append(NewH, NewT, FlatList).

flatten_list([H|T], [H|FlatList]) :-
    \+ is_list(H),
    flatten_list(T, FlatList).