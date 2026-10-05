% Facts
in_room(monkey).
in_room(chair).
in_room(banana).
clear(monkey).
tall(chair).
can_climb(monkey, chair).
can_push(monkey, chair).
at(monkey, door).
at(chair, window).
at(bananas, center).
clever(monkey).

% Rules
moved_under(chair, bananas) :-
    can_push(monkey, chair),
    at(bananas, center).

get_on(monkey, chair) :-
    can_climb(monkey, chair).

near(monkey, bananas) :-
    moved_under(chair, bananas),
    get_on(monkey, chair).

can_reach(monkey, bananas) :-
    clever(monkey),
    near(monkey, bananas).