function out=addrule(fis,rule);
%ADDRULE Add rule to FIS.
%	fis2 = ADDRULE(fis1, ruleList) adds the rules given by the
%	variable ruleList to the fuzzy inference system called fis1.
%	
%	The variable ruleList can be a list of one or more rows, each 
%	of which represents a given rule. The format that the rule list 
%	must take is very specific. If there are M inputs to a system and 
%	N outputs, there must be exactly M + N + 2 columns to the rule list.
%
%	The first M columns refer to the inputs of the system. Each column 
%	contains a number that refers to the index of the membership function 
%	for that variable.
%
%	The next N columns refer to the outputs of the system. Each column 
%	contains a number that refers to the index of the membership function 
%	for that variable.
%
%	The M + N + 1 column contains the weight that is to be applied to 
%	the rule. The weight must be a number between zero and one, and is 
%	generally left as one.
%
%	The M + N + 2 column contains a 1 if the fuzzy operator for the 
%	rule's antecedent is AND. It contains a 2 if the fuzzy operator is OR.
%
%	For example:
%
%		a=newfis('tipper');
%		a=addvar(a,'input','service',[0 10]);
%		a=addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%		a=addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%		a=addvar(a,'input','food',[0 10]);
%		a=addmf(a,'input',2,'rancid','trapmf',[-2 0 1 3]);
%		a=addmf(a,'input',2,'delicious','trapmf',[7 9 10 12]);
%		a=addvar(a,'output','tip',[0 30]);
%		a=addmf(a,'output',1,'cheap','trimf',[0 5 10]);
%		a=addmf(a,'output',1,'generous','trimf',[20 25 30]);
%		ruleList=[1 1 1 1 2; 2 2 2 1 2 ];
%		a=addrule(a,ruleList);
% 		showrule(a)
%
%	See also ADDMF, ADDVAR, PARSRULE, RMMF, RMVAR, and SHOWRULE.

%	Ned Gulley, 2-2-94
%	Copyright (c) 1994-95 by The MathWorks, Inc.
%	$Revision: 1.5 $  $Date: 1995/02/17 13:08:10 $

oldRuleList=getfis(fis,'ruleList');
newRuleList=[oldRuleList; rule];

fis=setfis(fis,'ruleList',newRuleList);
fis=setfis(fis,'numRules',size(newRuleList,1));

out=fis;
