function updtfis(figNumber,fis,guiList)
%UPDTFIS Update all fuzzy GUI tools as needed.
%	UPDTFIS(figNumber,FIS,guiList) updates the fuzzy GUI tools
%	specified by the list guiList with the new fuzzy inference
%	system matrix FIS. figNumber is the figure for the current
%	GUI tool making the update request.

%	Ned Gulley, 9-15-94
%	Copyright (c) 1994-95 by The MathWorks, Inc.
%	$Revision: 1.5 $  $Date: 1995/02/17 13:08:10 $

% Need to check all potentially open related windows.
nameList=[ ...
    'FIS Editor                '
    'Membership Function Editor'
    'Rule Editor               '
    'Rule Viewer               '
    'Surface Viewer            '];

fisName=getfis(fis,'name');
for guiIndex=1:5,
    name=deblank(nameList(guiIndex,:));
    newFigNumber=findobj(0,'Name',[name ': ' fisName]);
    if length(newFigNumber)>1,
	% There is more than one of the same editor for the same system present.
	% One should be closed and the others should be updated.
	close(newFigNumber(2:length(newFigNumber)));
	newFigNumber=newFigNumber(1);
    end

    if ~isempty(newFigNumber),
	set(newFigNumber,'UserData',fis);
	if any(guiIndex==guiList) & strcmp(get(newFigNumber,'Visible'),'on'),
	    % We need to explicitly update these GUIs 
	    % (don't bother if its missing or hidden)
	    statmsg(figNumber,['Updating ' name]);
	    figure(newFigNumber);
	    tag=get(newFigNumber,'Tag');
 	    eval([tag ' #update'])
        end
    end
end

figure(figNumber);
statmsg(figNumber,'Ready');
