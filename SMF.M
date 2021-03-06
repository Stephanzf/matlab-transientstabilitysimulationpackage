function y = smf(x, params)
%SMF S-shaped curve membership function.
%	SMF(X, PARAMS) returns a matrix which is the S-shaped
%	membership function evaluated at X. PARAMS = [X0 X1] is a 2-element
%	vector that determines the break points of this membership function.
%	When X0 < X1, SMF is a smooth transition from 0 (at X0) to 1 (at X1).
%	When x0 >= x1, SMF becomes a step function which jumps from 0 to 1
%	at (X0+X1)/2.
%	
%	For example:
%
%		x = 0:0.1:10;
%		subplot(311); plot(x, smf(x, [2 8]));
%		subplot(312); plot(x, smf(x, [4 6]));
%		subplot(313); plot(x, smf(x, [6 4]));
%		set(gcf, 'name', 'smf', 'numbertitle', 'off');
%
%	See also DSIGMF, GAUSS2MF, GAUSSMF, GBELLMF, EVALMF, PIMF, PSIGMF,
%	SIGMF, TRAPMF, TRIMF, and ZMF.

%	Roger Jang, 10-5-93, 7-14-94.
%       Copyright (c) 1994-95  by The MathWorks, Inc.
%       $Revision: 1.12 $  $Date: 1995/02/17 13:08:10 $

if nargin ~= 2,
	error('Two arguments are required by SMF.');
elseif length(params) < 2,
	error('SMF needs at least two parameters.');
end

x0 = params(1); x1 = params(2);

if x0 >= x1,
	y = x >= (x0+x1)/2;
	return;
end

y = zeros(size(x));

index1 = find(x <= x0);
if index1 ~= [],
	y(index1) = zeros(size(index1));
end

index2 = find((x0 < x) & (x <= (x0+x1)/2));
if index2 ~= [],
	y(index2) = 2*((x(index2)-x0)/(x1-x0)).^2;
end

index3 = find(((x0+x1)/2 < x) & (x <= x1));
if index3 ~= [],
	y(index3) = 1-2*((x1-x(index3))/(x1-x0)).^2;
end

index4 = find(x1 <= x);
if index4 ~= [],
	y(index4) = ones(size(index4));
end
