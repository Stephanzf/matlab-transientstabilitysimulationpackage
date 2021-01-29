function [out,errorStr]=readfis(fileName)
%READFIS Load FIS from disk.
%	FISMAT=FISWRITE('filename') creates a FIS matrix in the
%	workspace corresponding to the FIS file 'filename' on disk.
%
%	FISMAT=READFIS brings up a UIGETFILE dialog box to assist
%	with the name and directory location of the file.
%
%	The extension '.fis' is assumed for 'filename' if it is not 
%	already present.
%
%	See also WRITEFIS.

%	Ned Gulley, 5-10-94
%	Copyright (c) 1994-95 by The MathWorks, Inc.
%	$Revision: 1.16 $  $Date: 1995/02/22 16:28:01 $

pathName=[];
if nargin<1,
    pos=get(0,'DefaultFigurePosition');
    [fileName,pathName]=uigetfile('*.fis','Read FIS',pos(1),pos(2));
    if ~fileName | isempty(fileName),
	% If fileName is zero, "cancel" was hit, or there was an error.
	errorStr='No file was loaded';
	out=[];
	if nargout<2,
	    error(errorStr);
	end
	return
    end
end

fileName=deblank(fileName);
if isempty(fileName),
    errorStr='Empty file name: no file was loaded';
    out=[];
    if nargout<2,
	error(errorStr);
    end
    return
end

len=length(fileName);
% To make things as easy as possible, strip off everything after the
% period (if there is one), then attach ".fis" to the end.
% That way, if there's no .fis on the end, one will get put one there
% This also takes care of the VMS situation with it semi-colons
dotIndex=find(fileName=='.');
if ~isempty(dotIndex),
    fileName(dotIndex(1):len)=[];
end
fileName=[fileName '.fis'];

fileName=[pathName fileName];
[fid,errorStr]=fopen(fileName,'r');
if fid<0,
    if nargout<2,
    	error(errorStr);
    end
    return
end

% Structure
nextLineVar=' ';
topic='[System]';
while isempty(findstr(nextLineVar,topic)),
    nextLineVar=nextline(fid);
end

% These are the system defaults in case the user has omitted them
Name='Untitled';
Type='mamdani';
AndMethod='min';
OrMethod='max';
ImpMethod='min';
AggMethod='max';
DefuzzMethod='centroid';

nextLineVar=' ';
% Here we are evaluating everything up till the first "[" bracket
% The lines we're eval-ing contain their own variable names, so
% a lot of variables, like "Name" and so on, are getting initialized
% invisibly
while isempty([findstr(nextLineVar,'[Input') findstr(nextLineVar,'[Output')
    findstr(nextLineVar,'[Rules')]),
    eval([nextLineVar ';']);
    nextLineVar=nextline(fid);
end

fisName=Name;
fisType=Type;

% I have to rewind here to catch the first input. This is because
% I don't know how long the [System] comments are going to be
frewind(fid)

% Now begin with the inputs
for varIndex=1:NumInputs,
    nextLineVar=' ';
    topic='[Input';
    while isempty(findstr(nextLineVar,topic)),
    	nextLineVar=nextline(fid);
    end

    % Input variable name
    Name=0;
    eval([nextline(fid) ';'])
    if ~Name, 
	error(['Name missing or out of place for input variable ' ...
	    num2str(varIndex)]);
    end
    varName=Name;
    InLabels(varIndex,1:length(varName))=varName;

    % Input variable range
    Range=0;
    eval([nextline(fid) ';'])
    if ~Range, 
	error(['Range missing or out of place for input variable ' ...
	    num2str(varIndex)]);
    end
    InRange(varIndex,:)=Range;

    % Number of membership functions
    eval([nextline(fid) ';']);
    NumInputMFs(varIndex)=NumMFs;

    for MFIndex=1:NumMFs,
        MFRowIndex=sum(NumInputMFs(1:(varIndex-1)))+MFIndex;
	MFStr=nextline(fid);
	nameStart=findstr(MFStr,'=');
	nameEnd=findstr(MFStr,':');
	MFName=eval(MFStr((nameStart+1):(nameEnd-1)));
 	InMFLabels(MFRowIndex,1:length(MFName))=MFName;
	typeStart=findstr(MFStr,':');
	typeEnd=findstr(MFStr,',');
	MFType=eval(MFStr((typeStart+1):(typeEnd-1)));
	InMFTypes(MFRowIndex,1:length(MFType))=MFType;
	MFParams=eval(MFStr((typeEnd+1):length(MFStr)));
	InMFParams(MFRowIndex,1:length(MFParams))=MFParams;
    end
end

% Now for the outputs
for varIndex=1:NumOutputs,
    nextLineVar=' ';
    topic='Output';
    while isempty(findstr(nextLineVar,topic)),
    	nextLineVar=nextline(fid);
    end

    % Output variable name
    varName=nextline(fid);
    varName=strrep(varName,'Name','');
    varName=eval(strrep(varName,'=',''));
    OutLabels(varIndex,1:length(varName))=varName;

    % Output variable range
    rangeStr=nextline(fid);
    rangeStr=strrep(rangeStr,'Range','');
    rangeStr=strrep(rangeStr,'=','');
    OutRange(varIndex,:)=eval(['[' rangeStr ']']);

    NumMFsStr=nextline(fid);
    NumMFsStr=strrep(NumMFsStr,'NumMFs','');
    NumMFsStr=strrep(NumMFsStr,'=','');
    NumMFs=eval(NumMFsStr);
    NumOutputMFs(varIndex)=NumMFs;

    for MFIndex=1:NumMFs,
        MFRowIndex=sum(NumOutputMFs(1:(varIndex-1)))+MFIndex;
	MFStr=nextline(fid);
	nameStart=findstr(MFStr,'=');
	nameEnd=findstr(MFStr,':');
	MFName=eval(MFStr((nameStart+1):(nameEnd-1)));
 	OutMFLabels(MFRowIndex,1:length(MFName))=MFName;
	typeStart=findstr(MFStr,':');
	typeEnd=findstr(MFStr,',');
	MFType=eval(MFStr((typeStart+1):(typeEnd-1)));
	OutMFTypes(MFRowIndex,1:length(MFType))=MFType;
	MFParams=eval(MFStr((typeEnd+1):length(MFStr)));
	OutMFParams(MFRowIndex,1:length(MFParams))=MFParams;
    end
end

% Now assemble the whole FIS data matrix

% If NumInputs or NumOutputs is zero, we need a space holder for the MF indices
% Otherwise they'll just be the empty set
if isempty(NumInputMFs), NumInputMFs=0; end
if isempty(NumOutputMFs), NumOutputMFs=0; end

fisStructure=combine( ...
	fisType, ...
	[NumInputs NumOutputs], ...
	NumInputMFs, ...
	NumOutputMFs, ...
	NumRules, ...
	AndMethod, ...
	OrMethod, ...
	ImpMethod, ...
	AggMethod, ...
	DefuzzMethod);
	
fisVars=combine(  ...
	InLabels, ...
	OutLabels, ...
	InRange, ...
	OutRange);

fisMFs=combine( ...
	InMFLabels, ...
	OutMFLabels, ...
	InMFTypes, ...
	OutMFTypes, ...
	InMFParams, ...
	OutMFParams);

% Now assemble the whole structure (except for the rules)
fis=combine( ...
	fisName, ...
	fisStructure, ...
	fisVars, ...
	fisMFs);

% Now for the rules
nextLineVar=' ';
topic='Rules';
while isempty(findstr(nextLineVar,topic)),
    nextLineVar=nextline(fid);
end
txtRuleList=[];
%ones(NumRules,NumInputs+NumOutputs+2);

for ruleIndex=1:NumRules,
    ruleStr=nextline(fid);
    txtRuleList(ruleIndex,1:length(ruleStr))=ruleStr;
end

fclose(fid);

% Finally add the parsed rules
out=parsrule(fis,txtRuleList,'indexed');
