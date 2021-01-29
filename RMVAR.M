function [out,errorStr]=rmvar(fis,varType,varIndex)
%RMVAR	Remove variable from FIS.
%	fis2 = RMMF(fis,varType,varIndex) removes the specified
%	variable from the fuzzy inference system associated with the 
%	FIS matrix fis.
%
%	[fis2,errorStr] = RMMF(fis,varType,varIndex) returns any necessary
%	error messages in the string errorStr.
%
%	For example:
%
%		a=newfis('tipper');
%		a=addvar(a,'input','service',[0 10]);
%		a=addvar(a,'input','food',[0 10]);
%		getfis(a)
%		a=rmvar(a,'input',1);
%		getfis(a)
%
%	See also ADDMF, ADDVAR, and RMMF.

%	Ned Gulley, 2-2-94
%	Copyright (c) 1994-95 by The MathWorks, Inc.
%	$Revision: 1.10 $  $Date: 1995/02/17 13:08:10 $

errorFlag=0;
numInputs=fis(3,1);
numOutputs=fis(3,2);
numInputMFs=fis(4,1:numInputs);
totalInputMFs=sum(numInputMFs);
numOutputMFs=fis(5,1:numOutputs);
totalOutputMFs=sum(numOutputMFs);

% Get the rule matrix
numRules=fis(6,1);
numCols=numInputs+numOutputs+2;
firstRow=12+2*(numInputs+numOutputs)+3*(totalInputMFs+totalOutputMFs);
lastRow=firstRow+numRules-1;
ruleList=fis(firstRow:lastRow,1:numCols);

if strcmp(varType,'input'),
    if numInputs==0,
	errorStr='No input variables left to remove';
 	if nargout<2, 
	   error(errorStr); 
	else
	    out=[];
	    return
	end
    end

    % Make sure the variable is not currently being used in the rules
    if numRules>0,
	usageIndex=find(ruleList(:,varIndex)~=0);
    else
	usageIndex=[];
    end
    if length(usageIndex),
	errorStr=['Cannot remove. Variable "' ...
	    getfis(fis,varType,varIndex,'name') ...
	    '" is referenced in rule(s): ' fmat2str(usageIndex')];
 	if nargout<2, 
	   error(errorStr); 
	else
	    out=[];
	    return
	end
    end

    % If this is a sugeno output, remove a column from 
    % the current out params list...
    fisType=getfis(fis,'type');
    if strcmp(fisType,'sugeno'),
        numCols=numInputs+1;
    	firstRow=12+2*(numInputs+numOutputs)+3*totalInputMFs+2*totalOutputMFs;
    	lastRow=firstRow+totalOutputMFs-1;

        outMFParams=fis(firstRow:lastRow,1:numCols)
    	outMFParams(:,varIndex)=[]
    	fis(firstRow:lastRow,1:(numCols-1))=outMFParams;
    end	

    % Remove the relevant MFs.
    numMFs=numInputMFs(varIndex);
    for mfIndex=numMFs:-1:1,
	fis=rmmf(fis,'input',varIndex,'mf',mfIndex);
    end

    % Remove the appropriate column from the rule list
    if numRules,
	ruleList(:,varIndex)=[];
	ruleList=[ruleList zeros(size(ruleList,1),1)];
	fis=setfis(fis,'ruleList',ruleList);
    end

    % Remove two rows from the fis matrix, one for inLabels, one for inRange
    inLabelsFirstRow=12;
    inLabelsRmPtr=inLabelsFirstRow+varIndex-1;
    inRangeFirstRow=12+numInputs+numOutputs;
    inRangeRmPtr=inRangeFirstRow+varIndex-1;
    % Remove both rows at once so we don't throw off the row arithmetic
    fis([inLabelsRmPtr inRangeRmPtr],:)=[];

    numInputMFs(varIndex)=[];
    numInputMFs=[numInputMFs 0];
    fis(4,1:numInputs)=numInputMFs;
    fis(3,1)=numInputs-1;

elseif strcmp(varType,'output'),
    if numOutputs==0,
	errorStr='No output variables left to remove';
 	if nargout<2, 
	   error(errorStr); 
	else
	    out=[];
	    return
	end
    end

    % Make sure the variable is not currently being used in the rules
    if numRules>0,
    	usageIndex=find(ruleList(:,varIndex+numInputs)~=0);
    else
	usageIndex=[];
    end
    if length(usageIndex),
	errorStr=['Cannot remove. Variable "' ...
	    getfis(fis,varType,varIndex,'name') ...
	    '" is referenced in rule(s): ' fmat2str(usageIndex')];
 	if nargout<2, 
	   error(errorStr); 
	else
	    out=[];
	    return
	end
    end

    % Remove the relevant MFs.
    numMFs=numOutputMFs(varIndex);
    for mfIndex=numMFs:-1:1,
	fis=rmmf(fis,'output',varIndex,'mf',mfIndex);
    end

    % Remove the appropriate column from the rule list
    if numRules,
	ruleList(:,varIndex+numInputs)=[];
	ruleList=[ruleList zeros(size(ruleList,1),1)];
	fis=setfis(fis,'ruleList',ruleList);
    end

    % Remove two rows from the fis matrix, one for inLabels, one for inRange
    outLabelsFirstRow=12+numInputs;
    outLabelsRmPtr=outLabelsFirstRow+varIndex-1;
    outRangeFirstRow=12+2*numInputs+numOutputs;
    outRangeRmPtr=outRangeFirstRow+varIndex-1;
    % Remove both rows at once so we don't throw off the row arithmetic
    fis([outLabelsRmPtr outRangeRmPtr],:)=[];

    numOutputMFs(varIndex)=[];
    numOutputMFs=[numOutputMFs 0];
    fis(5,1:numOutputs)=numOutputMFs;
    fis(3,2)=numOutputs-1;

end

out=fis;
