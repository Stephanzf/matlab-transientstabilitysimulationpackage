function [outParams,errorStr]=strtchmf(inParams,inRange,outRange,inType)
%STRTCHMF Stretch membership functions.
%	outParams=STRTCHMF(inParams,inRange,outRange,inType) takes the 
%	original membership function parameters and range and returns 
%	parameters appropriate to the new membership function range. 
%
%	For example:
%
%		ri = [0 10]; ro = [-5 30];
%               xi = linspace(ri(1),ri(2));
%               xo = linspace(ro(1),ro(2));
%		pi = [0 5 8];
%		po = strtchmf(pi,ri,ro,'trimf');
%               yi = trimf(xi,pi);
%               yo = trimf(xo,po);
%		subplot(2,1,1), plot(xi,yi,'y');
%		subplot(2,1,2), plot(xo,yo,'c');
%               title('MF Stretching')
%
%	See also DSIGMF, GAUSSMF, GAUSS2MF, GBELLMF, EVALMF, PIMF, PSIGMF,
%	SIGMF, SMF, TRAPMF, TRIMF, and ZMF.

%	Ned Gulley, 10-17-94
%	Copyright (c) 1994-95 by The MathWorks, Inc.
%	$Revision: 1.5 $  $Date: 1995/02/17 13:08:10 $

diffInRange=diff(inRange);
diffOutRange=diff(outRange);
outParams=inParams;

if strcmp(inType,'trimf') | strcmp(inType,'trapmf') | strcmp(inType,'pimf') | ...
    strcmp(inType,'smf') | strcmp(inType,'smf'),
    outParams=(inParams-inRange(1))/diffInRange*diffOutRange+outRange(1);

elseif strcmp(inType,'gbellmf'),
    outParams(1)=inParams(1)/diffInRange*diffOutRange;
    outParams(2)=inParams(2);
    outParams(3)=(inParams(3)-inRange(1))/diffInRange*diffOutRange+outRange(1);

elseif strcmp(inType,'gaussmf'),
    outParams(1)=inParams(1)/diffInRange*diffOutRange;
    outParams(2)=(inParams(2)-inRange(1))/diffInRange*diffOutRange+outRange(1);

elseif strcmp(inType,'gauss2mf'),
    outParams([1 3])=inParams([1 3])/diffInRange*diffOutRange;
    outParams([2 4])=(inParams([2 4])-inRange(1))/diffInRange*diffOutRange+outRange(1);

elseif strcmp(inType,'sigmf'),
    outParams(1)=inParams(1)*diffInRange/diffOutRange;
    outParams(2)=(inParams(2)-inRange(1))/diffInRange*diffOutRange+outRange(1);

elseif strcmp(inType,'dsigmf') | strcmp(inType,'psigmf'),
    outParams([1 3])=inParams([1 3])*diffInRange/diffOutRange;
    outParams([2 4])=(inParams([2 4])-inRange(1))/diffInRange*diffOutRange+outRange(1);

else
    % Output MF type is unknown
    outParams=[];
    errorStr=['Cannot stretch MF type ' inType];
    if nargout<2, error(errorStr); end
    return
end

outParams=eval(fmat2str(outParams,4));


