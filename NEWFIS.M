function out=newfis(fisName,fisType,andMethod,orMethod,impMethod,aggMethod,defuzzMethod)
%NEWFIS	Create new FIS.
%	FIS=NEWFIS(FISNAME) creates a new Mamdani-style FIS matrix with the
%	name FISNAME.
%
%	FIS=NEWFIS(FISNAME, FISTYPE) creates a FIS matrix for a Mamdani or 
%	Sugeno-style system with the name FISNAME.

%	Ned Gulley, 3-15-94
%	Copyright (c) 1994-95 by The MathWorks, Inc.
%	$Revision: 1.7 $  $Date: 1995/02/17 13:08:10 $

if (nargin<2), fisType='mamdani'; end
if strcmp(fisType,'mamdani'),
    if (nargin<3), andMethod='min'; end
    if (nargin<4), orMethod='max'; end
    if (nargin<7), defuzzMethod='centroid'; end
end

if (nargin<5), impMethod='min'; end
if (nargin<6), aggMethod='max'; end

if strcmp(fisType,'sugeno'),
    if (nargin<3), andMethod='prod'; end
    if (nargin<4), orMethod='probor'; end
    if (nargin<7), defuzzMethod='wtaver'; end
end

% First create a dummy matrix
out=zeros(11,3);

out=setfis(out,'Name',fisName);
out=setfis(out,'Type',fisType);
out=setfis(out,'andMethod',andMethod);
out=setfis(out,'orMethod',orMethod);
out=setfis(out,'impMethod',impMethod);
out=setfis(out,'aggMethod',aggMethod);
out=setfis(out,'defuzzMethod',defuzzMethod);
