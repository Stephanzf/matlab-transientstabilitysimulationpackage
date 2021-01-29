function string = fmat2str(matrix,n)
%FMAT2STR Converts a matrix to a string using full precision.
%	STR = FMAT2STR(MAT) converts the matrix MAT to a MATLAB
%	string using full precision. 
%
%	STR = FMAT2STR(MAT,N) converts using n digits of precision. 

%	Copyright (c) 1994-95 by The MathWorks, Inc.
%	$Revision: 1.13 $  $Date: 1995/02/17 13:08:10 $
%	This function based on MAT2STR
%	D. Packer 7-10-90
%	Revised, A. Grace, 10-29-90
%       Revised, A. Potvin  9-21-92, 6-22-94

if isstr(matrix),
   string = matrix;
   return
end
if nargin<2,
   form = '%.15g';
else
   form = ['%.' int2str(n) 'g'];
end

[rows, cols] = size(matrix);
if rows*cols ~= 1
	string = '[';
else
	string = '';
end
for i = 1:rows
	for j = 1:cols
		if(matrix(i,j) == Inf)
		    string = [string,'Inf'];
		elseif (matrix(i,j) == -Inf)
		    string = [string,'-Inf'];
		else
		    string = [string,sprintf(form,real(matrix(i,j)))];
		    if(imag(matrix(i,j)) < 0)
		        string = [string,'-i*',sprintf(form,abs(imag(matrix(i,j))))];
		    elseif(imag(matrix(i,j)) > 0)
		        string = [string,'+i*',sprintf(form,imag(matrix(i,j)))];
		    end
		end
		string = [string ' '];
	end
        l = length(string);
	string(l:l+1) = '; ';
end
if rows==0,
	string = [string '  '];
end
l = length(string);
if rows * cols ~= 1
	string(l-1)  = ']';
        string(l) = [];
else
	string(l-1:l)  = [];
end
if(length(string)>255)
        disp('Warning string more than 255 characters long');
end

% end fmat2str
