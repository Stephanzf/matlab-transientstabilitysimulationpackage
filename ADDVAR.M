function out=addvar(fis,varType,varName,varRange)
%ADDVAR	Add variable to FIS.
%	fis2 = ADDVAR(fis1,varType,varName,varRange) adds the variable
%	specified by varType ('input' or 'output'), varName (the name of the
%	variable), and varRange (the universe of discourse for the variable)
%	to the fuzzy inference system called fis1.
%
%	Variables are given indices in the order in which they are added, 
%	so the first input variable added to a system will always be 
%	known as input variable number one for that system. Input and 
%	output variables are numbered independently. 
%
%	For example:
%
%		a=newfis('tipper');
%		a=addvar(a,'input','service',[0 10]);
%		getfis(a,'input',1)
%
%	See also ADDMF, ADDRULE, PLOTMF, RMMF, and RMVAR.

%	Ned Gulley, 2-2-94
%	Copyright (c) 1994-95 by The MathWorks, Inc.
%	$Revision: 1.13 $  $Date: 1995/02/17 13:08:10 $

numInputs=fis(3,1);
numOutputs=fis(3,2);
numInputMFs=fis(4,1:numInputs);
totalInputMFs=sum(numInputMFs);
numOutputMFs=fis(5,1:numOutputs);
totalOutputMFs=sum(numOutputMFs);
numRules=fis(6,1);

[numRows,numCols]=size(fis);

if strcmp(varType,'input'),
    inLabelsLastRow=12+numInputs-1;
    inRangeLastRow=12+2*numInputs+numOutputs-1;
    orderIndex=sort([1:numRows inLabelsLastRow inRangeLastRow]);

    % Add two new rows to the fis matrix, one for inLabels, one for inRange    
    out=zeros(numRows+2,numCols);
    out=fis(orderIndex,:);
    newVarIndex=numInputs+1;
    out=setfis(out,'numInputs',newVarIndex);
    out=setfis(out,varType,newVarIndex,'Name',varName);
    out=setfis(out,varType,newVarIndex,'Range',varRange);

    % If this is a sugeno output, need to insert a new column into 
    % the current out params list...
    fisType=getfis(fis,'type');
    if strcmp(fisType,'sugeno'),
        numCols=numInputs+1;
    	firstRow=12+2*(numInputs+numOutputs)+3*totalInputMFs+2*totalOutputMFs;
    	lastRow=firstRow+totalOutputMFs-1;

	if totalOutputMFs,
	    % Don't bother if there aren't any output MFs in the first place
            outMFParams=fis(firstRow:lastRow,1:numCols)
    	    outMFParams=outMFParams(:,sort([1:(numInputs+1) ...
	    	numInputs]))
    	    outMFParams(:,numInputs+1)=zeros(totalOutputMFs,1)

	    out=setfis(out,'outMFParams',outMFParams);
	end
    end	

    % Need to insert a new column into the current rule list
    if numRules,
	% Don't bother if there aren't any rules
        numCols=numInputs+numOutputs+2;
        firstRow=12+2*(numInputs+numOutputs)+3*(totalInputMFs+totalOutputMFs);
        lastRow=firstRow+numRules-1;
        ruleList=fis(firstRow:lastRow,1:numCols);
    	ruleList=ruleList(:,sort([1:(numInputs+numOutputs+2) numInputs]));
    	ruleList(:,newVarIndex)=zeros(numRules,1);
    	out=setfis(out,'ruleList',ruleList);
    end

elseif strcmp(varType,'output'),
    outLabelsLastRow=12+numInputs+numOutputs-1;
    outRangeLastRow=12+2*numInputs+2*numOutputs-1;
    orderIndex=sort([1:numRows outLabelsLastRow outRangeLastRow]);
    
    % Add two new rows to the fis matrix, one for outLabels, one for outRange    
    out=zeros(numRows+2,numCols);
    out=fis(orderIndex,:);
    newVarIndex=numOutputs+1;
    out=setfis(out,'numOutputs',newVarIndex);
    out=setfis(out,varType,newVarIndex,'Name',varName);
    out=setfis(out,varType,newVarIndex,'Range',varRange);

    % Need to insert a new column into the current rule list
    if numRules,
        numCols=numInputs+numOutputs+2;
        firstRow=12+2*(numInputs+numOutputs)+3*(totalInputMFs+totalOutputMFs);
        lastRow=firstRow+numRules-1;
        ruleList=fis(firstRow:lastRow,1:numCols);
    	ruleList=ruleList(:,sort([1:(numInputs+numOutputs+2) numInputs+numOutputs]));
    	ruleList(:,newVarIndex+numInputs)=zeros(numRules,1);
    	out=setfis(out,'ruleList',ruleList);
    end

end

