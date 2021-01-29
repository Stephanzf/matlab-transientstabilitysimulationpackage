function y = dsigmf(x, params)
%DSIGMF Difference of two sigmoid membership functions.
%       DSIGMF(X, PARAMs) returns a matrix Y which is the absolute difference
%	of two sigmoid functions evaluated at X. PARAMS is a 4-element vector
%	that determines the shape and position of this membership function.
%	Specifically, X and PARAMS are passed to SIGMF as follows:
%
%	DSIGMF(X, PARAMS) = ABS(SIGMF(X, PARAMS(1:2)-SIGMF(X, PARAMS(3:4))));
%	
%	For example:
%
%		x = (0:0.2:10)';
%		params1 = [5 2];
%		y1 = sigmf(x, params1);
%		params2 = [2 7];
%		y2 = sigmf(x, params2);
%		y3 = dsigmf(x, [params1 params2]);
%		subplot(211);
%		plot(x, y1, x, y2); title('sigmf');
%		subplot(212);
%		plot(x, y3, 'g-', x, y3, 'o'); title('dsigmf');
%		set(gcf, 'name', 'dsigmf', 'numbertitle', 'off');
%
%	See also GAUSS2MF, GAUSSMF, GBELLMF, EVALMF, PIMF, PSIGMF, SIGMF,
%	SMF, TRAPM, TRIMF, and ZMF.

%       Roger Jang, 10-5-93.
%       Copyright (c) 1994-95  by The MathWorks, Inc.
%       $Revision: 1.10 $  $Date: 1995/02/17 13:08:10 $

if nargin ~= 2
	error('Two arguments are required by diff. sigmoidal MF.');
elseif length(params) < 4
	error('The diff. sigmoidal MF needs at least four parameters.');
end

y = abs(sigmf(x, params(1:2)) - sigmf(x, params(3:4)));
