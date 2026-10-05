% Diabetes Facts

disease(diabetes).

symptom(sugar).

symptom(thirst).

thirst(john).

frequent_urination(john).

% Diabetes Rule

diabetes(X) :-
    thirst(X),
    frequent_urination(X).

% High Sugar Rule

high_sugar(X) :-
    diabetes(X).