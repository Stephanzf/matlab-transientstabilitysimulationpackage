function statmsg(figNumber,msgStr)
%STATMSG Send message to GUI status field.
%	STATMSG(figNumber,msgStr) causes the message contained in msgStr
%	to be passed to the status line (a text uicontrol field with the
%	Tag property set to "status") of the specified figure. 

%	Ned Gulley, 4-27-94
%	Copyright (c) 1994-95 by The MathWorks, Inc.
%	$Revision: 1.6 $  $Date: 1995/02/17 13:08:10 $

set(findobj(figNumber,'Type','uicontrol','Tag','status'),'String',msgStr);
