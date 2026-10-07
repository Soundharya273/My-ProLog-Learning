:- use_module(library(http/json)).
:- use_module(library(clpfd)).
:- use_module(library(readutil)).
:- prolog_load_context(directory, PrologDir),
   directory_file_path(PrologDir, 'validation.pl', ValidationFile),
   consult(ValidationFile).
:- prolog_load_context(directory, PrologDir),
   directory_file_path(PrologDir, 'rules.pl', RulesFile),
   consult(RulesFile).
:- prolog_load_context(directory, PrologDir),
   directory_file_path(PrologDir, 'allocation.pl', AllocationFile),
   consult(AllocationFile).

:- initialization(main, main).

main :-
    current_prolog_flag(argv, Args),
    ( member('--stdio', Args) -> stdio_loop ; halt(0) ).

stdio_loop :-
    read_line_to_string(user_input, Line),
    ( Line == end_of_file -> halt(0)
    ; catch(atom_json_dict(Line, Input, []), Error,
            (message_to_string(Error, Message), json_write_dict(current_output, _{success:false, message:Message}), nl, fail))
      -> solve_request(Input, Output),
         json_write_dict(current_output, Output, [width(0)]), nl, flush_output, stdio_loop
      ; stdio_loop
    ).

solve_request(Input, Output) :-
    validate_input(Input, Errors),
    ( Errors \= [] ->
        Output = _{success:false, message:"Input validation failed.", errors:Errors}
    ; calculate_plan(Input, Output)
    ).