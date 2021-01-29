function outLine=nextline(fid)
%NEXTLINE Return the next non-empty line of a file.
%	OUTLINE=NEXTLINE(FID) returns the next non-empty line in the
%	file whose file ID is FID. The file FID must already be open.
%	NEXTLINE skips all lines that consist only of a carriage
%	return and it returns a -1 when the end of the file has been
%	reached.
%
%	NEXTLINE ignores all lines that begin with the % comment
%	character (the % character must be in the first column)

%	Ned Gulley, 2-2-94
%	Copyright (c) 1994-95 by The MathWorks, Inc.
%	$Revision: 1.5 $  $Date: 1995/02/17 13:08:10 $

outLine=fgetl(fid);

stopFlag=0;
while (~stopFlag) & (outLine~=-1),
    if length(outLine)>0,
 	if ~strcmp(outLine(1),'%'),
	    % This line has real content; stop and return outLine
	    stopFlag=1;
    	else
	    % This line must be a comment; keep going
	    outLine=fgetl(fid);
	end
    else
	% This line is of length zero
    	outLine=fgetl(fid);
    end
end;

if outLine==-1,
    error('End of file reached')
end
