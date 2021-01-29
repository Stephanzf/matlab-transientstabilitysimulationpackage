function [ret,x0,str,ts,xts]=fuzblock(t,x,u,flag);
%FUZBLOCK	is the M-file description of the SIMULINK system named FUZBLOCK.
%	The block-diagram can be displayed by typing: FUZBLOCK.
%
%	SYS=FUZBLOCK(T,X,U,FLAG) returns depending on FLAG certain
%	system values given time point, T, current state vector, X,
%	and input vector, U.
%	FLAG is used to indicate the type of output to be returned in SYS.
%
%	Setting FLAG=1 causes FUZBLOCK to return state derivatives, FLAG=2
%	discrete states, FLAG=3 system outputs and FLAG=4 next sample
%	time. For more information and other options see SFUNC.
%
%	Calling FUZBLOCK with a FLAG of zero:
%	[SIZES]=FUZBLOCK([],[],[],0),  returns a vector, SIZES, which
%	contains the sizes of the state vector and other parameters.
%		SIZES(1) number of states
%		SIZES(2) number of discrete states
%		SIZES(3) number of outputs
%		SIZES(4) number of inputs
%		SIZES(5) number of roots (currently unsupported)
%		SIZES(6) direct feedthrough flag
%		SIZES(7) number of sample times
%
%	For the definition of other parameters in SIZES, see SFUNC.
%	See also, TRIM, LINMOD, LINSIM, EULER, RK23, RK45, ADAMS, GEAR.

% Note: This M-file is only used for saving graphical information;
%       after the model is loaded into memory an internal model
%       representation is used.

% the system will take on the name of this mfile:
sys = mfilename;
new_system(sys)
simver(1.3)
if (0 == (nargin + nargout))
     set_param(sys,'Location',[597,296,865,479])
     open_system(sys)
end;
set_param(sys,'algorithm',     'RK-45')
set_param(sys,'Start time',    '0')
set_param(sys,'Stop time',     '10000')
set_param(sys,'Min step size', '0.0001')
set_param(sys,'Max step size', '0.1')
set_param(sys,'Relative error','1e-3')
set_param(sys,'Return vars',   '')

add_block('built-in/S-Function',[sys,'/','Fuzzy Logic Controller'])
set_param([sys,'/','Fuzzy Logic Controller'],...
		'function name','sffis',...
		'parameters','fismatrix',...
		'Mask Display','plot(0, -0.3, 6, -0.3, 0, 1.2, 6, 1.2, [0 6], [0 0], [1 2 3],[0 1 0],[2 3 4],[0 1 0],[3 4 5],[0 1 0])')
set_param([sys,'/','Fuzzy Logic Controller'],...
		'Mask Type','FIS',...
		'Mask Dialogue','FIS|FIS Matrix:',...
		'Mask Translate','fismatrix = @1;',...
		'Mask Help','Fuzzy Inference System',...
		'Mask Entries','fismat\/')
set_param([sys,'/','Fuzzy Logic Controller'],...
		'position',[105,49,160,101])

drawnow

% Return any arguments.
if (nargin | nargout)
	% Must use feval here to access system in memory
	if (nargin > 3)
		if (flag == 0)
			eval(['[ret,x0,str,ts,xts]=',sys,'(t,x,u,flag);'])
		else
			eval(['ret =', sys,'(t,x,u,flag);'])
		end
	else
		[ret,x0,str,ts,xts] = feval(sys);
	end
else
	drawnow % Flash up the model and execute load callback
end
