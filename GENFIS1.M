function fismatrix = genfis1(data, mf_n, in_mf_type)
% GENFIS1 Generate FIS matrix using generic method.
%	GENFIS1(DATA, MF_N, IN_MF_TYPE) generates a fismatrix from training
%	data DATA, using grid partition style. MF_N is a vector specifying
%	the number of membership functions on all inputs. IN_MF_TYPE is a
%	string array where each row specifies the MF type of an input variable.
%	If MF_N is a number and/or IN_MF_TYPE is a single string, they will be
%	used for all inputs. Note that MF_N and IN_MF_TYPE are pass directly to
%	GENPARAM for generating input MF parameters.
%	
%	Default number of membership function MF_N is 2; default
%	input membership function type is 'gbellmf'.
%
%	For example:
%
%	NumData = 1000;
%	data = [rand(NumData,1) 10*rand(NumData,1)-5 rand(NumData,1)];
%	NumMf = [3 7];
%	MfType = str2mat('pimf', 'trimf');
%	FisMatrix = genfis1(data, NumMf, MfType);
%	figure('name', 'genfis1', 'numbertitle', 'off');
%	NumInput = size(data, 2) - 1;
%	for i = 1:NumInput;
%		subplot(NumInput, 1, i);
%		plotmf(FisMatrix, 'input', i);
%		xlabel(['input ' num2str(i) ' (' MfType(i, :) ')']);
%	end
%		
%	See also GENPARAM, ANFIS.

%       Roger Jang, 8-7-94
%       Copyright (c) 1994-95  by The MathWorks, Inc.
%       $Revision: 1.9 $  $Date: 1995/02/17 13:08:10 $

% Change this to have different default values
default_mf_n = 2;
default_mf_type = 'gbellmf';

if nargin <= 2,
	in_mf_type = default_mf_type;
end
if nargin <= 1,
	mf_n = default_mf_n;
end

% get dimension info
data_n = size(data, 1);
in_n = size(data, 2) - 1;

% generate mf_n and in_mf_type of proper sizes
mf_n = mf_n(:)';	% row vector
if length(mf_n) == 1,
	mf_n = mf_n(:, ones(in_n, 1));
end
if size(in_mf_type, 1) == 1,
	in_mf_type = in_mf_type(ones(in_n, 1), :);
end

% error checking
if length(mf_n) ~= in_n | size(in_mf_type, 1) ~= in_n,
	error('Wrong sizes of given argument(s)!');
end

rule_n = prod(mf_n);

fismatrix = [];
fismatrix = combine(fismatrix, 'anfis');
fismatrix = combine(fismatrix, 'sugeno');
fismatrix = combine(fismatrix, [in_n 1]);
fismatrix = combine(fismatrix, mf_n);
fismatrix = combine(fismatrix, rule_n);
fismatrix = combine(fismatrix, rule_n);
fismatrix = combine(fismatrix, 'prod');
fismatrix = combine(fismatrix, 'max');
fismatrix = combine(fismatrix, 'prod');
fismatrix = combine(fismatrix, 'max');
fismatrix = combine(fismatrix, 'wtaver');

for i = 1:in_n,
	fismatrix = combine(fismatrix, ['input', num2str(i)]);
end
fismatrix = combine(fismatrix, 'output');	% single output only

range = [min(data)' max(data)'];
fismatrix = combine(fismatrix, range);

for i = 1:in_n,
	tmp1 = ['in', num2str(i)];
	tmp1 = tmp1(ones(mf_n(i), 1), :);
	tmp2 = 'mf';
	tmp2 = [tmp2(ones(mf_n(i), 1), :) (49:49+mf_n(i)-1)'];
	in_mf_label = [tmp1 tmp2];
	fismatrix = combine(fismatrix, in_mf_label);
end

for i = 1:rule_n,
	fismatrix = combine(fismatrix, ['out1mf', num2str(i)]);
end

for i = 1:in_n,
	tmp = in_mf_type(i, :);
	fismatrix = combine(fismatrix, tmp(ones(mf_n(i), 1), :));
end
tmp = 'linear';
out_mf_type = tmp(ones(rule_n, 1), :);
fismatrix = combine(fismatrix, out_mf_type);

in_mf_param = genparam(data, mf_n, in_mf_type);
fismatrix = combine(fismatrix, in_mf_param);
out_mf_param = zeros(rule_n, in_n+1);
fismatrix = combine(fismatrix, out_mf_param);

rule_list = zeros(rule_n, length(mf_n));
for i = 0:rule_n-1,
	tmp = i;
	for j = length(mf_n):-1:1,
		rule_list(i+1, j) = rem(tmp, mf_n(j))+1;
		tmp = fix(tmp/mf_n(j));
	end
end
rule_list = [rule_list (1:rule_n)' ones(rule_n, 1) ones(rule_n, 1)];
fismatrix = combine(fismatrix, rule_list);
