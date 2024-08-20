/*
    1 Database: facts. Propositional logic.
    Introduce queries.
    Closed-world?
*/

/*
    2 Predicates. First-order logic.
    Extend queries: introduce variables, unification.
    Ground vs. non-ground?
*/


% `isProtoLanguage/1`

% `isExtinct/1`

% `isParent/2`


/*
    3 Rules.
    Extend queries, variables, unification.
*/


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


/*
    4 Recursion.
*/


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


/*
    5 Lists.
    Introduce acc, auxiliary predicates.
    Note built-ins.
*/


% `contains/2`

contains([H|_],H).
contains([H|T],X) :- H \= X, contains(T,X).


% `hasSize/2`

hasSize([],0).
hasSize([_|T],N) :- hasSize(T,M), N is M + 1.


% `isConcatenated/3`

isConcatenated([],L,L).
isConcatenated([X|A],L,[X|B]) :- isConcatenated(A,L,B).


% `hasLineage/2`

hasLineage(X,L) :- hasLineage(X,L,[]).

hasLineage(X,L,L) :- \+ isParent(_,X).
hasLineage(X,L,A) :-    isParent(Y,X), hasLineage(Y,L,[Y|A]).


% `hasReverseLineage/2`

hasReverseLineage(X,[]) :- \+ isParent(_,X).
hasReverseLineage(X,[Y|Z]) :- isParent(Y,X), hasReverseLineage(Y,Z).


/*
    6 Lists containing predicates.
    Note unification.
*/


% `areCorrectRelationships/1`

areCorrectRelationships([]).
areCorrectRelationships([areRelated(X,Y)|Z]) :-
    shareMostRecentAncestor(X,Y,_),
    areCorrectRelationships(Z).


% `hasActualRelationships/2`

hasActualRelationships([],[]).
hasActualRelationships([areRelated(X,Y)|A],[areRelated(X,Y)|B]) :-
    shareMostRecentAncestor(X,Y,_),
    hasActualRelationships(A,B).
hasActualRelationships([areRelated(X,Y)|A],[notRelated(X,Y)|B]) :-
    \+ shareMostRecentAncestor(X,Y,_),
    hasActualRelationships(A,B).
hasActualRelationships([X|A],B) :-
    X \= areRelated(_,_),
    hasActualRelationships(A,B).


/*
    7 Mutual recursion.
*/


% `hasDescendants/2`.

hasDescendants(X,[X])   :- \+ isParent(X,_).
hasDescendants(X,[X|Y]) :-    isParent(X,Z), haveDescendants(Z,Y).

% hasDescendants(X,[X|Y]) :- findall(A,isParent(X,A),Z), haveDescendants(Z,Y).

haveDescendants([],[]).
haveDescendants([X|Y],Z) :- hasDescendants(X,A), haveDescendants(Y,B), isConcatenated(A,B,Z).


% `hasSpokenDescendants/2`.

hasSpokenDescendants(X,0) :- \+ isParent(X,_),    isExtinct(X).
hasSpokenDescendants(X,1) :- \+ isParent(X,_), \+ isExtinct(X).
hasSpokenDescendants(X,N) :-    isParent(X,Y),    isExtinct(X), haveSpokenDescendants(Y,N).
hasSpokenDescendants(X,N) :-    isParent(X,Y), \+ isExtinct(X), haveSpokenDescendants(Y,M), N is M + 1.

haveSpokenDescendants([],0).
haveSpokenDescendants([X|Y],N) :- hasSpokenDescendants(X,A), haveSpokenDescendants(Y,B), N is A + B.
