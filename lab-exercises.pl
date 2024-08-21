% NOTE! These predicates use `languages-database-predicates.pl`.

% `isChild/2`
isChild(X,Y) :- isParent(Y,X).


% `isSpoken/1`
isSpoken(X) :- isLanguage(X), \+ isExtinct(X).


% `isSibling/2`
isSibling(X,Y) :-
    isParent(Z,X),
    isParent(Z,Y),
    X \= Y.


% `isCousin/2`
isCousin(X,Y) :-
    isParent(A,X),
    isParent(B,Y),
    isSibling(A,B),
    X \= Y.


% `isGrandparent/2`
isGrandparent(X,Y) :- isParent(X,Z), isParent(Z,Y).


% `isAncestor/2`
isAncestor(X,Y) :- isParent(X,Y).
isAncestor(X,Y) :- isParent(X,Z), isAncestor(Z,Y).


% `isDescendant/2`
isDescendant(X,Y) :- isChild(X,Y).
isDescendant(X,Y) :- isChild(X,Z), isDescendant(Z,Y).


% `shareAncestor/3`
shareAncestor(X,Y,Z) :- isAncestor(Z,X), isAncestor(Z,Y), X \= Y.


% `shareMostRecentAncestor/3`
shareMostRecentAncestor(X,Y,A) :-
    shareAncestor(X,Y,A),
    \+ (
        isParent(A,B),
        shareAncestor(X,Y,B)
    ).


% `hasSize/2`
hasSize([],0).
hasSize([_|T],N) :- hasSize(T,M), N is M + 1.


% `contains/2`
contains([H|_],H).
contains([H|T],X) :- H \= X, contains(T,X).


% `isConcatenated/3`
isConcatenated([],L,L).
isConcatenated([X|A],L,[X|B]) :- isConcatenated(A,L,B).


% `areLanguagesRelated/2`
areLanguagesRelated([],[]).
areLanguagesRelated([languages(X,Y)|A],[areRelated(X,Y)|B]) :-
    shareMostRecentAncestor(X,Y,_),
    areLanguagesRelated(A,B).
areLanguagesRelated([languages(X,Y)|A],[notRelated(X,Y)|B]) :-
    \+ shareMostRecentAncestor(X,Y,_),
    areLanguagesRelated(A,B).
areLanguagesRelated([X|A],B) :- % Challenge exercise.
    X \= areRelated(_,_),
    areLanguagesRelated(A,B).


% NOTE! Make sure to use `languages-database-lists.pl` for these predicates.


% `hasDescendants/2`.
hasDescendants(X,[X])   :- \+ isParent(X,_).
hasDescendants(X,[X|Y]) :-    isParent(X,Z), haveDescendants(Z,Y).

% `haveDescendants/2`. Auxiliary predicate for `hasDescendants/2`.
haveDescendants([],[]).
haveDescendants([X|Y],Z) :- hasDescendants(X,A), haveDescendants(Y,B), isConcatenated(A,B,Z).


% `hasSpokenDescendants/2`.
hasSpokenDescendants(X,0) :- \+ isParent(X,_),    isExtinct(X).
hasSpokenDescendants(X,1) :- \+ isParent(X,_), \+ isExtinct(X).
hasSpokenDescendants(X,N) :-    isParent(X,Y),    isExtinct(X), haveSpokenDescendants(Y,N).
hasSpokenDescendants(X,N) :-    isParent(X,Y), \+ isExtinct(X), haveSpokenDescendants(Y,M), N is M + 1.

% `haveSpokenDescendants/2`. Auxiliary predicate for `hasSpokenDescendants/2`.
haveSpokenDescendants([],0).
haveSpokenDescendants([X|Y],N) :- hasSpokenDescendants(X,A), haveSpokenDescendants(Y,B), N is A + B.
