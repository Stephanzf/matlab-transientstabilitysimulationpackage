function showfis(fis)
%SHOWFIS Display annotated FIS.
%	SHOWFIS(fismat) displays a text version of the variable
%	fismat annotated row by row, allowing you to see the
%	significance of each row.
%
%	For example:
%
%		a=newfis('tipper');
%		a=addvar(a,'input','service',[0 10]);
%		a=addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%		a=addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%		showfis(a)
%
%	See also GETFIS.

%	Ned Gulley, 3-15-94
%	Copyright (c) 1994-95 by The MathWorks, Inc.
%	$Revision: 1.9 $  $Date: 1995/02/17 13:08:10 $

NumInputs=fis(3,1);
NumOutputs=fis(3,2);
NumInputMFs=fis(4,1:NumInputs);
totalInputMFs=sum(NumInputMFs);
NumOutputMFs=fis(5,1:NumOutputs);
totalOutputMFs=sum(NumOutputMFs);
NumRules=fis(6,1);

disp(['1.  Name             ',getfis(fis,'Name')]);
disp(['2.  Type             ',getfis(fis,'Type')]);
disp(['3.  Inputs/Outputs   ',fmat2str([NumInputs NumOutputs])])
disp(['4.  NumInputMFs      ',fmat2str(NumInputMFs)]);
disp(['5.  NumOutputMFs     ',fmat2str(NumOutputMFs)]);
disp(['6.  NumRules         ',num2str(getfis(fis,'NumRules'))]);
disp(['7.  AndMethod        ',getfis(fis,'AndMethod')]);
disp(['8.  OrMethod         ',getfis(fis,'OrMethod')]);
disp(['9.  ImpMethod        ',getfis(fis,'ImpMethod')]);
disp(['10. AggMethod        ',getfis(fis,'AggMethod')]);
disp(['11. DefuzzMethod     ',getfis(fis,'DefuzzMethod')]);
if NumInputs>0,
    InLabels=getfis(fis,'InLabels');
    firstRow=12;
    dispStr=[num2str(firstRow) '. InLabels         ' InLabels(1,:)];
    for n=2:NumInputs,
    dispStr=str2mat(dispStr, ...
        [num2str(firstRow+n-1) '.' 32*ones(1,18) InLabels(n,:)]);
    end
    disp(dispStr);
end
if NumOutputs>0,
    OutLabels=getfis(fis,'OutLabels');
    firstRow=12+NumInputs;
    dispStr=[num2str(firstRow) '. OutLabels        ' OutLabels(1,:)];
    for n=2:NumOutputs,
    dispStr=str2mat(dispStr, ...
        [num2str(firstRow+n-1) '.' 32*ones(1,18) OutLabels(n,:)]);
    end
    disp(dispStr);
end
if NumInputs>0,
    InRange=getfis(fis,'InRange');
    firstRow=12+NumInputs+NumOutputs;
    dispStr=[num2str(firstRow) '. InRange          ' fmat2str(InRange(1,:),4)];
    for n=2:NumInputs,
    dispStr=str2mat(dispStr, ...
        [num2str(firstRow+n-1) '.' 32*ones(1,18) fmat2str(InRange(n,:),4)]);
    end
    disp(dispStr);
end
if NumOutputs>0,
    OutRange=getfis(fis,'OutRange');
    firstRow=12+2*NumInputs+NumOutputs;
    dispStr=[num2str(firstRow) '. OutRange         ' fmat2str(OutRange(1,:),4)];
    for n=2:NumOutputs,
    dispStr=str2mat(dispStr, ...
        [num2str(firstRow+n-1) '.' 32*ones(1,18) fmat2str(OutRange(n,:),4)]);
    end
        disp(dispStr);
end
if totalInputMFs>0,
    InMFLabels=getfis(fis,'InMFLabels');
    firstRow=12+2*(NumInputs+NumOutputs);
    dispStr=[num2str(firstRow) '. InMFLabels       ' InMFLabels(1,:)];
    for n=2:totalInputMFs,
    dispStr=str2mat(dispStr, ...
        [num2str(firstRow+n-1) '.' 32*ones(1,18) InMFLabels(n,:)]);
    end
        disp(dispStr);
end
if totalOutputMFs>0,
    OutMFLabels=getfis(fis,'OutMFLabels');
    firstRow=12+2*(NumInputs+NumOutputs)+totalInputMFs;
    dispStr=[num2str(firstRow) '. OutMFLabels      ' OutMFLabels(1,:)];
    for n=2:totalOutputMFs,
        dispStr=str2mat(dispStr, ...
        [num2str(firstRow+n-1) '.' 32*ones(1,18) OutMFLabels(n,:)]);
    end
    disp(dispStr);
end
if totalInputMFs>0,
    InMFTypes=getfis(fis,'InMFTypes');
    firstRow=12+2*(NumInputs+NumOutputs)+totalInputMFs+totalOutputMFs;
    dispStr=[num2str(firstRow) '. InMFTypes        ' InMFTypes(1,:)];
    for n=2:totalInputMFs,
    dispStr=str2mat(dispStr, ...
        [num2str(firstRow+n-1) '.' 32*ones(1,18) InMFTypes(n,:)]);
    end
        disp(dispStr);
end
if totalOutputMFs>0,
    OutMFTypes=getfis(fis,'OutMFTypes');
    firstRow=12+2*(NumInputs+NumOutputs)+2*totalInputMFs+totalOutputMFs;
    dispStr=[num2str(firstRow) '. OutMFTypes       ' OutMFTypes(1,:)];
    for n=2:totalOutputMFs,
    dispStr=str2mat(dispStr, ...
        [num2str(firstRow+n-1) '.' 32*ones(1,18) OutMFTypes(n,:)]);
    end
    disp(dispStr);
end
if totalInputMFs>0,
    InMFParams=getfis(fis,'InMFParams');
    firstRow=12+2*(NumInputs+NumOutputs)+2*totalInputMFs+2*totalOutputMFs;
    dispStr=[num2str(firstRow) '. InMFParams       ' fmat2str(InMFParams(1,:),4)];
     for n=2:totalInputMFs,
        dispStr=str2mat(dispStr, ...
        [num2str(firstRow+n-1) '.' 32*ones(1,18) fmat2str(InMFParams(n,:),4)]);
    end
    disp(dispStr);
end
if totalOutputMFs>0,
    OutMFParams=getfis(fis,'OutMFParams');
    firstRow=12+2*(NumInputs+NumOutputs)+3*totalInputMFs+2*totalOutputMFs;
    dispStr=[num2str(firstRow) '. OutMFParams      ' fmat2str(OutMFParams(1,:),4)];
    for n=2:totalOutputMFs,
    dispStr=str2mat(dispStr, ...
        [num2str(firstRow+n-1) '.' 32*ones(1,18) fmat2str(OutMFParams(n,:),4)]);
    end
    disp(dispStr);
end
if NumRules>0,
    ruleList=getfis(fis,'ruleList');
    firstRow=12+2*(NumInputs+NumOutputs)+3*totalInputMFs+3*totalOutputMFs;
    dispStr=[num2str(firstRow) '. RuleList         ' fmat2str(ruleList(1,:),4)];
    for n=2:NumRules,
    dispStr=str2mat(dispStr, ...
        [num2str(firstRow+n-1) '.' 32*ones(1,18) fmat2str(ruleList(n,:),4)]);
    end
    disp(dispStr);
end
