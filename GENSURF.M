function [xOut,yOut,zOut]=gensurf(fis,inputs,output,grids,refInput)
%GENSURF Return the output surface corresponding to the given FIS.
%	GENSURF(FIS) will generate a plot of the output surface of a
% 	fuzzy system using the first two inputs and the first output.
%	GENSURF(FIS,INPUTS,OUTPUT) will generate a plot using the inputs
%	(one or two) and output (only one is allowed) given by the
%	vector INPUTS and the scalar OUTPUT.
%
%	GENSURF(FIS,INPUTS,OUTPUT,GRIDS) allows you to specify the number
%	of grids in the X and Y directions. If GRIDS is a two element vector,
%	the grids in the X and Y directions can be set independently.
%
%	GENSURF(FIS,INPUTS,OUTPUT,GRIDS,REFINPUT) can be used if there 
%	are more than two outputs. REFINPUT then specifies the nonvarying
%	inputs to the system.
%
%	[X,Y,Z]=GENSURF(...) returns the variables that define the output
%	surface and suppresses automatic plotting.
%
%	For example:
%
%		a=newfis('tipper');
%		a=addvar(a,'input','service',[0 10]);
%		a=addmf(a,'input',1,'poor','gaussmf',[3 0]);
%		a=addmf(a,'input',1,'excellent','gaussmf',[3 10]);
%		a=addvar(a,'output','tip',[0 30]);
%		a=addmf(a,'output',1,'cheap','trimf',[0 5 10]);
%		a=addmf(a,'output',1,'generous','trimf',[20 25 30]);
%		ruleList=[1 1 1 2; 2 2 1 2];
%		a=addrule(a,ruleList);
%		gensurf(a,1,1,50)
%
%	See also SURFVIEW, EVALFIS.

%	Ned Gulley, 9-15-94
%	Copyright (c) 1994-95 by The MathWorks, Inc.
%	$Revision: 1.7 $  $Date: 1995/02/17 13:08:10 $

% Error checking
numInputs=getfis(fis,'numInputs');
numOutputs=getfis(fis,'numOutputs');

if numInputs<1, error('System has no inputs.'); end
if numOutputs<1, error('System has no outputs.'); end
if nargin<1, error('No system specified'); end

if nargin<2,
    if numInputs>1,
	inputs=[1 2];
    else
	inputs=1;
    end
end

if nargin<3, output=1; end;
if nargin<4, grids=15; end;

% If no reference input has been provided, let the reference input equal the
% middle of each input variable's range
inRange=getfis(fis,'inRange');
if nargin<5,
    refInput=mean(inRange');
end

if length(inputs)>2,
    error('No more than two input.');
elseif length(inputs)==1,
    xIndex=inputs(1); yIndex=[];
else
    xIndex=inputs(1); yIndex=inputs(2);
end
if length(output)>1,
    error('No more than one output.');
end
zIndex=output;

if length(grids)>2,
    error('No more than two grid values.');
elseif length(grids)==1,
    xGrids=grids(1); yGrids=xGrids;
else
    xGrids=grids(1); yGrids=grids(2);
end

% if yIndex is empty then xzFlag is true
if isempty(yIndex),
    xzFlag=1;
else
    xzFlag=0;
end

% Prepare the input

if xzFlag,
    x=linspace(inRange(xIndex,1),inRange(xIndex,2),xGrids)';
    u=refInput(ones(prod(size(x)),1),:);
    u(:,xIndex)=x(:);
else
    xRange=linspace(inRange(xIndex,1),inRange(xIndex,2),xGrids);
    yRange=linspace(inRange(yIndex,1),inRange(yIndex,2),yGrids);
    [x,y]=meshgrid(xRange,yRange);

    u=refInput(ones(prod(size(x)),1),:);
    u(:,xIndex)=x(:);
    u(:,yIndex)=y(:);
end

% Evaluate the input
v=evalfis(u,fis);

% Prepare the output
v=v(:,zIndex);
z=reshape(v,size(x,1),size(x,2));

% If no output is specified, plot the results
if nargout>1,
    xOut=x; yOut=y; zOut=z;
else
    inLabels=getfis(fis,'inLabels');
    outLabels=getfis(fis,'outLabels');
    if xzFlag,
     	plot(x,z);
    	xlabel(deblank(inLabels(xIndex,:)));
    	ylabel(deblank(outLabels(zIndex,:)));
    else
    	surf(x,y,z);
    	xlabel(deblank(inLabels(xIndex,:)));
    	ylabel(deblank(inLabels(yIndex,:)));
    	zlabel(deblank(outLabels(zIndex,:)));
	xMin=min(min(x)); xMax=max(max(x));
	yMin=min(min(y)); yMax=max(max(y));
	zMin=min(min(z)); zMax=max(max(z));
	if zMin==zMax, zMin=-inf; zMax=inf; end;
	axis([xMin xMax yMin yMax zMin zMax])
    end
end
