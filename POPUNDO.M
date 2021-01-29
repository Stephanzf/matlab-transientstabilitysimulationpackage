function popundo(figNumber)
%POPUNDO Pop the last FIS change off the undo stack.
%	POPUNDO(figNumber) pops the old FIS matrix off of the UserData
%	for the Undo uimenu. The function also broadcasts changes in the FIS
%	matrix to all the other related GUI tools.

%	Ned Gulley, 8-31-94
%	Copyright (c) 1994-95 by The MathWorks, Inc.
%	$Revision: 1.7 $  $Date: 1995/02/17 13:08:10 $

if nargin<1,
    figNumber=get(0,'CurrentFigure');
end

undoHndl=findobj(figNumber,'Type','uimenu','Tag','undo');
stack=get(undoHndl,'UserData');
if size(stack,1)>1, 
    statmsg(figNumber,'Undoing last change');

    % Pop the old FIS matrix off the stack
    rows=stack(1,:);
    numRows=rows(1);
    undoFis=stack(1+(1:numRows),:);
    rows(1)=[];
    stack([1 1+(1:numRows)],:)=[];
    stack=combine(rows,stack);
    set(undoHndl,'UserData',stack);
    if size(stack,1)<5,
	% We've popped until we found the bottom of the stack.
	% Can't pop no more.
    	set(undoHndl,'Enable','off');
    end

    % Now we have to update everybody
    tagList=[
    	'fuzzy   '
    	'mfedit  '
    	'ruleedit'
    	'ruleview'
    	'surfview'];
    % The figure tag contains the function name that created it (i.e. fuzzy)
    tag=get(figNumber,'Tag');
    currGui=findrow(tag,tagList);
    guiList=1:5;
    guiList(currGui)=[];
    updtfis(figNumber,undoFis,guiList);
    eval([tag ' #update']);

else
    set(undoHndl,'Enable','off');
end


