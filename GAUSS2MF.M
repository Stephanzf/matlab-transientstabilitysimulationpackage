function y = gauss2mf(x, params)
%GAUSS2MF Two-sided Gaussian curve membership function.
%	GAUSS2MF(X, PARAMS) returns a matrix which is the Gaussian-constructed
%	membership function evaluated at X. PARAMS = [S1 C1 S2 C2] is a
%	4-element parameter vector; S1 and C1 define the left shoulder of
%	the MF while S2 and C2 determine the right shoulder.
%	This MF has a height of unity if and only if C1 <= C2.
%
%	For example:
%
%		x = (0:0.1:10)';
%		y1 = gauss2mf(x, [2 4 1 8]);
%		y2 = gauss2mf(x, [2 5 1 7]);
%		y3 = gauss2mf(x, [2 6 1 6]);
%		y4 = gauss2mf(x, [2 7 1 5]);
%		y5 = gauss2mf(x, [2 8 1 4]);
%		plot(x, [y1 y2 y3 y4 y5]);
%		set(gcf, 'name', 'gauss2mf', 'numbertitle', 'off');
%
%	See also DSIGMF, GAUSSMF, GBELLMF, EVALMF, PIMF, PSIGMF, SIGMF, SMF,
%	TRAPMF, TRIMF, and ZMF.

%	Ned Gulley, 4-7-94, Roger Jang, 8-25-94
%       Copyright (c) 1994-95  by The MathWorks, Inc.
%       $Revision: 1.9 $  $Date: 1995/02/17 13:08:10 $

if nargin ~= 2
	error('Two arguments are required by GAUSS2MF.');
elseif length(params) < 2
	error('GAUSS2MF needs four parameters.');
end

sigma1 = params(1);
c1 = params(2);
sigma2 = params(3);
c2 = params(4);

if (sigma1==0) | (sigma2==0),
	error('The sigma value must be non-zero.');
end

c1Index=(x<=c1);
c2Index=(x>=c2);
y1 = exp(-(x-c1).^2/(2*sigma1^2)).*c1Index + 1-c1Index;
y2 = exp(-(x-c2).^2/(2*sigma2^2)).*c2Index + 1-c2Index;

y = y1.*y2;
