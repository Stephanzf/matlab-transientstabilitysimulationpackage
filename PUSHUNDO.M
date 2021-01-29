function pushundo(figNumber,newFis)
%PUSHUNDO Push the current FIS onto the undo stack.
%	PUSHUNDO(figNumber,newFIS) pushes the old FIS matrix into the UserData
%	for the Undo uimenu. The function also broadcasts changes in the FIS
%	matrix to all the other related GUI tools, since it gets called every
%	time the FIS matrix gets updated.

%	Ned Gulley, 8-31-94
%	Copyright (c) 1994-95 by The MathWorks, Inc.
%	$Revision: 1.4 $  $Date: 1995/02/17 13:08:10 $

undoLimit=3;

undoHndl=findobj(figNumber,'Type','uimenu','Tag','undo');
oldFis=get(figNumber,'UserData');
% If a change has been made, then store the old FIS matrix
% in the undo cubbyhole for later use. In other words, newFis is passed
% in just to make a comparison and potentially save time.
if ~strcmp(oldFis,newFis),

    % Push the new FIS matrix onto the stack
    stack=get(undoHndl,'UserData');
    if ~isempty(stack),
    	rows=stack(1,:);
    	rows(find(rows==0))=[];
    	stack(1,:)=[];
    	rows=[size(oldFis,1) rows];
    else
	rows=size(oldFis,1);
    end

    % If we're beyond the number of undos limit, throw the most
    % distant change off the back of the bus.    
    numUndos=length(rows);
    if numUndos>undoLimit,
	lastRow=size(stack,1);
	firstRow=lastRow-rows(numUndos)+1;
	stack(firstRow:lastRow,:)=[];
	rows(undoLimit+1)=[];
    end

    stack=combine(rows,oldFis,stack);

    set(undoHndl,'UserData',stack,'Enable','on');
end

