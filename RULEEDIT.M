function ruleedit(action);
%RULEEDIT Rule editor and parser.
%	The Rule Editor displays the rules associated with a given
%	fuzzy system. Rules can be edited and displayed in any 
%	of three different modes. Verbose mode use words like 
%	"if" and "then" to make the rules read as much like normal                  
%	sentences as possible. Symbolic mode is a language neutral 
%	mode that relies on symbols to specify the relationship 
%	between the parts of the rule. Indexed mode is a highly 
%	abbreviated version in which each input and output variable          
%	corresponds to a column and MFs are referred to by their 
%	index number.                                
%                                                  
%	If you make a change to the rules, typing control-return 
%	will parse the new rules.                 
%
%	See also FUZZY, MFEDIT, RULEVIEW, and SURFVIEW.

%	Ned Gulley, 3-30-94
%	Copyright (c) 1994-95 by The MathWorks, Inc.
%	$Revision: 1.17 $  $Date: 1995/02/17 13:08:10 $

if nargin<1,
    newFis=newfis('Untitled');
    newFis=addvar(newFis,'input','input1',[0 1]);
    newFis=addvar(newFis,'output','output1',[0 1]);
    action=newFis;
end

if isstr(action),
    if action(1)~='#',
	% The string "action" is not a switch for this function, 
	% so it must be a disk file
	fis=readfis(action);
    	action='#initialize';
    end
else
    % For initialization, the fis matrix is passed in as the parameter
    fis=action;
    action='#initialize';
end;

if strcmp(action,'#initialize'),
    fisName=getfis(fis,'Name');
    fisType=getfis(fis,'Type');
    numInputs=getfis(fis,'numInputs');
    numOutputs=getfis(fis,'numOutputs');
    numRules=getfis(fis,'numRules');

    %===================================
    % Information for all objects
    frmColor=192/255*[1 1 1];
    btnColor=192/255*[1 1 1];
    popupColor=192/255*[1 1 1];
    editColor=255/255*[1 1 1];
    axColor=128/255*[1 1 1];
    border=6;
    spacing=6;
    figPos=get(0,'DefaultFigurePosition');
    maxRight=figPos(3);
    maxTop=figPos(4);
    btnWid=100;
    btnHt=25;
 
    %====================================
    % The FIGURE
    figNumber=figure( ...
        'Name',['Rule Editor: ' fisName], ...
        'NumberTitle','off', ...
	'Color',frmColor, ...
	'MenuBar','none', ...
	'Visible','off', ...
	'UserData',fis, ...
	'Position',figPos, ...
	'Tag','ruleedit', ...
	'BackingStore','off');
    figPos=get(figNumber,'position');

    %====================================
    % The MENUBAR items
    % First create the menus standard to every GUI
    fisgui #initialize
 
    editHndl=findobj(figNumber,'Type','uimenu','Tag','editmenu');
	uimenu(editHndl,'Label','Undo', ...
	    'Tag','undo', ...
	    'Enable','off', ...
	    'Callback','popundo(gcf)');

    optHndl=uimenu(figNumber,'Label','Options','Tag','optionsmenu');
	langHndl=uimenu(optHndl,'Label','Language','Tag','language');
	    callbackStr='ruleedit #langselect';
	    uimenu(langHndl,'Label','English', ...
	    	'Tag','english', ...
		'Checked','on', ...
	    	'Callback',callbackStr);
	    uimenu(langHndl,'Label','Deutsch', ...
	    	'Tag','deutsch', ...
	    	'Callback',callbackStr);
	    uimenu(langHndl,'Label','Francais', ...
	    	'Tag','francais', ...
	    	'Callback',callbackStr);
%	    uimenu(langHndl,'Label','Svenska', ...
%	    	'Tag','svenska', ...
%	    	'Callback',callbackStr);

    %========================================================
    % The MAIN frame 
    bottom=border;
    top=maxTop-border; 
    right=maxRight-border;
    left=border;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
	right-left+frmBorder*2 top-bottom+frmBorder*2];
    mainFrmHndl=uicontrol( ...
        'Style','frame', ...
	'Units','pixel', ...
        'Position',frmPos, ...
	'BackgroundColor',frmColor);

    %====================================
    % The RULE FORMAT frame 
    bottom=border+4*spacing+btnHt;
    top=bottom+btnHt;
    left=border+spacing;
    right=left+2*btnWid+spacing;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
	right-left+frmBorder*2 top-bottom+frmBorder*2];
    mthFrmHndl=uicontrol( ...
        'Style','frame', ...
	'Units','pixel', ...
        'Position',frmPos, ...
	'BackgroundColor',frmColor);

    %------------------------------------
    % The RULE FORMAT text field
    labelStr='Rule Format';
    pos=[left bottom btnWid btnHt];
    txtHndl=uicontrol( ...
        'Style','text', ...
	'BackgroundColor',frmColor, ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'Units','pixel', ...
        'String',labelStr);

    %------------------------------------
    % The RULE FORMAT popup menu
    labelStr=' verbose| symbolic| indexed';
    name='ruleformat';
    callbackStr='ruleedit #disprules';
    pos=[right-btnWid bottom btnWid btnHt];
    ruleDispHndl=uicontrol( ...
        'Style','popupmenu', ...
	'Units','pixel', ...
	'BackgroundColor',popupColor, ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'Callback',callbackStr, ...
	'Tag',name, ...
        'String',labelStr);

    %====================================
    % The RULES frame 
    bottom=top+3*spacing;
    top=maxTop-border-spacing;
    right=maxRight-border-spacing;
    left=border+spacing;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
	right-left+frmBorder*2 top-bottom+frmBorder*2];
    ruleFrmHndl=uicontrol( ...
        'Style','frame', ...
	'Units','pixel', ...
        'Position',frmPos, ...
	'BackgroundColor',frmColor);

    %------------------------------------
    % The RULES edit window
    rulePos=[left bottom right-left top-bottom];
    if numRules>0,
    	labelStr=' ';
%        showrule(fis,1:numRules,'verbose');
%    	labelStr=[32*ones(size(labelStr,1),1) labelStr];
    else
	labelStr=' ';
	msgStr=['No rules for system "' fisName '"'];
	statmsg(figNumber,msgStr);
    end
    name='rulewindow';
    callbackStr='ruleedit #applyrules';
    pos=[left bottom btnWid*2 btnHt];
    ruleHndl=uicontrol( ...
        'Style','edit', ...
	'Units','pixel', ...
        'Position',rulePos, ...
	'BackgroundColor',editColor, ...
	'Callback',callbackStr, ...
	'HorizontalAlignment','left', ...
	'Max',40, ...
	'Tag',name);

    %====================================
    % The CLOSE frame 
    bottom=border+4*spacing+btnHt;
    top=bottom+btnHt;
    right=maxRight-border-spacing;
    % Left should be snug up against Rule Format frame
    left=border+5*spacing+2*btnWid;

    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
	right-left+frmBorder*2 top-bottom+frmBorder*2];
    clsFrmHndl=uicontrol( ...
        'Style','frame', ...
	'Units','pixel', ...
        'Position',frmPos, ...
	'BackgroundColor',frmColor);

    %------------------------------------
    % The HELP button
    labelStr='Help';
    callbackStr='ruleedit #help';
    helpHndl=uicontrol( ...
        'Style','push', ...
        'Position',[left bottom btnWid btnHt], ...
	'BackgroundColor',btnColor, ...
        'String',labelStr, ...
        'Callback',callbackStr);

    %------------------------------------
    % The CLOSE button
    labelStr='Close';
    callbackStr='fisgui #close';
    closeHndl=uicontrol( ...
        'Style','push', ...
        'Position',[right-btnWid bottom btnWid btnHt], ...
	'BackgroundColor',btnColor, ...
        'String',labelStr, ...
        'Callback',callbackStr);

    %====================================
    % The STATUS frame 
    bottom=border+spacing;
    top=bottom+btnHt;
    right=maxRight-border-spacing;
    left=border+spacing;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
	right-left+frmBorder*2 top-bottom+frmBorder*2];
    mainFrmHndl=uicontrol( ...
        'Style','frame', ...
	'Units','pixel', ...
        'Position',frmPos, ...
	'BackgroundColor',frmColor);

    %------------------------------------
    % The STATUS text window
    labelStr=['FIS Name: ' fisName];
    name='status';
    pos=[left bottom right-left btnHt];
    txtHndl=uicontrol( ...
        'Style','text', ...
	'BackgroundColor',frmColor, ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'Units','pixel', ...
	'Tag',name, ...
        'String',labelStr);

    ruleedit #update

    % Normalize all coordinates
    hndlList=findobj(figNumber,'Units','pixels');
    set(hndlList,'Units','normalized');

    % Uncover the figure
    set(figNumber, ...
	'Visible','on', ...
	'UserData',fis, ...
	'NextPlot','new');

elseif strcmp(action,'#update'),
    %====================================
    figNumber=watchon;
    fis=get(figNumber,'UserData');
    numRules=getfis(fis,'numRules');
    fisName=getfis(fis,'name');

    % The RULES FORMAT edit window
    name='ruleformat';
    hndl=findobj(figNumber,'Type','uicontrol','Tag',name);
    formatList=get(hndl,'String');
    formatVal=get(hndl,'Value');
    formatStr=deblank(formatList(formatVal,:));
    % Strip out the leading blanks
    formatStr(find(formatStr==32))=[];

    % The RULES edit window
    name='rulewindow';
    hndl=findobj(figNumber,'Type','uicontrol','Tag',name);
    if numRules>0,
 	langHndl=findobj(figNumber,'Type','uimenu','Checked','on');
	lang=get(langHndl,'Tag');
    	labelStr=showrule(fis,1:numRules,formatStr,lang);
    	labelStr=[32*ones(size(labelStr,1),1) labelStr];
    else
	labelStr=' ';
	msgStr=['No rules for system "' fisName '"'];
	statmsg(figNumber,msgStr);
    end
    set(hndl,'String',labelStr);
    watchoff(figNumber)

elseif strcmp(action,'#disprules'),
    %====================================
    figNumber=watchon;
    popupHndl=findobj(figNumber,'Type','uicontrol','Tag','ruleformat');
    popupList=get(popupHndl,'String');
    popupValue=get(popupHndl,'Value');
    dispStyle=deblank(popupList(popupValue,:));
    dispStyle=fliplr(deblank(fliplr(dispStyle)));
    fis=get(figNumber,'UserData');
    numRules=getfis(fis,'numRules');
    if numRules==0,
    	msgStr=['There are no rules for this system.'];
    	statmsg(figNumber,msgStr);
    else
    	msgStr=['Translating to ' dispStyle ' format'];
    	statmsg(figNumber,msgStr);
    	editHndl=findobj(figNumber,'Type','uicontrol','Style','edit');
 	langHndl=findobj(figNumber,'Type','uimenu','Checked','on');
	lang=get(langHndl,'Tag');
    	editStr=showrule(fis,1:numRules,dispStyle,lang);
    	editStr=[32*ones(size(editStr,1),1) editStr];
    	set(editHndl,'String',editStr);
    end
    watchoff(figNumber);

elseif strcmp(action,'#applyrules'),
    %====================================
    % Apply the edited rules to the current fismatrix
    figNumber=watchon;
    fis=get(figNumber,'UserData');

    editHndl=findobj(figNumber,'Type','uicontrol','Style','edit');
    popupHndl=findobj(figNumber,'Type','uicontrol','Style','popupmenu');
    popupList=get(popupHndl,'String');
    popupValue=get(popupHndl,'Value');
    dispStyle=deblank(popupList(popupValue,:));
    dispStyle=fliplr(deblank(fliplr(dispStyle)));
    txtRuleList=get(editHndl,'String');
    langHndl=findobj(figNumber,'Type','uimenu','Checked','on');
    lang=get(langHndl,'Tag');
    msgStr='Applying the current rule list to the FIS';
    statmsg(figNumber,msgStr);

    oldNumRules=getfis(fis,'numRules');
    [fis,outTxtRuleList,errorStr]=parsrule(fis,txtRuleList,dispStyle,lang);

    newNumRules=getfis(fis,'numRules');
    pushundo(figNumber,fis);
    if oldNumRules==newNumRules,
	% Don't bother updating the FIS Editor if the number of rules
	% has stayed the same...
    	updtfis(figNumber,fis,[4 5]);
    else
    	updtfis(figNumber,fis,[4 5]);
    end
    numRules=newNumRules;

    % Now refresh the display
    editStr=outTxtRuleList;
    editStr=[32*ones(size(editStr,1),1) editStr];
    set(editHndl,'String',editStr);

    if numRules==0,
	statmsg(figNumber,'No rules for this system')
    end

    if ~isempty(errorStr),
	statmsg(figNumber,errorStr);
    end

    watchoff(figNumber);

elseif strcmp(action,'#langselect');
    %====================================
    figNumber=watchon;
    langSelectHndl=get(figNumber,'CurrentMenu');
    langMenuHndl=get(langSelectHndl,'Parent');
    langUnselectHndl=findobj(langMenuHndl,'Checked','on');
    set(langUnselectHndl,'Checked','off');
    set(langSelectHndl,'Checked','on');
    ruleedit #disprules
    watchoff(figNumber)

elseif strcmp(action,'#help');
    %====================================
    figNumber=watchon;
    hthelp('ruleedit.m');
    watchoff(figNumber)
                                                          
end;    % if strcmp(action, ...
