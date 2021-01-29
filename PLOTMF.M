function [xOut,yOut]=plotmf(fis,varType,varIndex,numPts)
%PLOTMF Display all membership functions for one variable.
%	PLOTMF(fismat,varType,varIndex) plots all the membership functions 
%	associated with a specified variable in the fuzzy inference system
%	given by the matrix fismat.
%
%	[xOut,yOut]=PLOTMF(fismat,varType,varIndex) returns the x and y data
%	points associated with the membership functions without plotting them.
%
%	PLOTMF(fismat,varType,varIndex,numPts) generates the same plot with
%	exactly numPts points plotted along the curve.
%
%	For example:
%
%		a=newfis('tipper');
%		a=addvar(a,'input','service',[0 10]);
%		a=addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%		a=addmf(a,'input',1,'good','gaussmf',[1.5 5]);
%		a=addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
% 		plotmf(a,'input',1)
%
%	See also EVALMF, and PLOTFIS.

%	Ned Gulley, 10-30-94
%	Copyright (c) 1994-95 by The MathWorks, Inc.
%	$Revision: 1.6 $  $Date: 1995/02/17 13:08:10 $

%====================================
if nargin<4, numPts=181; end

fisType=getfis(fis,'type');

if strcmp(varType,'input'),
    numAllVarMFs=getfis(fis,'numInputMFs');
    mfTypeList=getfis(fis,'inMFTypes');
    mfParamsList=getfis(fis,'inMFParams');
    varRangeList=getfis(fis,'inRange');

elseif strcmp(varType,'output') & ~strcmp(fisType,'sugeno'),
    numAllVarMFs=getfis(fis,'numOutputMFs');
    mfTypeList=getfis(fis,'outMFTypes');
    mfParamsList=getfis(fis,'outMFParams');
    varRangeList=getfis(fis,'outRange');

else
    error('No plots for Sugeno Output MFs')
end

numMFs=numAllVarMFs(varIndex);
y=zeros(numPts,numMFs);

varRange=varRangeList(varIndex,:);
xPts=linspace(varRange(1),varRange(2),numPts)';
x=xPts(:,ones(numMFs,1));
for mfIndex=1:numMFs,
    mfIndex2=sum(numAllVarMFs(1:(varIndex-1)))+mfIndex;
    mfType=deblank(mfTypeList(mfIndex2,:));
    mfParams=mfParamsList(mfIndex2,:);
    y(:,mfIndex)=evalmf(xPts,mfParams,mfType);
end

if nargout<1,
    plot(x,y)
    xlabel(getfis(fis,varType,varIndex,'name'))
    ylabel('Degree of membership')
    axis([varRange(1) varRange(2) -0.1 1.1])
    mfNameList=getfis(fis,varType,varIndex,'MFLabels');
    for mfIndex=1:numMFs,
        mfName=deblank(mfNameList(mfIndex,:));
        centerIndex=find(y(:,mfIndex)==max(y(:,mfIndex)));
        centerIndex=mean(centerIndex);
        text(x(centerIndex,mfIndex),1.05,mfName, ...
            'HorizontalAlignment','center', ...
            'VerticalAlignment','middle', ...
	    'FontSize',10)
    end
else
    xOut=x;
    yOut=y;
end
