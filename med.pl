% ==========================================
% PRESCRIPTION DRUG-INTERACTION
% WARNING SYSTEM
% ==========================================

% -------- FACTS --------

% Medicines
medicine(paracetamol).
medicine(aspirin).
medicine(ibuprofen).
medicine(warfarin).
medicine(amoxicillin).
medicine(metformin).

% Drug interactions
interacts(warfarin, aspirin).
interacts(warfarin, ibuprofen).
interacts(aspirin, ibuprofen).

% Interaction severity
severity(warfarin, aspirin, high).
severity(warfarin, ibuprofen, high).
severity(aspirin, ibuprofen, moderate).


% -------- RULES --------

% Check interaction in either direction
drug_interaction(X, Y) :-
    interacts(X, Y).

drug_interaction(X, Y) :-
    interacts(Y, X).


% Find severity
interaction_severity(X, Y, Level) :-
    severity(X, Y, Level).

interaction_severity(X, Y, Level) :-
    severity(Y, X, Level).


% Generate warning
warning(X, Y) :-
    drug_interaction(X, Y),
    interaction_severity(X, Y, Level),
    write('WARNING: Drug interaction detected!'), nl,
    write('Medicine 1: '), write(X), nl,
    write('Medicine 2: '), write(Y), nl,
    write('Severity: '), write(Level), nl,
    write('Please consult a qualified healthcare professional.'), nl.


% No interaction
safe(X, Y) :-
    \+ drug_interaction(X, Y),
    write('No known interaction found between '),
    write(X),
    write(' and '),
    write(Y),
    write('.'),
    nl.