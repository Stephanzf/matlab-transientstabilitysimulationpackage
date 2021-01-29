function out=setfis(fis,arg1,arg2,arg3,arg4,arg5,arg6)
%SETFIS	Set fuzzy inference system properties.
%	FIS2 = SETFIS(FIS1,'fisPropName',newPropValue) returns the FIS matrix
%	FIS2 which is identical to FIS1 except that the FIS property 
%	corresponding to 'fisPropName' is set to newPropValue.
%
%	FIS2 = SETFIS(FIS1,varType,varIndex,'varPropName',newPropValue)
%	returns FIS2, in which a property associated with the variable
%	specified by varType and varIndex has been set to a new value.
%
%	FIS2 = SETFIS(FIS1,varType,varIndex,'mf',mfIndex, ...
%		'mfPropName',newPropValue) returns FIS2, in which a property 
%	associated with the membership function specified by varType,
%	varIndex, and mfIndex has been set to a new value.
%
%	For example:
%
%		a=newfis('tipper');
%		a=addvar(a,'input','service',[0 10]);
%		a=addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%		a=addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%		getfis(a)
%		a=setfis(a,'Name','tip_example');
%		a=setfis(a,'DefuzzMethod','bisector');
%		a=setfis(a,'input',1,'Name','quality');
%		getfis(a)
%
%	See also GETFIS.

%	Ned Gulley, 2-2-94
%	Copyright (c) 1994-95 by The MathWorks, Inc.
%	$Revision: 1.13 $  $Date: 1995/02/17 13:08:10 $

numInputs=fis(3,1);
numOutputs=fis(3,2);
numInputMFs=fis(4,1:numInputs);
totalInputMFs=sum(numInputMFs);
numOutputMFs=fis(5,1:numOutputs);
totalOutputMFs=sum(numOutputMFs);
numrules=fis(6,1);
fieldWid=size(fis,2);

if nargin==1,
    indent=32*ones(1,8);
    disp([indent,'Name']);
    disp([indent,'Type']);
    disp([indent,'NumInputs']);
    disp([indent,'InRange']);
    disp([indent,'InLabels']);
    disp([indent,'NumInputMFs']);
    disp([indent,'NumOutputs']);
    disp([indent,'OutRange']);
    disp([indent,'OutLabels']);
    disp([indent,'NumOutputMFs']);
    disp([indent,'NumRules']);
    disp([indent,'AndMethod']);
    disp([indent,'OrMethod']);
    disp([indent,'ImpMethod']);
    disp([indent,'AggMethod']);
    disp([indent,'DefuzzMethod']);
    return

elseif nargin==3,
    propName=lower(arg1);
    newVal=arg2;

    if length(arg2)>=fieldWid,
	newEntry=newVal;
    else
	% Pad with zeros if newVal isn't as long as the current fis width
	newEntry=[newVal zeros(size(newVal,1),fieldWid-size(newVal,2))];
    end
    newEntryWid=size(newEntry,2);
 
    if strcmp(propName,'name'),
    	fis(1,1:newEntryWid)=abs(newEntry);
	out=fis;

    elseif strcmp(propName,'type'),
    	fis(2,1:newEntryWid)=abs(newEntry);
	out=fis;

    elseif strcmp(propName,'numinputs'),
 	fis(3,1)=newVal;
	out=fis;

    elseif strcmp(propName,'numoutputs'),
 	fis(3,2)=newVal;
	out=fis;

    elseif strcmp(propName,'numinputmfs'),
    	fis(4,1:newEntryWid)=newEntry;
	out=fis;

    elseif strcmp(propName,'numoutputmfs'),
    	fis(5,1:newEntryWid)=newEntry;
	out=fis;

    elseif strcmp(propName,'numrules'),
 	fis(6,1)=newVal;
	out=fis;

    elseif strcmp(propName,'andmethod'),
    	fis(7,1:newEntryWid)=abs(newEntry);
	out=fis;

    elseif strcmp(propName,'ormethod'),
    	fis(8,1:newEntryWid)=abs(newEntry);
	out=fis;

    elseif strcmp(propName,'impmethod'),
    	fis(9,1:newEntryWid)=abs(newEntry);
	out=fis;

    elseif strcmp(propName,'aggmethod'),
    	fis(10,1:newEntryWid)=abs(newEntry);
	out=fis;

    elseif strcmp(propName,'defuzzmethod'),
    	fis(11,1:newEntryWid)=abs(newEntry);
	out=fis;

    elseif strcmp(propName,'inlabels'),
	error('You may not set this property directly');

    elseif strcmp(propName,'outlabels'),
	error('You may not set this property directly');

    elseif strcmp(propName,'inmflabels'),
	error('You may not set this property directly');

    elseif strcmp(propName,'outmflabels'),
	error('You may not set this property directly');

    elseif strcmp(propName,'inrange'),
	error('You may not set this property directly');

    elseif strcmp(propName,'outrange'),
	error('You may not set this property directly');

    elseif strcmp(propName,'inmftypes'),
	error('You may not set this property directly');

    elseif strcmp(propName,'outmftypes'),
	error('You may not set this property directly');

    elseif strcmp(propName,'inmfparams'),
    	firstRow=12+2*(numInputs+numOutputs)+2*totalInputMFs+2*totalOutputMFs;
    	lastRow=firstRow+totalInputMFs-1;
	if size(newEntry,1)>totalInputMFs,
	    error('Too many rows in new inMFParams list')
	end
    	fis(firstRow:lastRow,:)=newEntry;
        out=fis;

    elseif strcmp(propName,'outmfparams'),
    	firstRow=12+2*(numInputs+numOutputs)+3*totalInputMFs+2*totalOutputMFs;
    	lastRow=firstRow+totalOutputMFs-1;
	if size(newEntry,1)>totalOutputMFs,
	    error('Too many rows in new outMFParams list')
	end
    	fis(firstRow:lastRow,:)=newEntry;
        out=fis;

    elseif strcmp(propName,'rulelist'),
	numRules=fis(6,1);
  	newNumRules=size(newEntry,1);
    	firstRow=12+2*(numInputs+numOutputs)+3*(totalInputMFs+totalOutputMFs);
    	lastRow=firstRow+numRules-1;
	newLastRow=firstRow+newNumRules-1;
	if newNumRules<numRules,
	    % If there are fewer rules than there were, we need to 
	    % remove some of the rows.
	    fis((firstRow+newNumRules):lastRow,:)=[];
	end
    	fis(firstRow:newLastRow,1:newEntryWid)=newEntry;
	out=fis;

    else
    	error(['There is no FIS system property called ', propName]);

    end

% ===============================================
% Handle VARIABLES
% ===============================================
elseif nargin==5,
    % Name assignment
    % ===========================================
    varType=lower(arg1);
    varIndex=arg2;
    varProp=lower(arg3);
    newVal=arg4;

    % New value preparation
    % ===========================================
    if length(newVal)>fieldWid,
	newEntry=newVal;
    else
	% Pad with zeros
	newEntry=[newVal zeros(1,fieldWid-length(newVal))];
    end
    newEntryWid=length(newEntry);
 
    if strcmp(varType,'input'),
    	if varIndex>numInputs,
	    error(['There are not that many input variables.']);
   	end

	if strcmp(varProp,'name'),
	    inLabelsFirstRow=12;
	    fis(inLabelsFirstRow+varIndex-1,1:newEntryWid)=abs(newEntry);
	    out=fis;
    	end

	if strcmp(varProp,'range'),
    	    inRangeFirstRow=12+numInputs+numOutputs;
	    fis(inRangeFirstRow+varIndex-1,1:newEntryWid)=newEntry;
	    out=fis;
    	end

	if strcmp(varProp,'nummfs'),
	    error('You may not set this property directly');
    	end

	if strcmp(varProp,'mflist'),
	    error('You may not set this property directly');
    	end

    elseif strcmp(varType,'output'),
	% Range checking
    	if varIndex>numOutputs,
	    error(['There are not that many output variables.']);
   	end

	if strcmp(varProp,'name'),
	    outLabelsFirstRow=12+numInputs;
	    fis(outLabelsFirstRow+varIndex-1,1:newEntryWid)=abs(newEntry);
	    out=fis;
    	end

	if strcmp(varProp,'range'),
    	    outRangeFirstRow=12+2*numInputs+numOutputs;
	    fis(outRangeFirstRow+varIndex-1,1:2)=newVal;
	    out=fis;
    	end

	if strcmp(varProp,'nummfs'),
	    error('You may not set this property directly');
    	end

	if strcmp(varProp,'mflist'),
	    error('You may not set this property directly');
    	end

    else
 	disp(['Variable type must be either "input" or "output"']);

    end

    % Rip out zeros if the output is a string
    if isstr(out)&(size(out,1)==1),
    	out(out==0)=[];
    end

% ===============================================
% Handle MEMBERSHIP FUNCTIONS
% ===============================================
elseif nargin==7,
    % Name assignment
    % ===========================================
    varType=lower(arg1);
    varIndex=arg2;
    MFIndex=arg4;
    MFProp=lower(arg5);
    newVal=arg6;

    % New value preparation
    % ===========================================
    if length(newVal)>fieldWid,
	newEntry=newVal;
    else
	% Pad with zeros
	newEntry=[newVal zeros(1,fieldWid-length(newVal))];
    end
    newEntryWid=length(newEntry);
 
    if strcmp(varType,'input'),
    	% Range checking
    	% =======================================
    	if varIndex>numInputs,
	    error(['There are not that many input variables.']);
   	end

	if MFIndex>numInputMFs(varIndex),
	    errStr=['There are only ',int2str(numInputMFs(varIndex)), ...
		' MFs associated with that variable'];
	    error(errStr)
	end
	
	MFRowIndex=sum(numInputMFs(1:(varIndex-1)))+MFIndex;

	if strcmp(MFProp,'name'),
	    inMFLabelsFirstRow=12+2*(numInputs+numOutputs);
	    fis(inMFLabelsFirstRow+MFRowIndex-1,1:newEntryWid)=abs(newEntry);
	    out=fis;
    	end

	if strcmp(MFProp,'type'),
	    inMFTypesFirstRow=12+2*(numInputs+numOutputs)+ ...
		totalInputMFs+totalOutputMFs;
	    fis(inMFTypesFirstRow+MFRowIndex-1,1:newEntryWid)=abs(newEntry);
	    out=fis;
    	end

	if strcmp(MFProp,'params'),
	    inMFParamsFirstRow=12+2*(numInputs+numOutputs)+ ...
		2*(totalInputMFs+totalOutputMFs);
	    fis(inMFParamsFirstRow+MFRowIndex-1,1:newEntryWid)=newEntry;
	    out=fis;
    	end

    elseif strcmp(varType,'output'),
    	% Range checking
    	% =======================================
    	if varIndex>numOutputs,
	    error(['There are not that many output variables.']);
   	end

	MFRowIndex=sum(numOutputMFs(1:(varIndex-1)))+MFIndex;

	if strcmp(MFProp,'name'),
	    outMFLabelsFirstRow=12+2*(numInputs+numOutputs)+totalInputMFs;
	    fis(outMFLabelsFirstRow+MFRowIndex-1,1:newEntryWid)=abs(newEntry);
	    out=fis;
    	end

	if strcmp(MFProp,'type'),
	    outMFTypesFirstRow=12+2*(numInputs+numOutputs)+ ...
		2*totalInputMFs+totalOutputMFs;
	    fis(outMFTypesFirstRow+MFRowIndex-1,1:newEntryWid)=abs(newEntry);
	    out=fis;
    	end

	if strcmp(MFProp,'params'),
	    outMFParamsFirstRow=12+2*(numInputs+numOutputs)+ ...
		3*totalInputMFs+2*totalOutputMFs;
	    fisType=deblank(getfis(fis,'type'));
	    MFType=deblank(getfis(fis,varType,varIndex,'mf',MFIndex,'type'));
	    if strcmp(fisType,'sugeno') & strcmp(MFType,'constant'),
		% Sugeno systems with constant output functions should only have
		% one parameter, and it should go in the numInputs+1 column
		newEntry(numInputs+1)=newEntry(1);
		newEntry(1)=0;
	    end

	    fis(outMFParamsFirstRow+MFRowIndex-1,1:newEntryWid)=newEntry;
	    out=fis;
    	end

    end

    % Rip out zeros if the output is a string
    if isstr(out),
    	out(out==0)=[];
    end

end

% Strip off unnecessary columns filled with zeros
% Flag all columns that contain any nonzeros
nonZeroColIndex=~all(out==0);
% This last piece of trickery guarantees that the zero columns we strip
% off are on the far right of the FIS matrix. Otherwise we may pluck out
% an important column in the middle that happens to be zeros.
removeIndex=~sign(fliplr(cumsum(fliplr(nonZeroColIndex))));
if any(removeIndex),
    out(:,removeIndex)=[];
end

