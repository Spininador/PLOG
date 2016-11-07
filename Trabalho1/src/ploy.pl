:- use_module(library(system)).
:- include('board.pl').
:- include('menu.pl').
:- include('interface.pl').

ploy:- menu.

%%%%%%%%%%% ROTAÇAO DE PEÇA %%%%%%%%%%%%%%%

% Exemplo de Piece: ['red',['s']] %

rotatePiece(Piece,Orientation,PieceNova):-
rotatePiece_aux(Piece,Orientation,PieceNova).

rotatePiece_aux([Team|[Sides|Rest]],Orientation,[Team|[NewSides|Rest2]]):-
clockwise(Orientation) -> rotateClock(Sides,NewSides);(
counterClockwise(Orientation) -> rotateCounterClock(Sides,NewSides)).

rotateClock([],[]).
rotateClock([Side|Rest1],[NewSide|Rest2]):-
rotateC(Side,NewSide),rotateClock(Rest1,Rest2).

rotateCounterClock([],[]).
rotateCounterClock([Side|Rest1],[NewSide|Rest2]):-
rotateCC(Side,NewSide),rotateCounterClock(Rest1,Rest2).

%Rotate Clockwise
clockwise(0).
rotateC('n','ne').
rotateC('ne','e').
rotateC('e','se').
rotateC('se','s').
rotateC('s','sw').
rotateC('sw','w').
rotateC('w','nw').
rotateC('nw','n').
%Rotate CounterClockwise
counterClockwise(1).
rotateCC('n','nw').
rotateCC('ne','n').
rotateCC('e','ne').
rotateCC('se','e').
rotateCC('s','se').
rotateCC('sw','s').
rotateCC('w','sw').
rotateCC('nw','w').

%%%%%%%%%%%%% MANIPULACAO DE PEÇAS %%%%%%%%%%%%%%%

%getPiece(+X,+Y,+Board,-Piece)
getPiece(X,Y,Board,Piece):-
getPiece_aux(X,Y,Board,Piece).

getPiece_aux(_,_,[],_).
getPiece_aux(X,Y,[CurrLine|Rest],Piece):-
Y == 0 -> getPiece_aux2(X,Y,CurrLine,Piece); (Y1 is Y - 1, getPiece_aux(X,Y1,Rest,Piece)).

getPiece_aux2(_,_,[],_).
getPiece_aux2(X,Y,[CurrPiece|Rest],Piece):-
X == 0 -> Piece = CurrPiece ; (X1 is X - 1, getPiece_aux2(X1,Y,Rest,Piece)).

%setPiece(+X,+Y,+Board,-NewBoard,+Piece)
setPiece(X,Y,Board,NewBoard,Piece):-
setPiece_aux(X,Y,Board,NewBoard,Piece).

setPiece_aux(_,_,[],[],_).
setPiece_aux(X,Y,[CurrLine|Rest],[CurrLine2|Rest2],Piece):-
setPiece_aux2(X,Y,CurrLine,CurrLine2,Piece),
Y1 is Y-1,
setPiece_aux(X,Y1,Rest,Rest2,Piece).

setPiece_aux2(_,_,[],[],_).
setPiece_aux2(X,Y,[CurrPiece|Rest],[CurrPiece2|Rest2],Piece):-
((X = 0, Y = 0) -> CurrPiece2 = Piece ; CurrPiece2 = CurrPiece),
X1 is X-1,
setPiece_aux2(X1,Y,Rest,Rest2,Piece).

%movePiece(+X,+Y,+Orientation,+Length,+Board,-NewBoard)
movePiece(X,Y,Orientation,Length,Board,NewBoard):-
	getPiece(X,Y,Board,Piece),
	calcEndPoint(X,Y,Orientation,Length,Xf,Yf),
	assertCanMove(Piece,X,Y,Xf,Yf,Orientation,Length,Board),
	setPiece(Xf,Yf,Board,IntBoard,Piece),
	vazio(Vazio),
	setPiece(X,Y,IntBoard,NewBoard,Vazio).


assertCanMove(Piece,X,Y,Xf,Yf,Orientation,Length,Board):-
	assertHasOrientation(Orientation,Piece),
	assertValidLength(Length,Piece),
	assertInsideBoundaries(Xf,Yf),
	assertNoColision(X,Y,Orientation,Length,Board).

assertHasOrientation(Orientation,Piece):-
	assertHasOrientation_aux(Orientation,Piece).

assertHasOrientation_aux(Orientation,[_|[Orientations|_]]):-
	member(Orientation,Orientations).

assertValidLength(Length,Piece):-
	assertValidLength_aux(Length,Piece).

assertValidLength_aux(Length,[_|[Orientations|_]]):-
	length(Orientations,NDirections),
	(NDirections == 4 -> MaxLength is 1 ; MaxLength is NDirections),
	Length =< MaxLength.

%Coord multipliers
multiplierX('s',0).
multiplierX('n',0).
multiplierX('e',1).
multiplierX('w',-1).
multiplierX('ne',1).
multiplierX('se',1).
multiplierX('nw',-1).
multiplierX('sw',-1).

multiplierY('s',1).
multiplierY('n',-1).
multiplierY('e',0).
multiplierY('w',0).
multiplierY('ne',-1).
multiplierY('se',1).
multiplierY('nw',-1).
multiplierY('sw',1).

assertInsideBoundaries(Xf,Yf):-
	Xf < 9,
	Xf > -1,
	Yf < 9,
	Yf > -1.
%calcEndPoint(+X,+Y,+Orientation,+Length,-Xf,-Yf)
calcEndPoint(X,Y,Orientation,Length,Xf,Yf):-
	multiplierX(Orientation,MultX),
	multiplierY(Orientation,MultY),
	Xf is X + Length*MultX,
	Yf is Y + Length*MultY.

assertNoColision(X,Y,Orientation,Length,Board):-
	calcEndPoint(X,Y,Orientation,Length,Xf,Yf),
	getPiece(X,Y,Board,Piece1),
	getPiece(Xf,Yf,Board,Piece2),
	assertDifferentTeam(Piece1,Piece2),
	Length1 is Length - 1,
	(Length > 1 -> assertNoColision_inter(X,Y,Orientation,Length1,Board) ; true).

assertNoColision_inter(X,Y,Orientation,Length,Board):-
	Length > 0 ->(
		calcEndPoint(X,Y,Orientation,Length,Xf,Yf),
		getPiece(Xf,Yf,Board,Piece),
		assertEmpty(Piece),
		Length1 is Length - 1,
		assertNoColision_inter(X,Y,Orientation,Length1,Board)
	); true.

assertEmpty([Team|_]):-
	Team == 'empty'.

assertDifferentTeam([Team1|_],[Team2|_]):-
	Team1 \= Team2.
