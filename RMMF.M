function [out,errorStr]=rmmf(fis,varType,varIndex,mfFlag,mfIndex)
%RMMF	Remove membership function from FIS.
%	fis2 = RMMF(fis,varType,varIndex,'mf',mfIndex) removes the
%	specified membership function from the fuzzy inference system
%	associated with the FIS matrix fis.
%
%	For example:
%
%		a=newfis('tipper');
%		a=addvar(a,'input','service',[0 10]);
%		a=addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%		a=addmf(a,'input',1,'good','gaussmf',[1.5 5]);
%		a=addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%		subplot(2,1,1), plotmf(a,'input',1)
%		a=rmmf(a,'input',1,'mf',2);
%		subplot(2,1,2), plotmf(a,'input',1)
%
%	See also ADDMF, ADDRULE, ADDVAR, PLOTMF, and RMVAR.

%	Ned Gulley, 2-2-94
%	Copyright (c) 1994-95 by The MathWorks, Inc.
%	$Revision: 1.6 $  $Date: 1995/02/17 13:08:10 $

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

if isempty(mfIndex),
    errorStr='No membership function was selected!';
    if nargout<2,
	error(errorStr)
    else
	out=[]; return
    end
end

if strcmp(varType,'input'),
    if varIndex>numInputs,
    	errorStr=['There are only ' num2str(numInputs)	' input variables.'];
	if nargout<2,
	    error(errorStr)
	else
	    out=[]; return
	end
    end

    currNumMFs=numInputMFs(varIndex);
    if currNumMFs==0,
	errorStr='No membership functions left to remove';
	if nargout<2,
	    error(errorStr)
	else
	    out=[]; return
	end
    end

    if mfIndex>currNumMFs,
	errorStr=['There are only ' num2str(currNumMFs) ...
	    ' membership functions for this variable.'];
	if nargout<2,
	    error(errorStr)
	else
	    out=[]; return
	end
    end

    % Make sure the MF is not currently being used in the rules
    if numRules>0,
	usageIndex=find(ruleList(:,varIndex)==mfIndex);
    else
	usageIndex=[];
    end
    if length(usageIndex),
	errorStr=['Cannot remove. MF "' ...
	    getfis(fis,varType,varIndex,mfFlag,mfIndex,'name') ...
	    '" is referenced in rule(s): ' fmat2str(usageIndex')];
	if nargout<2,
	    error(errorStr)
	else
	    out=[]; return
	end
    end

    % Remove three rows from the FIS matrix: inMFLabels, inMFTypes, and inMFParams
    MFRowIndex=sum(numInputMFs(1:(varIndex-1)))+mfIndex;
    inMFLabelsFirstRow=12+2*(numInputs+numOutputs);
    inMFLabelsRmPtr=inMFLabelsFirstRow+MFRowIndex-1;

    inMFTypesFirstRow=12+2*(numInputs+numOutputs)+totalInputMFs+totalOutputMFs;
    inMFTypesRmPtr=inMFTypesFirstRow+MFRowIndex-1;

    inMFParamsFirstRow=12+2*(numInputs+numOutputs)+2*(totalInputMFs+totalOutputMFs);
    inMFParamsRmPtr=inMFParamsFirstRow+MFRowIndex-1;

    % Remove all rows at once so we don't throw off the row arithmetic
    fis([inMFLabelsRmPtr inMFTypesRmPtr inMFParamsRmPtr],:)=[];

    % Now update the number of input MFs field accordingly
    numInputMFs(varIndex)=currNumMFs-1;
    fis(4,1:numInputs)=numInputMFs;

    % And update the rules
    if numRules>0,
    	ruleList(:,varIndex)=ruleList(:,varIndex)-(ruleList(:,varIndex)>mfIndex);
    	fis=setfis(fis,'ruleList',ruleList);
    end

elseif strcmp(varType,'output'),
    if varIndex>numOutputs,
    	errorStr=['There are only ' num2str(numOutputs)	' output variables.'];
	if nargout<2,
	    error(errorStr)
	else
	    out=[]; return
	end
    end

    currNumMFs=numOutputMFs(varIndex);
    if currNumMFs==0,
	errorStr='No membership functions left to remove';
	if nargout<2,
	    error(errorStr)
	else
	    out=[]; return
	end
    end

    if mfIndex>currNumMFs,
	errorStr=['There are only ' num2str(currNumMFs) ...
	    ' membership functions for this variable.'];
	if nargout<2,
	    error(errorStr)
	else
	    out=[]; return
	end
    end

    % Make sure the MF is not currently being used in the rules
    if numRules>0,
	usageIndex=find(ruleList(:,varIndex+numInputs)==mfIndex);
    else
	usageIndex=[];
    end
    if length(usageIndex),
	errorStr=['Cannot remove. MF "' ...
	    getfis(fis,varType,varIndex,mfFlag,mfIndex,'name') ...
	    '" is referenced in rule(s): ' fmat2str(usageIndex')];
	if nargout<2,
	    error(errorStr)
	else
	    out=[]; return
	end
    end

    % Remove three rows from the FIS matrix: outMFLabels, outMFTypes, and outMFParams
    MFRowIndex=sum(numOutputMFs(1:(varIndex-1)))+mfIndex;
    outMFLabelsFirstRow=12+2*(numInputs+numOutputs)+totalInputMFs;
    outMFLabelsRmPtr=outMFLabelsFirstRow+MFRowIndex-1;

    outMFTypesFirstRow=12+2*(numInputs+numOutputs)+2*totalInputMFs+totalOutputMFs;
    outMFTypesRmPtr=outMFTypesFirstRow+MFRowIndex-1;

    outMFParamsFirstRow=12+2*(numInputs+numOutputs)+3*totalInputMFs+2*totalOutputMFs;
    outMFParamsRmPtr=outMFParamsFirstRow+MFRowIndex-1;

    % Remove all rows at once so we don't throw off the row arithmetic
    fis([outMFLabelsRmPtr outMFTypesRmPtr outMFParamsRmPtr],:)=[];

    % Now update the number of output MFs field accordingly
    numOutputMFs(varIndex)=currNumMFs-1;
    fis(5,1:numOutputs)=numOutputMFs;

    % And update the rules
    if numRules>0,
    	ruleList(:,varIndex+numInputs)=ruleList(:,varIndex+numInputs)- ...
	    (ruleList(:,varIndex+numInputs)>mfIndex);
    	fis=setfis(fis,'ruleList',ruleList);
    end

end

out=fis;

