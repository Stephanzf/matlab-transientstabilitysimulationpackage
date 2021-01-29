function out = defuzz(x, mf, type)
% DEFUZZ Defuzzification of a membership function (MF).
%	DEFUZZ(X, MF, TYPE) returns a defuzzified value of MF positioned
%	at X, using different defuzzification strategies:
%
%	TYPE = 'centroid' --> centroid of area
%	TYPE = 'bisector' --> bisector of area
%	TYPE = 'mom'      --> mean of maximum
%	TYPE = 'som'      --> smallest of maximum
%	TYPE = 'lom'      --> largest of maximum
%
%	If TYPE is not one of the above, it is taken as a user-defined
%	function. X and MF are passed to this function to generate the
%	defuzzified output.
%
%	For example:
%
%		x = -10:0.1:10;
%		mf = trapmf(x, [-10, -8, -4, 7]);
%		type = 'centroid';
%		figure('name', 'defuzz', 'numbertitle', 'off');
%		plot(x, mf);
%		axis([min(x) max(x) 0 1.2]);
%		hold on
%		xx =  defuzz(x, mf, type);
%		plot([xx xx], [0 1.2], 'r-'); plot(xx, 0.0, 'c*');
%		text(xx, 0.1, type, 'hor', 'center', 'ver', 'top');
%		hold off
%
%	Try DEFUZZDM for more examples.

%	Roger Jang, 6-28-93 ,10-5-93, 9-29-94.
%       Copyright (c) 1994-95  by The MathWorks, Inc.
%       $Revision: 1.4 $  $Date: 1995/02/17 13:08:10 $

x = x(:);
mf = mf(:);
if length(x) ~= length(mf),
	error('Sizes mismatch!');
end
data_n = length(x);
 
if strcmp(type, 'centroid'),
	total_area = sum(mf);
	if total_area == 0,
		error('Total area is zero in centroid defuzzification!');
	end
	out = sum(mf.*x)/total_area;
	return;
elseif strcmp(type, 'bisector'),
        total_area = sum(mf);
	if total_area == 0,
		error('Total area is zero in bisector defuzzification!');
	end
        tmp = 0;
        for k=1:data_n,
                tmp = tmp + mf(k);
                if tmp >= total_area/2,
                        break;
                end
        end
	out = x(k);
	return;
elseif strcmp(type, 'mom'),
        out = mean(x(find(mf==max(mf))));
	return;
elseif strcmp(type, 'som'),
        tmp = x(find(mf == max(mf)));
        [junk, which] = min(abs(tmp));
	out = tmp(which); 
	return;
elseif strcmp(type, 'lom'),
        tmp = x(find(mf == max(mf)));
        [junk, which] = max(abs(tmp));
	out = tmp(which); 
	return;
else
	% defuzzification type is unknown
	% We assume it is user-defined and evaluate it here
	evalStr=[type '(x, mf)'];
	out = eval(evalStr);
	return;
end
