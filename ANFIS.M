function [t_fismat, t_error, stepsize, c_fismat, c_error] ...
	= anfis(trn_data, in_fismat, t_opt, d_opt, chk_data)
%ANFIS	Training routine for Sugeno-type FIS (MEX only).
%	ANFIS applies the least-squares method and the back-propagation gradient
%	descent for identifying linear and nonlinear parameters, respectively,
%	in a Sugeno-type fuzzy inference systems.
%
%	FISMAT = ANFIS(TRN_DATA) attempts to fit a training data TRN_DATA
%	using a Sugeno FIS with 2^N rules, where N is the number of inputs.
%	(This is recommanded only when N is less than 7.) The final fuzzy
%	inference system is returned as a FIS matrix FISMAT. The format of
%	TRN_DATA is described below.
%
%	When a specific Sugeno fuzzy inference system is used for fitting,
%	we can call ANFIS with from 2 to 4 input arguments and it returns
%	from 1 to 3 output arguments:
%
%	[FISMAT, ERROR, STEPSIZE] = ANFIS(TRN_DATA, IN_FISMAT, T_OPT, D_OPT)
%
%	  TRN_DATA: training data matrix, where each row is a desired
%		input/output data pairs, with output at the last column.
%	  IN_FISMAT: input FIS matrix to specify the structure and initial
%		parameters for fitting. This can be generated from data
%		directly using the command GENFIS.
%	  T_OPT: training options. 
%		T_OPT(1): training epoch number (default: 10)
%		T_OPT(2): training error goal (default: 0)
%		T_OPT(3): initial step size (default: 0.01)
%		T_OPT(4): step size decrease rate (default: 0.9)
%		T_OPT(5): step size increase rate (default: 1.1)
%		If any element of T_OPT is NaN (not a number), then the default
%		value is used. Default values can be changed directly by
%		modifying this file. If T_OPT itself is missing, a null matrix,
%		or an NaN, then it will also take default value.
%		The training process stops when the designated epoch number is
%		reached or when the training goal is achieved.
%		The step size is decreased (by multiplying the decrease rate)
%		if the error measure undergoes two consecutive combinations
%		of increase and decrease; increased (by multiplying the
%		increase rate) if the error measure undergoes four consecutive
%		decreases.
%	  D_OPT: display options. 
%		D_OPT(1): display ANFIS information (default: 1)
%		D_OPT(2): display error measure (default: 1)
%		D_OPT(3): display step size (default: 1)
%		D_OPT(4): display final results (default: 1)
%		The parsing of D_OPT is the same as T_OPT.
%	  FISMAT: output FIS matrix, which is the FIS matrix corresponding to
%		the minimum training error.
%	  ERROR: array of root mean squared errors.
%	  STEPSIZE: array of step sizes.
%
%	If checking data is involved in the training process, then ANFIS
%	should be called with 5 input arguments and it returns from 1 to 5
%	output arguments:
%
%	[FISMAT1, T_ERROR, STEPSIZE, FISMAT2, C_ERROR] = ...
%		ANFIS(TRN_DATA, IN_FISMAT, T_OPT, D_OPT, CHK_DATA)
%
%	  TRN_DATA: training data matrix, see above.
%	  IN_FISMAT: input FIS matrix, see above.
%	  T_OPT: training options, see above.
%	  D_OPT: display options, see above.
%	  CHK_DATA: checking data matrix, with the same format as TRN_DATA.
%	  FISMAT1: output FIS matrix corresponding to the min. training error.
%	  T_ERROR: array of root mean squared training errors.
%	  STEPSIZE: array of step sizes.
%	  FISMAT1: output FIS matrix corresponding to the min. checking error.
%	  C_ERROR: array of root mean squared checking errors.
%
%	For example:
%
%	x = (0:0.2:10)';
%	y = sin(2*x)./exp(x/5) + randn(size(x))/30;
%	TrainData = [x y];
%	NumMfs = 5;
%	MfType = 'gbellmf';
%	NumEpochs = 20;
%	StepSize = 0.1;
%	InputFismat = genfis1(TrainData, NumMfs, MfType);
%	OutputFismat = anfis(TrainData, InputFismat, [NumEpochs nan StepSize]);
%	yy = evalfis(x, OutputFismat);
%	plot(x, y, 'o', x, yy, 'x', x, y, 'y', x, yy, 'm');
%	legend('Training Data', 'ANFIS Output');
%	
%	See also GENFIS1, ANFISMEX.

%       Roger Jang, 9-12-94.
%       Copyright (c) 1994-95  by The MathWorks, Inc.
%       $Revision: 1.10 $  $Date: 1995/02/17 13:08:10 $

if nargin > 5 & nargin < 1,
	error('Too many or too few input arguments!');
end

% Change the following to set default train options.
default_t_opt = [10;	% training epoch number
		0;	% training error goal
		0.01;	% initial step size
		0.9;	% step size decrease rate
		1.1];	% step size increase rate

% Change the following to set default display options.
default_d_opt = [1;	% display ANFIS information
		1;	% display error measure
		1;	% display step size
		1];	% display final result

% Change the following to set default MF type and numbers
default_mf_type = 'gbellmf';	% default MF type
default_mf_number = 2;

if nargin <= 4,
	chk_data = [];
end
if nargin <= 3,
	d_opt = default_d_opt;
end
if nargin <= 2,
	t_opt = default_t_opt;
end
if nargin <= 1,
	in_fismat = default_mf_number;
end

% If d_opt or t_opt are nan's or []'s, replace them with default settings
if t_opt == [],
	t_opt = default_t_opt;
elseif length(t_opt) == 1 & isnan(t_opt),
	t_opt = default_t_opt;
end
if d_opt == [],
	d_opt = default_d_opt;
elseif length(d_opt) == 1 & isnan(d_opt),
	d_opt = default_d_opt;
end

% If d_opt or t_opt is not fully specified, pad it with default values. 
if length(t_opt) < 5,
	tmp = default_t_opt;
	tmp(1:length(t_opt)) = t_opt;
	t_opt = tmp;
end
if length(d_opt) < 5,
	tmp = default_d_opt;
	tmp(1:length(d_opt)) = d_opt;
	d_opt = tmp;
end

% If entries of d_opt or t_opt are nan's, replace them with default settings
nan_index = find(isnan(d_opt)==1);
d_opt(nan_index) = default_d_opt(nan_index);
nan_index = find(isnan(t_opt)==1);
t_opt(nan_index) = default_t_opt(nan_index);

% Generate FIS matrix if necessary
% in_fismat is a single number or a vector 
if min(size(in_fismat, 1), size(in_fismat, 2)) == 1,
	in_fismat = genfis1(trn_data, in_fismat, default_mf_type);
end

% More input/output argument checking
if nargin <= 4 & nargout > 3,
	error('Too many output arguments!');
end
if length(t_opt) ~= 5,
	error('Wrong length of t_opt!');
end
if length(d_opt) ~= 4,
	error('Wrong length of d_opt!');
end

% Start the real thing!
if nargout == 0,
	anfismex(trn_data, in_fismat, t_opt, d_opt, chk_data);
elseif nargout == 1,
	[t_fismat] = ...
		anfismex(trn_data, in_fismat, t_opt, d_opt, chk_data);
elseif nargout == 2,
	[t_fismat, t_error] = ...
		anfismex(trn_data, in_fismat, t_opt, d_opt, chk_data);
elseif nargout == 3,
	[t_fismat, t_error, stepsize] = ...
		anfismex(trn_data, in_fismat, t_opt, d_opt, chk_data);
elseif nargout == 4,
	[t_fismat, t_error, stepsize, c_fismat] = ...
		anfismex(trn_data, in_fismat, t_opt, d_opt, chk_data);
elseif nargout == 5,
	[t_fismat, t_error, stepsize, c_fismat, c_error] = ...
		anfismex(trn_data, in_fismat, t_opt, d_opt, chk_data);
else
	error('Too many output arguments!');
end
