%Not final submission
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * %
% Project 2 - Fill in Puzzle Implementation for COMP90048: Declarative Programming, Semester 2 2020.
% By Abhishek Anand - Student ID: 1005884
% 
% This project solves fill in puzzles by reconstructing the associated squares in the 'Puzzle', then It
% tries out the words from the 'WordList' until a suitable solution is found, then the solution is
% returned.
%
%
% To start of, we build a set of suitable squares(S1) using the 'SquareUtil' function, transpose the puzzle,
% and do the same with the transposed puzzle(S2); and then join both the suitable squares(From puzzle and
% transposed puzzle) as Square.
% 
% We then sort the input Wordlist and Square( To reduce the search needed) , and send it to be processed into
% word - Square combos and put into a suitable square in the puzzle using 'fillUtil'. We make a list containing
% the number of possible words in a square, and 'fillUtil' tries to put the given word into the correct square,
% failing which it will try the next square and so on. 
% 
% Once all slots are filled, the Puzzle and the given WordList are printed.
% 
% This program has been implemented with tail recursion wherever possible with suitable optimizations, but it
% is not over emphasized. Comments have been added with each function to summarise their function.
%
% * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * %

:- ensure_loaded(library(clpfd)).
:- set_prolog_flag(answer_write_options,
                   [ quoted(true),
                     portray(true),
                     spacing(next_argument)
                   ]).
:- use_module(library(pairs)).

puzzle_solution(Puzzle, WordList) :-

	squareUtil(Puzzle,Square),
	sortbylen(Square,SortedSquare),!,
	sortbylen(WordList,SortedWordList),!,
	fillUtil(SortedSquare, SortedWordList).


squareUtil(Puzzle,Square):-
	squareHelper(S1,Puzzle),
	transpose(Puzzle,TPuzzle),
	squareHelper(S2,TPuzzle),
	append(S1,S2,Square).

same_chars([],_).
same_chars(Item,List):-
	Item = [_|Last],
	List = [_|LastLists],
	same_chars(Last,LastLists).

canJoin(W1, S1) :-
	same_length(W1,S1),
	same_chars(W1,S1).

join(X2, X2).

getsquares([], Currentsquare, Square) :-
    length(Currentsquare, N),
    (   N =< 1
    ->  Square = []
    ;   Square = [Currentsquare]
    ).

getsquares([Var|Vars], Currentsquare, Square) :-
    (   Var == '#'
    ->	length(Currentsquare, N),
        (   N > 1
        ->  Square = [Currentsquare|S1]
        ;   Square = S1
        ),
        getsquares(Vars, [], S1)
	;  append(Currentsquare, [Var], Currentsquare1),
        getsquares(Vars, Currentsquare1, Square)  
    ).



squareHelper([], []).
squareHelper(Square,RowVar) :-
	RowVar = [Row|Rows],
    getsquares(Row, [], S1),
    squareHelper(S2,Rows),
    append(S1, S2, Square).

sortbylen(WordList, WbyLen) :-
    map_list_to_pairs(length, WordList, Pairs),
    sort(1, @>=, Pairs, FinList),
    pairs_values(FinList, WbyLen).


fillUtil([], _).
fillUtil(Item, WordList) :-
	Item = [Square|S2],
	
	combinationCheck(Square, WordList, 0, Matches),

	comboUtil(S2, WordList, Matches, Square, BestMatch, [], New), 

	
	
	filler(BestMatch, WbyLen, [], NewWordList),
	
	fillUtil(New, WbyLen).

filler(Square, [Word|WordList], NewWordListIn, NewWordListOut) :-
	
	join(Square, Word),
	append(WordList, NewWordListIn, NewWordListOut);

	append(NewWordListIn, [Word], NewWordListTemp),
	filler(Square, WordList, NewWordListTemp, NewWordListOut).



comboUtil([], _, Least, Current, Current,Input, Input) :-
	Least > 0.
comboUtil(Var, WordList, Least, Current,
	BestMatch, Input, Output) :-
	
	 Var = [Square|OtherSquares],
	combinationCheck(Square, WordList, 0, Total),
	(	Total >= Least
	->	append(Input, [Square], InputTemp),
		comboUtil(OtherSquares, WordList, Least, Current,
			BestMatch, InputTemp, Output)

	;	append(Input, [Current], InputTemp),
		comboUtil(OtherSquares, WordList, Total, Square, BestMatch,
			InputTemp, Output)	
		
	).


combinationCheck(_, [], CurrentMatches, CurrentMatches).
combinationCheck(Square, [Word|OtherWords], CurrentMatches, Total) :-
	(	canJoin(Word, Square)
	->	combinationCheck(Square, OtherWords, CurrentMatches+1, Total)
	;	combinationCheck(Square, OtherWords, CurrentMatches, Total)
	).
