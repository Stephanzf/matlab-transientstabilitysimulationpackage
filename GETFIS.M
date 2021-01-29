function out=getfis(fis,arg1,arg2,arg3,arg4,arg5)
%GETFIS	Get fuzzy inference system properties.
%	OUT = GETFIS(FIS) returns a list of general information about the
%	fuzzy inference system FIS. OUT = GETFIS(FIS,'fisProp') returns 
%	the current value of the FIS property called 'fisProp'.
%
%	OUT = GETFIS(FIS,'varType',varIndex) returns a list of general
%	information about the specified FIS variable.
%	OUT = GETFIS(FIS,'varType',varIndex,'varProp') returns the current
%	value of the variable property called 'varProp'.
%
%	OUT = GETFIS(FIS,'varType',varIndex,'mf',mfIndex) returns a list of
%	general information about the specified FIS membership function.
%	OUT = GETFIS(FIS,'varType',varIndex,'mf',mfIndex,'mfProp') returns
%	the current value of the membership function property called 'mfProp'.
%
%	For example:
%
%		a=newfis('tipper');
%		a=addvar(a,'input','service',[0 10]);
%		a=addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%		a=addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%		getfis(a)
%		getfis(a,'input',1)
%		getfis(a,'input',1,'mf',2)
%
%	See also SETFIS and SHOWFIS.

%	Ned Gulley, 2-2-94
%	Copyright (c) 1994-95 by The MathWorks, Inc.
%	$Revision: 1.16 $  $Date: 1995/02/17 13:08:10 $

numInputs=fis(3,1);
numOutputs=fis(3,2);
numInputMFs=fis(4,1:numInputs);
totalInputMFs=sum(numInputMFs);
numOutputMFs=fis(5,1:numOutputs);
totalOutputMFs=sum(numOutputMFs);

% ===============================================
% Handle generic inquiries related to the whole fis
% ===============================================
if nargin==1,
    indent=32*ones(1,8);
    disp([indent,'Name = ',getfis(fis,'Name')]);
    disp([indent,'Type = ',getfis(fis,'Type')]);
    disp([indent,'NumInputs = ',num2str(numInputs)]);
    disp([indent,'InLabels = ']);
    if numInputs~=0,
	disp([32*ones(numInputs,16),getfis(fis,'InLabels')]);
    end
    disp([indent,'NumOutputs = ',num2str(numOutputs)]);
    disp([indent,'OutLabels = ']);
    if numOutputs~=0,
	disp([32*ones(numOutputs,16),getfis(fis,'OutLabels')]);
    end
    disp([indent,'NumRules = ',num2str(getfis(fis,'NumRules'))]);
    disp([indent,'AndMethod = ',num2str(getfis(fis,'AndMethod'))]);
    disp([indent,'OrMethod = ',num2str(getfis(fis,'OrMethod'))]);
    disp([indent,'ImpMethod = ',num2str(getfis(fis,'ImpMethod'))]);
    disp([indent,'AggMethod = ',num2str(getfis(fis,'AggMethod'))]);
    disp([indent,'DefuzzMethod = ',num2str(getfis(fis,'DefuzzMethod'))]);
    out=[];

% ===============================================
elseif nargin==2,
    propName=lower(arg1);

    if strcmp(propName,'name'),
    	out=deblank(setstr(fis(1,:)));

    elseif strcmp(propName,'type'),
    	out=deblank(setstr(fis(2,:)));

    elseif strcmp(propName,'numinputs'),
    	out=numInputs;

    elseif strcmp(propName,'numoutputs'),
 	out=numOutputs;

    elseif strcmp(propName,'numinputmfs'),
    	out=numInputMFs;

    elseif strcmp(propName,'numoutputmfs'),
    	out=numOutputMFs;

    elseif strcmp(propName,'numrules'),
    	out=fis(6,1);

    elseif strcmp(propName,'andmethod'),
    	out=deblank(setstr(fis(7,:)));

    elseif strcmp(propName,'ormethod'),
    	out=deblank(setstr(fis(8,:)));

    elseif strcmp(propName,'impmethod'),
    	out=deblank(setstr(fis(9,:)));

    elseif strcmp(propName,'aggmethod'),
    	out=deblank(setstr(fis(10,:)));

    elseif strcmp(propName,'defuzzmethod'),
    	out=deblank(setstr(fis(11,:)));

    elseif strcmp(propName,'inlabels'),
    	firstRow=12;
    	lastRow=firstRow+numInputs-1;
    	out=fis(firstRow:lastRow,:);
    	out=setstr(out);

    elseif strcmp(propName,'outlabels'),
    	firstRow=12+numInputs;
    	lastRow=firstRow+numOutputs-1;
    	out=fis(firstRow:lastRow,:);
    	out=setstr(out);

    elseif strcmp(propName,'inrange'),
    	firstRow=12+numInputs+numOutputs;
    	lastRow=firstRow+numInputs-1;
    	out=fis(firstRow:lastRow,1:2);

    elseif strcmp(propName,'outrange'),
    	firstRow=12+2*numInputs+numOutputs;
    	lastRow=firstRow+numOutputs-1;
    	out=fis(firstRow:lastRow,1:2);

    elseif strcmp(propName,'inmflabels'),
    	firstRow=12+2*(numInputs+numOutputs);
    	lastRow=firstRow+totalInputMFs-1;
    	out=fis(firstRow:lastRow,:);
    	out=setstr(out);

    elseif strcmp(propName,'outmflabels'),
    	firstRow=12+2*(numInputs+numOutputs)+totalInputMFs;
    	lastRow=firstRow+totalOutputMFs-1;
    	out=fis(firstRow:lastRow,:);
    	out=setstr(out);

    elseif strcmp(propName,'inmftypes'),
    	firstRow=12+2*(numInputs+numOutputs)+totalInputMFs+totalOutputMFs;
    	lastRow=firstRow+totalInputMFs-1;
    	out=fis(firstRow:lastRow,:);
    	out=setstr(out);

    elseif strcmp(propName,'outmftypes'),
    	firstRow=12+2*(numInputs+numOutputs)+2*totalInputMFs+totalOutputMFs;
    	lastRow=firstRow+totalOutputMFs-1;
    	out=fis(firstRow:lastRow,:);
    	out=setstr(out);

    elseif strcmp(propName,'inmfparams'),
    	firstRow=12+2*(numInputs+numOutputs)+2*totalInputMFs+2*totalOutputMFs;
    	lastRow=firstRow+totalInputMFs-1;
	fisType=deblank(setstr(fis(2,:)));
	lastCol=4;
    	out=fis(firstRow:lastRow,1:lastCol);

    elseif strcmp(propName,'outmfparams'),
    	firstRow=12+2*(numInputs+numOutputs)+3*totalInputMFs+2*totalOutputMFs;
    	lastRow=firstRow+totalOutputMFs-1;
	fisType=deblank(setstr(fis(2,:)));
	if strcmp(fisType,'mamdani'),
	    lastCol=4;
	else
	    lastCol=numInputs+1;
	end
    	out=fis(firstRow:lastRow,1:lastCol);

    elseif strcmp(propName,'rulelist'),
	numRules=abs(fis(6,1));
	numCols=numInputs+numOutputs+2;
    	firstRow=12+2*(numInputs+numOutputs)+3*(totalInputMFs+totalOutputMFs);
    	lastRow=firstRow+numRules-1;
    	out=fis(firstRow:lastRow,1:numCols);

    elseif strcmp(propName,'inputs'),
	indent=32*ones(1,8);
	disp([indent,'Name = ',getfis(fis,'Name')]);
	disp([indent,'NumInputs = ',num2str(numInputs)]);
	disp([indent,'InLabels = ']);
	if numInputs~=0,
	    disp([32*ones(numInputs,16),getfis(fis,'InLabels')]);
	end
	out=[];

    elseif strcmp(propName,'outputs'),
	indent=32*ones(1,8);
	disp([indent,'Name = ',getfis(fis,'Name')]);
	disp([indent,'NumOutputs = ',num2str(numOutputs)]);
	disp([indent,'OutLabels = ']);
	if numOutputs~=0,
	    disp([32*ones(numOutputs,16),getfis(fis,'OutLabels')]);
	end
	out=[];

    else
    	error(['There is no FIS system property called ', propName]);

    end

% ===============================================
% Handle generic inquiries related to VARIABLES
% ===============================================
elseif nargin==3,
    if strcmp(arg1,'input') | strcmp(arg1,'output'),
 	varType=lower(arg1);
    	varIndex=arg2;

    	indent=32*ones(1,8);
    	numMFs=getfis(fis,varType,varIndex,'NumMFs');
    	disp([indent,'Name = ', ...
	    getfis(fis,varType,varIndex,'Name')]);
    	disp([indent,'NumMFs = ',num2str(numMFs)]);
    	disp([indent,'MFLabels = ']);
	if numMFs~=0,
	    disp([32*ones(numMFs,16),getfis(fis,varType,varIndex,'MFLabels')]);
	end
    	range=getfis(fis,varType,varIndex,'Range');
    	disp([indent,'Range = ', ...
	    '[',num2str(range(1)),' ',num2str(range(2)),']']);
    	out=[];

    end

% ===============================================
% Handle specific inquiries related to VARIABLES
% ===============================================
elseif nargin==4,
    varType=lower(arg1);
    varIndex=arg2;
    varProp=lower(arg3);
    if strcmp(varType,'input'),
    	if varIndex>numInputs,
	    error(['There are not that many input variables.']);
   	end

	if strcmp(varProp,'name'),
	    varList=getfis(fis,'inlabels');
	    out=deblank(varList(varIndex,:));
    	end

	if strcmp(varProp,'range'),
	    varList=getfis(fis,'inrange');
	    out=varList(varIndex,:);
    	end

	if strcmp(varProp,'nummfs'),
	    varList=getfis(fis,'numInputMFs');
	    out=varList(varIndex);
    	end

	if strcmp(varProp,'mflabels'),
	    numMFs=getfis(fis,'input',varIndex,'numMFs');
	    MFList=getfis(fis,'inMFlabels');
	    MFIndexBegin=sum(numInputMFs(1:(varIndex-1)))+1;
	    MFIndexEnd=MFIndexBegin+numMFs-1;
	    out=MFList(MFIndexBegin:MFIndexEnd,:);
    	end

    elseif strcmp(varType,'output'),
    	if varIndex>numOutputs,
	    error(['There are not that many output variables.']);
   	end

	if strcmp(varProp,'name'),
	    varList=getfis(fis,'outlabels');
	    out=deblank(varList(varIndex,:));
    	end

	if strcmp(varProp,'range'),
	    varList=getfis(fis,'outrange');
	    out=varList(varIndex,:);
    	end

	if strcmp(varProp,'nummfs'),
	    varList=getfis(fis,'numOutputMFs');
	    out=varList(varIndex);
    	end

	if strcmp(varProp,'mflabels'),
	    numMFs=getfis(fis,'output',varIndex,'numMFs');
	    MFList=getfis(fis,'outMFlabels');
	    MFIndexBegin=sum(numOutputMFs(1:(varIndex-1)))+1;
	    MFIndexEnd=MFIndexBegin+numMFs-1;
	    out=MFList(MFIndexBegin:MFIndexEnd,:);
    	end

    else
 	error(['Variable type must be either "input" or "output"']);

    end

    % Rip out zeros if the output is a string
    if isstr(out)&(size(out,1)==1),
    	out(out==0)=[];
    end

% ===============================================
% Handle generic inquiries related to MEMBERSHIP FUNCTIONS
% ===============================================
elseif nargin==5,
    if strcmp(arg1,'input') | strcmp(arg1,'output'),
 	varType=lower(arg1);
    	varIndex=arg2;
	MFIndex=arg4;

    	indent=32*ones(1,8);
    	MFLabels=getfis(fis,varType,varIndex,'MFLabels');
    	disp([indent,'Name = ', ...
	    getfis(fis,varType,varIndex,'MF',MFIndex,'Name')]);
    	disp([indent,'Type = ', ...
	    getfis(fis,varType,varIndex,'MF',MFIndex,'Type')]);
	params=getfis(fis,varType,varIndex,'MF',MFIndex,'Params');
    	disp([indent,'Params = '])
	disp(params);
%	    '[',num2str(params(1)),' ',num2str(params(2)),' ', ...
%	    num2str(params(3)),' ', num2str(params(4)),']']);
    	out=[];

    end

% ===============================================
% Handle specific inquiries related to MEMBERSHIP FUNCTIONS
% ===============================================
elseif nargin==6,
    varType=lower(arg1);
    varIndex=arg2;
    MFIndex=arg4;
    MFProp=lower(arg5);

    if strcmp(varType,'input'),
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
	    MFList=getfis(fis,'inMFlabels');
	    out=deblank(MFList(MFRowIndex,:));
    	end

	if strcmp(MFProp,'type'),
	    MFTypeList=getfis(fis,'inMFtypes');
	    out=deblank(MFTypeList(MFRowIndex,:));
    	end

	if strcmp(MFProp,'params'),
	    MFTypeList=getfis(fis,'inMFtypes');
	    MFType=deblank(MFTypeList(MFRowIndex,:));
	    MFParamsList=getfis(fis,'inMFparams');
	    if strcmp(MFType,'gaussmf') | strcmp(MFType,'sigmf') ...
		| strcmp(MFType,'smf'),
	    	out=MFParamsList(MFRowIndex,1:2);
	    elseif strcmp(MFType,'trimf') | strcmp(MFType,'gbellmf'),
	    	out=MFParamsList(MFRowIndex,1:3);
	    else
	    	out=MFParamsList(MFRowIndex,1:4);
	    end
    	end

    elseif strcmp(varType,'output'),
    	if varIndex>numOutputs,
	    error(['There are not that many output variables.']);
   	end

	MFRowIndex=sum(numOutputMFs(1:(varIndex-1)))+MFIndex;

	if strcmp(MFProp,'name'),
	    MFList=getfis(fis,'outMFlabels');
	    out=deblank(MFList(MFRowIndex,:));
    	end

	if strcmp(MFProp,'type'),
	    MFTypeList=getfis(fis,'outMFtypes');
	    out=deblank(MFTypeList(MFRowIndex,:));
    	end

	if strcmp(MFProp,'params'),
	    % Output MF params are complicated by the fact that they
	    % look completely different for Sugeno and Mamdani systems
	    MFParamsList=getfis(fis,'outMFparams');
	    out=MFParamsList(MFRowIndex,:);
	    MFTypeList=getfis(fis,'outMFtypes');
	    MFType=deblank(MFTypeList(MFRowIndex,:));
	    fisType=deblank(getfis(fis,'type'));
	    if strcmp(fisType,'mamdani'),
		if strcmp(MFType,'gaussmf') | strcmp(MFType,'sigmf') ...
		    | strcmp(MFType,'smf'),
		    out=MFParamsList(MFRowIndex,1:2);
		elseif strcmp(MFType,'trimf') | strcmp(MFType,'gbellmf'),
		    out=MFParamsList(MFRowIndex,1:3);
		else
		    out=MFParamsList(MFRowIndex,1:4);
		end
	    elseif strcmp(fisType,'sugeno'),
		if strcmp(MFType,'constant'),
		    out=out(numInputs+1);
		elseif strcmp(MFType,'linear'),
		    out=out(1:numInputs+1);
		end
	    end
    	end

    end

end

% Rip out zeros if the output is a string
if (isstr(out)) & ~isempty(out),
    zeroIndex=find(sum(out)==0);
    out(:,zeroIndex)=[];
end

