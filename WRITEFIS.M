function [fileName,pathName,errorStr]=writefis(fis,fileName,dlgStr)
%WRITEFIS Save FIS to disk.
%	WRITEFIS(FISMAT) brings up a UIPUTFILE dialog box to assist
%	with the naming and directory location of the file.
%
%	WRITEFIS(FISMAT,'filename') writes a FIS file corresponding
%	to the FIS matrix FISMAT to a disk file called 'filename' in
%	the current directory.
%
%	WRITEFIS(FISMAT,'filename','dialog') brings up a UIPUTFILE
%	dialog box with the default name 'filename' supplied.
%
%	The extension '.fis' is added to 'filename' if it is not 
%	already present.
%
%	See also READFIS.

%	Ned Gulley, 5-25-94
%	Copyright (c) 1994-95 by The MathWorks, Inc.
%	$Revision: 1.12 $  $Date: 1995/02/22 16:29:09 $

if nargin<1,
    errorStr='No FIS matrix provided.';
    if nargout<3, error(errorStr); end
    return
end

if nargin>1,
    fileName=deblank(fileName);
end

if nargin<3,
    dlgStr=' ';
end

if nargin<2,
    fileName='*.fis';
end

pathName=[];
if (nargin<2) | strcmp(dlgStr,'dialog'),
    pos=get(0,'DefaultFigurePosition');
    [fileName,pathName]=uiputfile([fileName '.fis'],'Save FIS',pos(1),pos(2));
    if ~fileName | isempty(fileName),
	errorStr='No file name was specified';
    	if nargout<3, error(errorStr); end
    	return; 
    end
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

fileExt='.fis';
fid=fopen([pathName fileName fileExt],'w');
if fid==-1, 
    errorStr=['Unable to write to file "' fileName '"'];
    if nargout<3, error(errorStr); end
    return; 
end

fprintf(fid,'[System]\n');
% Name
fisname=getfis(fis,'name');
str=['Name=''' fisname '''\n'];
fprintf(fid,str);

% Structure
fisType=getfis(fis,'type');
str=['Type=''' fisType '''\n'];
fprintf(fid,str);

NumInputs=getfis(fis,'NumInputs');
str=['NumInputs=' num2str(NumInputs) '\n'];
fprintf(fid,str);

NumOutputs=getfis(fis,'NumOutputs');
str=['NumOutputs=' num2str(NumOutputs) '\n'];
fprintf(fid,str);

NumRules=getfis(fis,'NumRules');
str=['NumRules=' num2str(NumRules) '\n'];
fprintf(fid,str);

andMethod=getfis(fis,'andMethod');
str=['AndMethod=''' andMethod '''\n'];
fprintf(fid,str);

orMethod=getfis(fis,'orMethod');
str=['OrMethod=''' orMethod '''\n'];
fprintf(fid,str);

impMethod=getfis(fis,'impMethod');
str=['ImpMethod=''' impMethod '''\n'];
fprintf(fid,str);

aggMethod=getfis(fis,'aggMethod');
str=['AggMethod=''' aggMethod '''\n'];
fprintf(fid,str);

defuzzMethod=getfis(fis,'defuzzMethod');
str=['DefuzzMethod=''' defuzzMethod '''\n'];
fprintf(fid,str);

numInputs=getfis(fis,'numinputs');
numInputMFs=getfis(fis,'numinputmfs');
inLabels=getfis(fis,'inLabels');
inRange=getfis(fis,'inRange');
inMFLabels=getfis(fis,'inMFLabels');
inMFTypes=getfis(fis,'inMFTypes');
%inMFParams=getfis(fis,'inMFParams');
numOutputs=getfis(fis,'numoutputs');
numOutputMFs=getfis(fis,'numoutputmfs');
outLabels=getfis(fis,'outLabels');
outRange=getfis(fis,'outRange');
outMFLabels=getfis(fis,'outMFLabels');
outMFTypes=getfis(fis,'outMFTypes');
%outMFParams=getfis(fis,'outMFParams');

for varIndex=1:numInputs,
    fprintf(fid,['\n[Input' num2str(varIndex) ']\n']);
    str=['Name=''' deblank(inLabels(varIndex,:)) '''\n'];
    fprintf(fid,str);
    str=['Range=' fmat2str(inRange(varIndex,:)) '\n'];
    fprintf(fid,str);
    str=['NumMFs=' num2str(numInputMFs(varIndex)) '\n'];
    fprintf(fid,str);

    for mfIndex=1:numInputMFs(varIndex),
	MFIndex2=sum(numInputMFs(1:(varIndex-1)))+mfIndex;
	mfLabel=deblank(inMFLabels(MFIndex2,:));
	mfType=deblank(inMFTypes(MFIndex2,:));
	p=getfis(fis,'input',varIndex,'MF',mfIndex,'params');
	str=['MF' num2str(mfIndex) '=''' mfLabel ''':''' mfType ''',' fmat2str(p) '\n'];
    	fprintf(fid,str);
    end
end

for varIndex=1:numOutputs,
    fprintf(fid,['\n[Output' num2str(varIndex) ']\n']);
    str=['Name=''' deblank(outLabels(varIndex,:)) '''\n'];
    fprintf(fid,str);
    str=['Range=' fmat2str(outRange(varIndex,:)) '\n'];
    fprintf(fid,str);
    str=['NumMFs=' num2str(numOutputMFs(varIndex)) '\n'];
    fprintf(fid,str);
 
    for mfIndex=1:numOutputMFs(varIndex),
	MFIndex2=sum(numOutputMFs(1:(varIndex-1)))+mfIndex;
	mfLabel=deblank(outMFLabels(MFIndex2,:));
	mfType=deblank(outMFTypes(MFIndex2,:));
	p=getfis(fis,'output',varIndex,'MF',mfIndex,'params');
	str=['MF' num2str(mfIndex) '=''' mfLabel ''':''' mfType ''',' fmat2str(p) '\n'];
    	fprintf(fid,str);
    end
end

numRules=getfis(fis,'numRules');
str=['\n[Rules]\n'];
fprintf(fid,str);

ruleListStr=showrule(fis,1:numRules,'indexed');
for ruleIndex=1:numRules,
    str=[ruleListStr(ruleIndex,:) '\n'];
    fprintf(fid,str);
end

fclose(fid);
