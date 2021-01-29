function out=addmf(fis,varType,varIndex,MFLabel,MFType,MFParams)
%ADDMF	Add membership function to FIS
%	fis2 = ADDMF(fis1,varType,varIndex,mfName,mfType,mfParams)
%	adds the membership function specified by MFLabel (the name
%	of the membership function), mfType (the function, such as
%	TRIMF or GBELLMF), and mfParams (the function parameters) to
%	a variable in the fuzzy inference system called fis1.
%	The variable is specified by varType (either 'input' or 
%	'output') and varIndex.
%
%	For example:
%
%		a=newfis('tipper');
%		a=addvar(a,'input','service',[0 10]);
%		a=addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%		a=addmf(a,'input',1,'good','gaussmf',[1.5 5]);
%		a=addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%		plotmf(a,'input',1)
%
%	See also ADDRULE, ADDVAR, PLOTMF, RMMF, and RMVAR.

%	Ned Gulley, 3-15-94
%	Copyright (c) 1994-95 by The MathWorks, Inc.
%	$Revision: 1.7 $  $Date: 1995/02/17 13:08:10 $

numInputs=fis(3,1);
numOutputs=fis(3,2);
numInputMFs=fis(4,1:numInputs);
totalInputMFs=sum(numInputMFs);
numOutputMFs=fis(5,1:numOutputs);
totalOutputMFs=sum(numOutputMFs);
[numRows,numCols]=size(fis);

if strcmp(varType,'input'),
    MFLastRow=sum(numInputMFs(1:varIndex))-1;
    inMFLabelsLastRow=12+2*(numInputs+numOutputs)+ ...
	MFLastRow;
    inMFTypesLastRow=12+2*(numInputs+numOutputs)+totalInputMFs+totalOutputMFs+ ...
	MFLastRow;
    inMFParamsLastRow=12+2*(numInputs+numOutputs)+2*(totalInputMFs+totalOutputMFs)+ ...
	MFLastRow;
    orderIndex=sort([1:numRows inMFLabelsLastRow inMFTypesLastRow inMFParamsLastRow]);

    % Add three new rows to the fis matrix, one for inMFLabels, 
    % one for inMFType, and  one for inMFParams
    out=zeros(numRows+3,numCols);
    out=fis(orderIndex,:);
    newMFIndex=numInputMFs(varIndex)+1;
    numInputMFs(varIndex)=newMFIndex;
    out=setfis(out,'numInputMFs',numInputMFs);
    out=setfis(out,varType,varIndex,'MF',newMFIndex,'Name',MFLabel);
    out=setfis(out,varType,varIndex,'MF',newMFIndex,'Type',MFType);
    out=setfis(out,varType,varIndex,'MF',newMFIndex,'Params',MFParams);

elseif strcmp(varType,'output'),
    MFLastRow=sum(numOutputMFs(1:varIndex))-1;
    outMFLabelsLastRow=12+2*(numInputs+numOutputs)+ ...
	totalInputMFs+ ...
	MFLastRow;
    outMFTypesLastRow=12+2*(numInputs+numOutputs)+ ...
	2*totalInputMFs+totalOutputMFs+ ...
	MFLastRow;
    outMFParamsLastRow=12+2*(numInputs+numOutputs)+ ...
	3*totalInputMFs+2*totalOutputMFs+ ...
	MFLastRow;
    orderIndex=sort([1:numRows outMFLabelsLastRow ...
	outMFTypesLastRow outMFParamsLastRow]);

    % Add three new rows to the fis matrix, one for outMFLabels, 
    % one for outMFType, and  one for outMFParams
    out=zeros(numRows+3,numCols);
    out=fis(orderIndex,:);
    newMFIndex=numOutputMFs(varIndex)+1;
    numOutputMFs(varIndex)=newMFIndex;
    out=setfis(out,'numOutputMFs',numOutputMFs);
    out=setfis(out,varType,varIndex,'MF',newMFIndex,'Name',MFLabel);
    out=setfis(out,varType,varIndex,'MF',newMFIndex,'Type',MFType);
    out=setfis(out,varType,varIndex,'MF',newMFIndex,'Params',MFParams);

end
