function [outParams,errorStr]=mf2mf(inParams,inType,outType)
%MF2MF Translate parameters between functions.
%	outParams=MF2MF(inParams,inType,outType) takes the original 
%	membership function parameters and type and returns parameters 
%	appropriate to the new membership function type. The result 
%	is very rough approximation of the general location and shape 
%	of the original.
%
%	For example:
%
%               x = (0:0.1:10)';
%		pOld = [1.5 5];
%               y1 = gaussmf(x,pOld);
%		pNew = mf2mf(pOld,'gaussmf','trimf');
%               y2 = trimf(x,pNew);
%		plot(x,y1,'y',x,y2,'c')
%               title('MF Conversion')
%
%       See also DSIGMF, GAUSSMF, GAUSS2MF, GBELLMF, EVALMF, PIMF,
%       PSIGMF, SIGMF, SMF, TRAPMF, TRIMF, and ZMF.

%	Ned Gulley, 6-17-94
%	Copyright (c) 1994-95 by The MathWorks, Inc.
%	$Revision: 1.12 $  $Date: 1995/02/17 13:08:10 $

yWaist=0.5;
yShoulder=0.90;

if strcmp(inType,'trimf'),
    lftWaist=yWaist*(inParams(2)-inParams(1))+inParams(1);
    lftShoulder=yShoulder*(inParams(2)-inParams(1))+inParams(1);
    rtShoulder=(1-yShoulder)*(inParams(3)-inParams(2))+inParams(2);
    rtWaist=(1-yWaist)*(inParams(3)-inParams(2))+inParams(2);

elseif strcmp(inType,'trapmf') | strcmp(inType,'pimf'),
    lftWaist=yWaist*(inParams(2)-inParams(1))+inParams(1);
    lftShoulder=yShoulder*(inParams(2)-inParams(1))+inParams(1);
    rtShoulder=(1-yShoulder)*(inParams(4)-inParams(3))+inParams(3);
    rtWaist=(1-yWaist)*(inParams(4)-inParams(3))+inParams(3);

elseif strcmp(inType,'gaussmf'),
    lftWaist=-abs(inParams(1))*sqrt(-2*log(yWaist))+inParams(2);
    lftShoulder=-abs(inParams(1))*sqrt(-2*log(yShoulder))+inParams(2);
    rtShoulder=2*inParams(2)-lftShoulder;
    rtWaist=2*inParams(2)-lftWaist;

elseif strcmp(inType,'gauss2mf'),
    lftWaist=-abs(inParams(1))*sqrt(-2*log(yWaist))+inParams(2);
    lftShoulder=inParams(2);
    rtShoulder=inParams(4);
    rtWaist=abs(inParams(3))*sqrt(-2*log(yWaist))+inParams(4);

elseif strcmp(inType,'gbellmf'),
    lftWaist=-inParams(1)*((1/yWaist-1)^(1/(2*inParams(2))))+inParams(3);
    lftShoulder=-inParams(1)*((1/yShoulder-1)^(1/(2*inParams(2))))+inParams(3);
    rtShoulder=2*inParams(3)-lftShoulder;
    rtWaist=2*inParams(3)-lftWaist;

elseif strcmp(inType,'sigmf'),
    if inParams(1)>0,
    	lftWaist=inParams(2);
    	lftShoulder=-1/inParams(1)*log(1/yShoulder-1)+inParams(2);
    	rtShoulder=2*lftShoulder-lftWaist;
    	rtWaist=2*rtShoulder-lftWaist;
    else
    	rtWaist=inParams(2);
    	rtShoulder=-1/inParams(1)*log(1/yShoulder-1)+inParams(2);
    	lftShoulder=rtShoulder;
    	lftWaist=2*lftShoulder-rtWaist;
    end

elseif strcmp(inType,'dsigmf'),
    lftWaist=inParams(2);
    lftShoulder=-1/inParams(1)*log(1/yShoulder-1)+inParams(2);
    rtWaist=inParams(4);
    rtShoulder=1/inParams(3)*log(1/yShoulder-1)+inParams(4);

elseif strcmp(inType,'psigmf'),
    lftWaist=inParams(2);
    lftShoulder=-1/inParams(1)*log(1/yShoulder-1)+inParams(2);
    rtWaist=inParams(4);
    rtShoulder=-1/inParams(3)*log(1/yShoulder-1)+inParams(4);

elseif strcmp(inType,'smf'),
    lftWaist=yWaist*(inParams(2)-inParams(1))+inParams(1);
    lftShoulder=yShoulder*(inParams(2)-inParams(1))+inParams(1);
    rtShoulder=inParams(2);
    if inParams(1)<inParams(2),
	lftWaist=inParams(1);
	rtWaist=2*inParams(2)-inParams(1);
    else
	lftWaist=2*inParams(2)-inParams(1);
	rtWaist=inParams(1);
    end

elseif strcmp(inType,'zmf'),
    lftShoulder=inParams(2);
    rtShoulder=inParams(2);
    if inParams(1)<inParams(2),
	lftWaist=inParams(1);
	rtWaist=2*inParams(2)-inParams(1);
    else
	lftWaist=2*inParams(2)-inParams(1);
	rtWaist=inParams(1);
    end
else
    % Input MF type is unknown
    outParams=[];
    errorStr=['Cannot translate from input MF type ' inType];
    if nargout<2, error(errorStr); end
    return
end

% We've translated into generalized coordinates, now translate back into
% MF specific parameters...

if strcmp(outType,'trimf'),
    center=(rtShoulder+lftShoulder)/2;
    % Assumes yWaist=0.5
    outParams=[2*lftWaist-center center 2*rtWaist-center];

elseif strcmp(outType,'trapmf')|strcmp(outType,'pimf'),
    % Assumes yWaist=0.5
    outParams=[2*lftWaist-lftShoulder lftShoulder rtShoulder 2*rtWaist-rtShoulder];

elseif strcmp(outType,'gbellmf'),
    center=(rtShoulder+lftShoulder)/2;
    a=center-lftWaist;
    b=2*a/(lftShoulder-lftWaist);
    outParams=[a b center];

elseif strcmp(outType,'gaussmf'),
    center=(rtShoulder+lftShoulder)/2;
    sigma=(rtWaist-center)/sqrt(-2*log(yWaist));
    outParams=[sigma center];

elseif strcmp(outType,'gauss2mf'),
    lftSigma=(lftShoulder-lftWaist)/sqrt(-2*log(yWaist));
    rtSigma=(rtWaist-rtShoulder)/sqrt(-2*log(yWaist));
    outParams=[lftSigma lftShoulder rtSigma rtShoulder];

elseif strcmp(outType,'sigmf'),
    center=lftWaist;
    a=-1/(lftShoulder-center)*log(1/yShoulder-1);
    outParams=[a center];

elseif strcmp(outType,'dsigmf'),
    lftCenter=lftWaist;
    lftA=-1/(lftShoulder-lftCenter)*log(1/yShoulder-1);
    rtCenter=rtWaist;
    rtA=1/(rtShoulder-rtCenter)*log(1/yShoulder-1);
    outParams=[lftA lftCenter rtA rtCenter];

elseif strcmp(outType,'psigmf'),
    lftCenter=lftWaist;
    lftA=-1/(lftShoulder-lftCenter)*log(1/yShoulder-1);
    rtCenter=rtWaist;
    rtA=-1/(rtShoulder-rtCenter)*log(1/yShoulder-1);
    outParams=[lftA lftCenter rtA rtCenter];
%keyboard

elseif strcmp(outType,'smf'),
    % Assumes yWaist=0.5
    outParams=[2*lftWaist-lftShoulder lftShoulder];

elseif strcmp(outType,'zmf'),
    % Assumes yWaist=0.5
    outParams=[rtShoulder 2*rtWaist-rtShoulder];

%elseif strcmp(outType,'psigmf'),
%    lftCenter=(lftWaist+lftShoulder)/2;
%    lftA=abs(-1/(lftWaist-lftCenter)*log(1/yWaist-1));
%    rtCenter=(rtWaist+rtShoulder)/2;
%    rtA=-abs(-1/(rtWaist-rtCenter)*log(1/yWaist-1));
%    outParams=[lftA lftCenter rtA rtCenter];

else
    % Output MF type is unknown
    outParams=[];
    errorStr=['Cannot translate to output MF type ' outType];
    if nargout<2, error(errorStr); end
    return
end

outParams=eval(fmat2str(outParams,4));
