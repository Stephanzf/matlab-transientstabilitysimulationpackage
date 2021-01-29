function fismat = genfis2(Xin,Xout,radii,xBounds,options)
%GENFIS2 Generate FIS matrix using subtractive clustering.
%	This function extracts a set of rules that models a given data set.
%	The rule extraction method first uses SUBCLUST to determine the number
%	of rules and antecedent membership functions and then uses linear least
%	squares estimation to determine each rule's consequent equations.
%
%	GENFIS2(XIN,XOUT,RADII,XBOUNDS,OPTIONS) returns a FIS matrix that
%	contains the resultant fuzzy inference system.  XIN is a matrix in
%	which each row contains the input values of a data point.  XOUT is a
%	matrix in which each row contains the output values of a data point.
%	RADII is a vector that specifies a cluster center's range of influence
%	in each of the data dimensions, assuming the data falls within a unit
%	hyperbox.  For example, if the data dimension is 3 (e.g., XIN has 2
%	columns and XOUT has 1 column), RADII = [0.5 0.4 0.3] specifies that
%	the ranges of influence in the first, second, and third data dimensions
%	(i.e., the first column of XIN, the second column of XIN, and the column
%	of XOUT) are 0.5, 0.4, and 0.3 times the width of the data space,
%	respectively.  If RADII is a scalar, then the scalar value is applied
%	to all data dimensions, i.e., each cluster center will have a spherical
%	neighborhood of influence with the given radius.  XBOUNDS is a 2xN
%	matrix that specifies how to map the data in XIN and XOUT into a unit
%	hyperbox, where N is the data dimension.  The first row contains the
%	minimum axis range values and the second row contains the maximum axis
%	range values for scaling the data in each dimension.  For example,
%	XBOUNDS = [-10 0 -1; 10 50 1] specifies that data values in the first
%	data dimension are to be scaled from the range [-10 +10] into values in
%	the range [0 1]; data values in the second data dimension are to be
%	scaled from the range [0 50]; and data values in the third data
%	dimension are to be scaled from the range [-1 +1].  If XBOUNDS is an
%	empty matrix or not provided, then XBOUNDS defaults to the minimum and
%	maxium data values found in each data dimension. OPTIONS is an optional
%	vector for specifying algorithm parameters to override the default
%	values.  These parameters are explained in the help text of SUBCLUST.
%
%	Examples:
%
%	FISMAT = GENFIS2(XIN,XOUT,0.5)
%	This is the minimum number of argument needed to use this function.
%	Here a range of influence of 0.5 is specified for all data dimensions.
%
%	FISMAT = GENFIS2(XIN,XOUT,[0.5 0.25 0.3])
%	This assumes the combined data dimension is 3.  Suppose XIN has 2
%	columns and XOUT has 1 column, then 0.5 and 0.25 are the ranges of
%	influence for each of the XIN data dimensions, and 0.3 is the range of
%	influence for the XOUT data dimension.
%
%	FISMAT = GENFIS2(XIN,XOUT,0.5,[-10 -5 0; 10 5 20])
%	This specifies how to normalize the data in XIN and XOUT into values
%	in the range [0 1] for processing.  Suppose XIN has 2 columns and XOUT
%	has 1 column, then the data in the first column of XIN are scaled from
%	[-10 +10], the data in the second column of XIN are scaled from [-5 +5],
%	and the data in XOUT are scaled from [0 20].
%
%	A full description of the rule extraction algorithm can be found in: 
%	S. Chiu, "Fuzzy Model Identification Based on Cluster Estimation," J. of
%	Intelligent & Fuzzy Systems, Vol. 2, No. 3, 1994.
%
%	See also SUBCLUST, GENFIS1 and ANFIS.

%       Steve Chiu, 1-25-95
%       Copyright (c) 1994-95  by The MathWorks, Inc.
%       $Revision: 1.5 $  $Date: 1995/02/17 13:08:10 $

[numData,numInp] = size(Xin);
[numData2,numOutp] = size(Xout);

if numData ~= numData2
	% There's a mismatch in the input and output data matrix dimensions
	if numData == numOutp
		% The output data matrix should have been transposed, we'll fix it
		Xout = Xout';
		numOutp = numData2;
	else
		error('Mismatched input and output data matrices');
	end
end

if nargin < 5
	verbose = 0;
	if nargin < 4
		xBounds = [];
	end
	[centers,sigmas] = subclust([Xin Xout],radii,xBounds);
else
	verbose = options(4);
	[centers,sigmas] = subclust([Xin Xout],radii,xBounds,options);
end


if verbose
	disp('Setting up matrix for linear least squares estimation...');
end

% Discard the clusters' output dimensions
centers = centers(:,1:numInp);
sigmas = sigmas(:,1:numInp);

% Distance multipliers
distMultp = (1.0 / sqrt(2.0)) ./ sigmas;

[numRule,foo] = size(centers);
sumMu = zeros(numData,1);
muVals = zeros(numData,1);
dxMatrix = zeros(numData,numInp);
muMatrix = zeros(numData,numRule * (numInp + 1));

for i=1:numRule

	for j=1:numInp
		dxMatrix(:,j) = (Xin(:,j) - centers(i,j)) * distMultp(j);
	end

	dxMatrix = dxMatrix .* dxMatrix;
	if numInp > 1
		muVals(:) = exp(-1 * sum(dxMatrix'));
	else
		muVals(:) = exp(-1 * dxMatrix');
	end

	sumMu = sumMu + muVals;

	colNum = (i - 1)*(numInp + 1);
	for j=1:numInp
		muMatrix(:,colNum + j) = Xin(:,j) .* muVals;
	end

	muMatrix(:,colNum + numInp + 1) = muVals;

end % endfor i=1:numRule

sumMuInv = 1.0 ./ sumMu;
for j=1:(numRule * (numInp + 1))
	muMatrix(:,j) = muMatrix(:,j) .* sumMuInv;
end

if verbose
	disp('Solving linear least squares estimation problem...');
end

% Compute the TSK equation parameters
outEqns = muMatrix \ Xout;

% Each column of outEqns now contains the output equation parameters
% for an output variable.  For example, if output variable y1 is given by
% the equation y1 = k1*x1 + k2*x2 + k3*x3 + k0, then column 1 of
% outEqns contains [k1 k2 k3 k0] for rule #1, followed by [k1 k2 k3 k0]
% for rule #2, etc.

if verbose
	disp('Creating FIS matrix...');
end

% Find out the number of digits required for printing out the input,
% output, and rule numbers
numInDigit = floor(log10(numInp)) + 1;
numOutDigit = floor(log10(numOutp)) + 1;
numRuleDigit = floor(log10(numRule)) + 1;

% Find out the required size of the FIS matrix
numRow = 11 + (2 * (numInp + numOutp)) + (3 * (numInp + numOutp) * numRule);
numCol = numInp + numOutp + 2;		% number of columns required for the rule list	
strSize = 3 + numInDigit + numOutDigit; % size of name 'sug[numInp][numOutp]'
numCol = max(numCol,strSize);
strSize = 4 + numInDigit + numRuleDigit;	% size of 'in[numInp]mf[numRule]'
numCol = max(numCol,strSize);
strSize = 5 + numOutDigit + numRuleDigit;	% size of 'out[numOutp]fm[numRule]'
numCol = max(numCol,strSize);
numCol = max(numCol,7);	% size of 'gaussmf' is 7

% Create a FIS matrix that initially contains all zeros
fismat = zeros(numRow,numCol);

% Set the FIS name as 'sug[numInp][numOutp]'
theStr = sprintf('sug%g%g',numInp,numOutp);
fismat(1,1:(3 + numInDigit + numOutDigit)) = abs(theStr);
% FIS type
fismat(2,1:6) = abs('sugeno');
% Number of inputs and outputs
fismat(3,1:2) = [numInp numOutp];
% Number of input membership functions
fismat(4,1:numInp) = numRule * ones(1,numInp);
% Number of output membership functions
fismat(5,1:numOutp) = numRule * ones(1,numOutp);
% Number of rules
fismat(6,1) = numRule;
% Inference operators for and, or, imp, agg, and defuzz
fismat(7,1:4) = abs('prod');
fismat(8,1:6) = abs('probor');
fismat(9,1:3) = abs('min');
fismat(10,1:3) = abs('max');
fismat(11,1:6) = abs('wtaver');

rowIndex = 11;
% Set the input variable labels
for i=1:numInp
	rowIndex = rowIndex + 1;
	theStr = sprintf('in%g',i);
	strSize = length(theStr);
	fismat(rowIndex,1:strSize) = abs(theStr);
end

% Set the output variable labels
for i=1:numOutp
	rowIndex = rowIndex + 1;
	theStr = sprintf('out%g',i);
	strSize = length(theStr);
	fismat(rowIndex,1:strSize) = abs(theStr);
end

% Set the input variable ranges
if length(xBounds) == 0
	% No data scaling range values were specified, use the actual minimum and
	% maximum values of the data.
	minX = min(Xin);
	maxX = max(Xin);
else
	minX = xBounds(1,1:numInp);
	maxX = xBounds(2,1:numInp);
end


ranges = [minX ; maxX]';
fismat((rowIndex + 1):(rowIndex + numInp),1:2) = ranges;
rowIndex = rowIndex + numInp;

% Set the output variable ranges to the dummy values [-5 +5]
fismat((rowIndex + 1):(rowIndex + numOutp),1) = -5 * ones(numOutp,1);
fismat((rowIndex + 1):(rowIndex + numOutp),2) = 5 * ones(numOutp,1);
rowIndex = rowIndex + numOutp;

% Set the input membership function labels
for i=1:numInp
	for j=1:numRule
		rowIndex = rowIndex + 1;
		theStr = sprintf('in%gmf%g',i,j);
		strSize = length(theStr);
		fismat(rowIndex,1:strSize) = abs(theStr);
	end
end

% Set the output membership function labels
for i=1:numOutp
	for j=1:numRule
		rowIndex = rowIndex + 1;
		theStr = sprintf('out%gmf%g',i,j);
		strSize = length(theStr);
		fismat(rowIndex,1:strSize) = abs(theStr);
	end
end

% Set the input membership function types
for i=1:(numInp * numRule)
	rowIndex = rowIndex + 1;
	fismat(rowIndex,1:7) = abs('gaussmf');
end

% Set the output membership function types
for i=1:(numOutp * numRule)
	rowIndex = rowIndex + 1;
	fismat(rowIndex,1:6) = abs('linear');
end

% Set the input membership function parameters
colOfOnes = ones(numRule,1);	% a column of ones
for i=1:numInp
	fismat(rowIndex + 1:rowIndex + numRule,1) = sigmas(i) * colOfOnes;
	fismat(rowIndex + 1:rowIndex + numRule,2) = centers(:,i);
	rowIndex = rowIndex + numRule;
end

% Set the output membership function parameters
for i=1:numOutp
	outParams = reshape(outEqns(:,i),numInp + 1,numRule);
	fismat(rowIndex + 1:rowIndex + numRule,1:numInp + 1) = outParams';
	rowIndex = rowIndex + numRule;
end

% Set the membership function pointers in the rule list
colOfEnum = [1:numRule]';
for i=1:(numInp + numOutp)
	fismat(rowIndex + 1:rowIndex + numRule,i) = colOfEnum;
end

% Set the antecedent operators and rule weights in the rule list
fismat(rowIndex + 1:rowIndex + numRule,numInp + numOutp + 1) = colOfOnes;
fismat(rowIndex + 1:rowIndex + numRule,numInp + numOutp + 2) = colOfOnes;
