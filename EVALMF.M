function y=evalmf(x,params,type)
%EVALMF	Evaluate membership function.
%	Y=EVALMF(X, PARAMS, TYPE)
%	X is the input vector, PARAMS is the parameters
%	vector, and TYPE is either a string or a number
%	representing the type of membership function being
%	used ('trapmf', 'trimf', 'gaussmf', etc.)
%
%	For example:
%
%		x = (0:0.2:10)';
%		y1 = evalmf(x, [-1 2 3 4], 'pimf');
%		y2 = evalmf(x, [3 4 5 7], 'trapmf');
%		y3 = evalmf(x, [5 7 8], 'trimf');
%		y4 = evalmf(x, [2 9], 'sigmf');
%		plot(x, [y1 y2 y3 y4])
%		title('evalmf')
%
%	See also DSIGMF, GAUSS2MF, GAUSSMF, GBELLMF, PIMF, PSIGMF,
%	SIGMF, SMF, TRAPMF, TRIMF, and ZMF.

%	Copyright (c) 1994-95 by The MathWorks, Inc.
%	$Revision: 1.11 $  $Date: 1995/02/17 13:08:10 $
  
if (type == 1) | (strcmp(type,'trimf')),
    y = trimf(x, params);
    return;
elseif (type == 2) | (strcmp(type,'trapmf')),
    y = trapmf(x, params);
    return;
elseif (type == 3) | (strcmp(type,'gaussmf')),
    y = gaussmf(x, params);
    return;
elseif (type == 4) | (strcmp(type,'gauss2mf')),
    y = gauss2mf(x, params);
    return;
elseif (type == 5) | (strcmp(type,'sigmf')),
    y = sigmf(x, params);
    return;
elseif (type == 6) | (strcmp(type,'dsigmf')),
    y = dsigmf(x, params);
    return;
elseif (type == 7) | (strcmp(type,'psigmf')),
    y = psigmf(x, params);
    return;
elseif (type == 8) | (strcmp(type,'gbellmf')),
    y = gbellmf(x, params);
    return;
elseif (type == 9) | (strcmp(type,'smf')),
    y = smf(x, params);
    return;
elseif (type == 10) | (strcmp(type,'zmf')),
    y = zmf(x, params);
    return;
elseif (type == 11) | (strcmp(type,'pimf')),
    y = pimf(x, params);
    return;
else
    % Membership function is unknown
    % We assume it is user-defined and evaluate it here
    evalStr=[type '(x, params)'];
    y = eval(evalStr);
    return;
end
