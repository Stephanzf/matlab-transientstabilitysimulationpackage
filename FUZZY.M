function fuzzy(action);
%FUZZY 	Basic FIS editor.
%	The FIS Editor displays high-level information about a 
%	Fuzzy Inference System. At the top is a diagram of the 
%	system with each input and output clearly labeled. By 
%	double-clicking on the input or output boxes, you can bring 
%	up the Membership Function Editor. Double-clicking on the 
%	fuzzy rule box in the center of the diagram will bring up 
%	the Rule Editor.                     
%                                                    
%	Just below the diagram is a text field that displays the 
%	name of the current FIS. In the lower left of the window are 
%	a series of popup menus that allow you to specify the various 
%	functions used in the fuzzy implication process. In the lower 
%	right are fields that provide information about the current 
%	variable. The current variable is determined by clicking once
%	on one of the input or output boxes.
%
%	See also MFEDIT, RULEEDIT, RULEVIEW, and SURFVIEW.

%	Ned Gulley, 4-30-94
%	Copyright (c) 1994-95 by The MathWorks, Inc.
%	$Revision: 1.11 $  $Date: 1995/02/17 13:08:10 $

% The # symbol is used to mark all callbacks into this function
selectColor=[1 0.3 0.3];

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
    % Detect any FIS Editors out there with exactly the same name
    fisName=getfis(fis,'Name');
    figName=['FIS Editor: ' fisName];
    while findobj(0,'Type','figure','Name',figName),
    	nameLen=length(fisName);
    	lastChar=fisName(nameLen);
    	if abs(lastChar)>47 & abs(lastChar)<58,
 	    fisName(nameLen)=lastChar+1;
    	else
	    fisName=[fisName '2'];
    	end
    	fis=setfis(fis,'name',fisName);
        figName=['FIS Editor: ' fisName];
    end

    fisType=getfis(fis,'Type');
    NumInputs=getfis(fis,'NumInputs');
    NumOutputs=getfis(fis,'NumOutputs');
    NumRules=getfis(fis,'NumRules');

    %===================================
    % Information for all objects
    frmColor=192/255*[1 1 1];
    btnColor=192/255*[1 1 1];
    popupColor=192/255*[1 1 1];
    editColor=255/255*[1 1 1];
    border=6;
    spacing=6;
    figPos=get(0,'DefaultFigurePosition');
    maxRight=figPos(3);
    maxTop=figPos(4);
    btnWid=110;
    btnHt=23;
 
    %====================================
    % The FIGURE
    figNumber=figure( ...
        'Name',figName, ...
        'NumberTitle','off', ...
	'Color',[0.9 0.9 0.9], ...
	'Visible','off', ...
	'MenuBar','none', ...
	'UserData',fis, ...
	'Units','pixels', ...
	'DefaultAxesXColor','black', ...
	'DefaultAxesYColor','black', ...
	'Position',figPos, ...
	'Tag','fuzzy', ...
	'ButtonDownFcn','fuzzy #deselect', ...
	'Nextplot','new', ...
	'KeyPressFcn','fuzzy #keypress');
    figPos=get(figNumber,'position');

    %====================================
    % The MENUBAR items
    % First create the menus standard to every GUI
    fisgui #initialize
 
    editHndl=findobj(figNumber,'Type','uimenu','Tag','editmenu');
	uimenu(editHndl,'Label','Add input', ...
	    'Tag','input', ...
	    'Callback','fuzzy #addvar');
	uimenu(editHndl,'Label','Add output', ...
	    'Tag','output', ...
	    'Callback','fuzzy #addvar');
	[labelStr,accelStr]=menulabel('&Remove variable ^x');
	uimenu(editHndl,'Label',labelStr, ...
	    'Accelerator',accelStr, ...
	    'Tag','removevar', ...
	    'Enable','off', ...
	    'Callback','fuzzy #rmvar');
	[labelStr,accelStr]=menulabel('&Undo ^z');
	uimenu(editHndl,'Label','Undo', ...
	    'Enable','off', ...
	    'Tag','undo', ...
	    'Accelerator',accelStr, ...
	    'Callback','popundo(gcf)');

    %====================================
    % The AXES frame 
    top=maxTop-border;
    bottom=border+7*btnHt+14*spacing;
    right=maxRight-border;
    left=border;
    axBorder=spacing;
    axPos=[left-axBorder bottom-0.5*axBorder ...
	right-left+axBorder*2 top-bottom+axBorder*2];
    axHndl=axes( ...
	'Box','on', ...
	'Units','pixels', ...
	'Position',axPos, ...
	'Tag','mainaxes', ...
	'Visible','on');

    %====================================
    % The MAIN frame 
    top=border+7*btnHt+12*spacing;
    bottom=border; 
    right=maxRight-border;
    left=border;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
	right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 0 1 0];
    mainFrmHndl=uicontrol( ...
        'Style','frame', ...
	'Units','pixel', ...
        'Position',frmPos, ...
	'BackgroundColor',frmColor);

    %====================================
    % The STATUS frame 
    bottom=border+spacing;
    top=bottom+btnHt;
    right=maxRight-border-spacing;
    left=border+spacing;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
	right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 0 1 0];
    topFrmHndl=uicontrol( ...
        'Style','frame', ...
	'Units','pixel', ...
        'Position',frmPos, ...
	'BackgroundColor',frmColor);

    %------------------------------------
    % The STATUS text window
    labelStr=' ';
    name='status';
    pos=[left bottom right-left btnHt];
    statHndl=uicontrol( ...
        'Style','text', ...
	'BackgroundColor',frmColor, ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'Units','pixel', ...
	'Tag',name, ...
        'String',labelStr);

    %====================================
    % The TOP frame 
    top=border+7*btnHt+11*spacing;
    bottom=top-btnHt;
    right=maxRight-border-spacing;
    left=border+spacing;

    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
	right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 0 1 0];
    topFrmHndl=uicontrol( ...
        'Style','frame', ...
	'Units','pixel', ...
        'Position',frmPos, ...
	'BackgroundColor',frmColor);

    %------------------------------------
    % The FIS NAME text window
    labelStr='FIS Name:';
    pos=[left top-btnHt btnWid btnHt];
    hndl=uicontrol( ...
        'Style','text', ...
	'BackgroundColor',frmColor, ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'Units','pixel', ...
        'String',labelStr);

    %------------------------------------
    % The FIS NAME edit window
    name='fisname';
    pos=[left+spacing+btnWid top-btnHt btnWid btnHt];
    hndl=uicontrol( ...
	'Units','pixel', ...
        'Style','text', ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'BackgroundColor',frmColor, ...
 	'Tag',name);

    %------------------------------------
    % The FIS TYPE text window
    labelStr='FIS Type:';
    pos=[right-spacing-2*btnWid top-btnHt btnWid btnHt];
    hndl=uicontrol( ...
	'Units','pixel', ...
        'Style','text', ...
	'BackgroundColor',frmColor, ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'Units','pixel', ...
        'String',labelStr);

    %------------------------------------
    % The FIS TYPE text display
    labelStr=' mamdani';
    name='fistype';
    pos=[right-btnWid top-btnHt btnWid btnHt];
    hndl=uicontrol( ...
	'Units','pixel', ...
        'Style','text', ...
	'HorizontalAlignment','left', ...
	'BackgroundColor',frmColor, ...
        'Position',pos, ...
 	'Tag',name, ...
        'String',labelStr);

    %====================================
    % The VARIABLES frame 
    top=border+6*btnHt+8*spacing;
    bottom=border+7*spacing+2*btnHt;
    right=maxRight-border-spacing;
    left=(maxRight)/2+2*spacing;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
	right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 0 1 0];
    varFrmHndl=uicontrol( ...
	'Units','pixel', ...
        'Style','frame', ...
        'Position',frmPos, ...
	'BackgroundColor',frmColor);

    varSpacing=(top-bottom-4*btnHt)/3;
    %------------------------------------
    % The CURRENT VARIABLE text field
    n=1;
    labelStr='Current Variable';
    pos=[left top-btnHt*n-varSpacing*(n-1) right-left btnHt];
    uicontrol( ...
	'Units','pixel', ...
        'Style','text', ...
	'BackgroundColor',frmColor, ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
        'String',labelStr);

    %------------------------------------
    % The CURRENT VARIABLE NAME text field
    n=2;
    labelStr='Name';
    pos=[left top-btnHt*n-varSpacing*(n-1) right-left btnHt];
    hndl=uicontrol( ...
	'Units','pixel', ...
        'Style','text', ...
	'BackgroundColor',frmColor, ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
        'String',labelStr);

    %------------------------------------
    % The CURRENT VARIABLE NAME edit field
    callbackStr='fuzzy #varname';
    name='currvarname';
    pos=[right-btnWid top-btnHt*n-varSpacing*(n-1) btnWid btnHt];
    inputVarNameHndl=uicontrol( ...
	'Units','pixel', ...
        'Style','edit', ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'Enable','off', ...
	'BackgroundColor',editColor, ...
	'Tag',name, ...
	'Callback',callbackStr);

    %------------------------------------
    % The CURRENT VARIABLE TYPE text field
    n=3;
    labelStr='Type';
    pos=[left top-btnHt*n-varSpacing*(n-1) btnWid btnHt];
    uicontrol( ...
	'Units','pixel', ...
        'Style','text', ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'BackgroundColor',frmColor, ...
        'String',labelStr);

    %------------------------------------
    % The CURRENT VARIABLE TYPE text field
    name='currvartype';
    pos=[right-btnWid top-btnHt*n-varSpacing*(n-1) btnWid btnHt];
    hndl=uicontrol( ...
        'Style','text', ...
	'HorizontalAlignment','left', ...
	'BackgroundColor',frmColor, ...
        'Position',pos, ...
	'Units','pixel', ...
	'Tag',name);

    %------------------------------------
    % The CURRENT VARIABLE RANGE text field
    n=4;
    labelStr='Range';
    pos=[left top-btnHt*n-varSpacing*(n-1) btnWid btnHt];
    outputVarNameHndl=uicontrol( ...
        'Style','text', ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'BackgroundColor',frmColor, ...
	'String',labelStr, ...
	'Units','pixel');

    %------------------------------------
    % The CURRENT VARIABLE RANGE display field
    name='currvarrange';
    pos=[right-btnWid top-btnHt*n-varSpacing*(n-1) btnWid btnHt];
    outputVarNameHndl=uicontrol( ...
        'Style','text', ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'BackgroundColor',frmColor, ...
	'Tag',name, ...
	'Units','pixel');

    %====================================
    % The METHODS frame 
    bottom=border+4*spacing+btnHt;
    left=border+spacing;
    right=(maxRight)/2-spacing;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
	right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 0 1 0];
    mthFrmHndl=uicontrol( ...
        'Style','frame', ...
	'Units','pixel', ...
        'Position',frmPos, ...
	'BackgroundColor',frmColor);

    mthSpacing=(top-bottom-5*btnHt)/4;
    %------------------------------------
    % The AND METHOD text field
    n=1;
    labelStr='And method';
    pos=[left top-btnHt*n-mthSpacing*(n-1) btnWid btnHt];
    hndl=uicontrol( ...
        'Style','text', ...
	'BackgroundColor',frmColor, ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'Units','pixel', ...
        'String',labelStr);

    %------------------------------------
    % The AND METHOD popup menu
    labelStr=str2mat(' min',' prod',' Custom...');
    name='andmethod';
    callbackStr='fuzzy #methodchange';
    pos=[right-btnWid top-btnHt*n-mthSpacing*(n-1) btnWid btnHt];
    hndl=uicontrol( ...
        'Style','popupmenu', ...
	'BackgroundColor',popupColor, ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'Callback',callbackStr, ...
	'Units','pixel', ...
	'Tag',name, ...
        'String',labelStr);

    %------------------------------------
    % The OR METHOD text field
    n=2;
    labelStr='Or method';
    pos=[left top-btnHt*n-mthSpacing*(n-1) btnWid btnHt];
    hndl=uicontrol( ...
        'Style','text', ...
	'BackgroundColor',frmColor, ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'Units','pixel', ...
        'String',labelStr);

    %------------------------------------
    % The OR METHOD popup menu
    labelStr=str2mat(' max',' probor',' Custom...');
    name='ormethod';
    callbackStr='fuzzy #methodchange';
    pos=[right-btnWid top-btnHt*n-mthSpacing*(n-1) btnWid btnHt];
    hndl=uicontrol( ...
        'Style','popupmenu', ...
	'HorizontalAlignment','left', ...
	'BackgroundColor',popupColor, ...
        'Position',pos, ...
	'Callback',callbackStr, ...
	'Units','pixel', ...
	'Tag',name, ...
        'String',labelStr);

    %------------------------------------
    % The IMPLICATION METHOD text field
    n=3;
    labelStr='Implication';
    pos=[left top-btnHt*n-mthSpacing*(n-1) btnWid btnHt];
    hndl=uicontrol( ...
        'Style','text', ...
	'BackgroundColor',frmColor, ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'Units','pixel', ...
        'String',labelStr);

    %------------------------------------
    % The IMPLICATION METHOD popup menu
    labelStr=str2mat(' min',' prod',' Custom...');
    name='impmethod';
    callbackStr='fuzzy #methodchange';
    pos=[right-btnWid top-btnHt*n-mthSpacing*(n-1) btnWid btnHt];
    hndl=uicontrol( ...
        'Style','popupmenu', ...
	'HorizontalAlignment','left', ...
	'BackgroundColor',popupColor, ...
        'Position',pos, ...
	'Callback',callbackStr, ...
	'Units','pixel', ...
	'Tag',name, ...
        'String',labelStr);
    if strcmp(fisType,'sugeno'),
	set(hndl,'Enable','off');
    end

    %------------------------------------
    % The AGGREGATION METHOD text field
    n=4;
    labelStr='Aggregation';
    pos=[left top-btnHt*n-mthSpacing*(n-1) btnWid btnHt];
    hndl=uicontrol( ...
        'Style','text', ...
	'BackgroundColor',frmColor, ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'Units','pixel', ...
        'String',labelStr);

    %------------------------------------
    % The AGGREGATION METHOD popup menu
    labelStr=str2mat(' max',' sum',' probor',' Custom...');
    name='aggmethod';
    callbackStr='fuzzy #methodchange';
    pos=[right-btnWid top-btnHt*n-mthSpacing*(n-1) btnWid btnHt];
    hndl=uicontrol( ...
        'Style','popupmenu', ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'BackgroundColor',popupColor, ...
	'Callback',callbackStr, ...
	'Units','pixel', ...
	'Tag',name, ...
        'String',labelStr);
    if strcmp(fisType,'sugeno'),
	set(hndl,'Enable','off');
    end

    %------------------------------------
    % The DEFUZZIFICATION METHOD text field
    n=5;
    labelStr='Defuzzification';
    pos=[left top-btnHt*n-mthSpacing*(n-1) btnWid btnHt];
    hndl=uicontrol( ...
        'Style','text', ...
	'BackgroundColor',frmColor, ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'Units','pixel', ...
        'String',labelStr);

    %------------------------------------
    % The DEFUZZIFICATION METHOD popup menu
    if strcmp(fisType,'mamdani'),
	% Defuzzification methods are different depending on the FIS type
    	labelStr=str2mat(' centroid',' bisector',' mom',' lom', ...
	    ' som',' Custom...');
    else
    	labelStr=str2mat(' wtaver',' wtsum');
    end
    name='defuzzmethod';
    callbackStr='fuzzy #methodchange';
    pos=[right-btnWid top-btnHt*n-mthSpacing*(n-1) btnWid btnHt];
    hndl=uicontrol( ...
        'Style','popupmenu', ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'BackgroundColor',popupColor, ...
	'Callback',callbackStr, ...
	'Units','pixel', ...
	'Tag',name, ...
        'String',labelStr);

    %====================================
    % The CLOSE frame 
%    top=border+2*spacing+2*btnHt;
    bottom=border+4*spacing+btnHt;
    top=bottom+btnHt;
    right=maxRight-border-spacing;
    left=(maxRight)/2+2*spacing;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
	right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 0 1 0];
    clsFrmHndl=uicontrol( ...
        'Style','frame', ...
	'Units','pixel', ...
        'Position',frmPos, ...
	'BackgroundColor',frmColor);

    %------------------------------------
    % The HELP button
    labelStr='Help';
    callbackStr='fuzzy #help';
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

    fuzzy #update

    % Uncover the figure
    set(figNumber, ...
	'Visible','on', ...
	'NextPlot','new');

elseif strcmp(action,'#update'),
    %====================================
    figNumber=watchon;
    fis=get(figNumber,'UserData');
    NumInputs=getfis(fis,'NumInputs');
    NumOutputs=getfis(fis,'NumOutputs');
    NumRules=getfis(fis,'NumRules');

    % The FIS NAME edit window
    name='fisname';
    hndl=findobj(figNumber,'Type','uicontrol','Tag',name);
    fisName=getfis(fis,'name');
    labelStr=[' ' fisName];
    set(hndl,'String',labelStr);

    % The FIS TYPE text field
    name='fistype';
    hndl=findobj(figNumber,'Type','uicontrol','Tag',name);
    fisType=getfis(fis,'type');
    set(hndl,'String',fisType);

    % Clear all current variable display registers ...
    varTypeHndl=findobj(figNumber,'Type','uicontrol','Tag','currvartype');
    set(varTypeHndl,'String',' ');
    varNameHndl=findobj(figNumber,'Type','uicontrol','Tag','currvarname');
    set(varNameHndl,'String',' ','Enable','off');
    varRangeHndl=findobj(figNumber,'Type','uicontrol','Tag','currvarrange');
    set(varRangeHndl,'String',' ');
    
    % The AND METHOD popup menu
    name='andmethod';
    hndl=findobj(figNumber,'Type','uicontrol','Tag',name);
    labelStr=get(hndl,'String');
    andMethod=getfis(fis,'andMethod');
    val=findrow(andMethod,labelStr);
    if isempty(val),
	labelStr=str2mat([' ' andMethod],labelStr);
        msgStr=['Installing custom And method "' andMethod '"'];
     	statmsg(figNumber,msgStr);
    	set(hndl,'String',labelStr,'Value',1);
    elseif val~=get(hndl,'Value'),
    	set(hndl,'Value',val);
    end

    % The OR METHOD popup menu
    name='ormethod';
    hndl=findobj(figNumber,'Type','uicontrol','Tag',name);
    labelStr=get(hndl,'String');
    orMethod=getfis(fis,'orMethod');
    val=findrow(orMethod,labelStr);
    if isempty(val),
	labelStr=str2mat([' ' orMethod],labelStr);
        msgStr=['Installing custom Or method "' orMethod '"'];
     	statmsg(figNumber,msgStr);
    	set(hndl,'String',labelStr,'Value',1);
    elseif val~=get(hndl,'Value'),
    	set(hndl,'Value',val);
    end

    if ~strcmp(fisType,'sugeno'),
    	% The IMPLICATION METHOD popup menu
    	name='impmethod';
    	hndl=findobj(figNumber,'Type','uicontrol','Tag',name);
    	labelStr=get(hndl,'String');
    	impMethod=getfis(fis,'impMethod');
    	val=findrow(impMethod,labelStr);
    	if isempty(val),
	    labelStr=str2mat([' ' impMethod],labelStr);
            msgStr=['Installing custom Implication method "' impMethod '"'];
     	    statmsg(figNumber,msgStr);
    	    set(hndl,'String',labelStr,'Value',1);
    	elseif val~=get(hndl,'Value'),
    	    set(hndl,'Value',val);
    	end

    	% The AGGREGATION METHOD popup menu
    	name='aggmethod';
    	hndl=findobj(figNumber,'Type','uicontrol','Tag',name);
   	labelStr=get(hndl,'String');
    	aggMethod=getfis(fis,'aggMethod');
    	val=findrow(aggMethod,labelStr);
    	if isempty(val),
	    labelStr=str2mat([' ' aggMethod],labelStr);
            msgStr=['Installing custom Aggregation method "' aggMethod '"'];
     	    statmsg(figNumber,msgStr);
    	    set(hndl,'String',labelStr,'Value',1);
    	elseif val~=get(hndl,'Value'),
    	    set(hndl,'Value',val);
    	end
    end

    % The DEFUZZIFICATION METHOD popup menu
    name='defuzzmethod';
    hndl=findobj(figNumber,'Type','uicontrol','Tag',name);
    labelStr=get(hndl,'String');
    defuzzMethod=getfis(fis,'defuzzMethod');
    val=findrow(defuzzMethod,labelStr);
    if isempty(val),
	labelStr=str2mat([' ' defuzzMethod],labelStr);
        msgStr=['Installing custom Defuzzification method "' defuzzMethod '"'];
     	statmsg(figNumber,msgStr);
    	set(hndl,'String',labelStr,'Value',1);
    elseif val~=get(hndl,'Value'),
    	set(hndl,'Value',val);
    end

    % Now plot the FIS diagram
    % First delete all axes except for the main one
    axHndlList=findobj(figNumber,'Type','axes');
    mainAxHndl=findobj(figNumber,'Type','axes','Tag','mainaxes');
    axHndlList(find(axHndlList==mainAxHndl))=[];
    delete(axHndlList);
    lineHndlList=findobj(figNumber,'Type','line');
    delete(lineHndlList);
    fuzzy #plotfis

    fisName=getfis(fis,'name');
    msgStr=[ 'System "' fisName '": ' num2str(NumInputs) ' inputs, ' ...
	num2str(NumOutputs) ' outputs, and ' ...
	num2str(NumRules) ' rules'];
    if NumInputs==1, msgStr=strrep(msgStr,'inputs','input'); end
    if NumOutputs==1, msgStr=strrep(msgStr,'outputs','output'); end
    if NumRules==1, msgStr=strrep(msgStr,'rules','rule'); end
    statmsg(figNumber,msgStr);

    watchoff(figNumber)

elseif strcmp(action,'#keypress'),
    %====================================
    figNumber=gcf;
    if abs(get(figNumber,'CurrentCharacter'))==127,
    	if ~isempty(findobj(figNumber,'Type','axes','XColor',selectColor)),
	    fuzzy #rmvar
	end
    end

elseif strcmp(action,'#rmvar'),
    %====================================
    figNumber=watchon;
    fis=get(figNumber,'UserData');

    currVarAxes=findobj(figNumber,'Type','axes','XColor',selectColor);
    if isempty(currVarAxes),
	statmsg(figNumber,'No variable was selected!');
	watchoff(figNumber)
	return
    end
    varIndex=get(currVarAxes,'UserData');
    tag=get(currVarAxes,'Tag');
    if strcmp(tag(1:5),'input'),
	varType='input';
    else
	varType='output';
    end

    % Find the corresponding name display field
    varNameHndl=findobj(figNumber,'Type','uicontrol','Tag','currvarname');
    varName=getfis(fis,varType,varIndex,'name');

    if strcmp(varType,'input'), 
    	numVars=getfis(fis,'NumInputs');
	varLabels=getfis(fis,'InLabels');
    else
    	numVars=getfis(fis,'NumOutputs');
	varLabels=getfis(fis,'OutLabels');
    end

    % Remove a variable
    [fis,errorMsg]=rmvar(fis,varType,varIndex);
    if isempty(fis),
        % rmvar has failed for one reason or other
        statmsg(figNumber,errorMsg)
    else
        msgStr=['Removing the ' varType ' variable "' varName '"'];
        statmsg(figNumber,msgStr);

	pushundo(figNumber,fis);
        updtfis(figNumber,fis,[2 4 5]);

	% Now replot the FIS diagram
	% First delete all axes except for the main one
	axHndlList=findobj(figNumber,'Type','axes');
	mainAxHndl=findobj(figNumber,'Type','axes','Tag','mainaxes');
	axHndlList(find(axHndlList==mainAxHndl))=[];
	delete(axHndlList);
	lineHndlList=findobj(figNumber,'Type','line');
	delete(lineHndlList);
	fuzzy #plotfis

	% Clear the VARIABLE NAME, TYPE, and RANGE fields
	hndl=findobj(figNumber,'Type','uicontrol','Tag','currvarname');
	set(hndl,'String',' ');
	hndl=findobj(figNumber,'Type','uicontrol','Tag','currvartype');
	set(hndl,'String',' ');
	hndl=findobj(figNumber,'Type','uicontrol','Tag','currvarrange');
	set(hndl,'String',' ');
    end

    watchoff(figNumber)

elseif strcmp(action,'#addvar'),
    %====================================
    figNumber=watchon;
    currMenu=get(figNumber,'CurrentMenu');
    varType=get(currMenu,'Tag');
    fis=get(figNumber,'UserData');

    % "Add" has been selected, so add a variable
    if strcmp(varType,'input'),
	numVars=getfis(fis,'numInputs');
    else
	numVars=getfis(fis,'numOutputs');
    end
    numVars=numVars+1;
    newVarName=[varType num2str(numVars)];
    msgStr=['Adding the ' varType ' variable "' newVarName '"'];
    statmsg(figNumber,msgStr);
    fis=addvar(fis,varType,newVarName,[0 1]);
    pushundo(figNumber,fis);
    updtfis(figNumber,fis,[2 4 5]);
%    set(figNumber,'UserData',fis);

    % Now replot the FIS diagram
    % First delete all axes except for the main one
    axHndlList=findobj(figNumber,'Type','axes');
    mainAxHndl=findobj(figNumber,'Type','axes','Tag','mainaxes');
    axHndlList(find(axHndlList==mainAxHndl))=[];
    delete(axHndlList);
    lineHndlList=findobj(figNumber,'Type','line');
    delete(lineHndlList);
    fuzzy #plotfis

    % Clear the VARIABLE NAME, TYPE, and RANGE fields
    hndl=findobj(figNumber,'Type','uicontrol','Tag','currvarname');
    set(hndl,'String',' ');
    hndl=findobj(figNumber,'Type','uicontrol','Tag','currvartype');
    set(hndl,'String',' ');
    hndl=findobj(figNumber,'Type','uicontrol','Tag','currvarrange');
    set(hndl,'String',' ');

    statmsg(figNumber,'Ready');
    watchoff(figNumber)

elseif strcmp(action,'#deselect'),
    %====================================
    figNumber=watchon; 
    % Deselect all variables
    oldCurrVar=findobj(figNumber,'Type','axes','XColor',selectColor);
    set(oldCurrVar, ...
	'LineWidth',1, ...
	'XColor','black','YColor','black');

    % Clear all current variable display registers ...
    varTypeHndl=findobj(figNumber,'Type','uicontrol','Tag','currvartype');
    set(varTypeHndl,'String',' ');
    varNameHndl=findobj(figNumber,'Type','uicontrol','Tag','currvarname');
    set(varNameHndl,'String',' ','Enable','off');
    varRangeHndl=findobj(figNumber,'Type','uicontrol','Tag','currvarrange');
    set(varRangeHndl,'String',' ');
    rmvarMenuHndl=findobj(figNumber,'Type','uimenu','Tag','removevar');
    set(rmvarMenuHndl,'Enable','off')
    
    watchoff(figNumber)

elseif strcmp(action,'#selectvar'),
    %====================================
    figNumber=watchon; 
    fis=get(figNumber,'UserData');
    newCurrVarPatch=get(figNumber,'CurrentObject');
    newCurrVar=get(newCurrVarPatch,'Parent');
    varIndex=get(newCurrVar,'UserData');
    tag=get(newCurrVar,'Tag');
    if strcmp(tag(1:5),'input'),
	varType='input';
    else
	varType='output';
    end

    % Deselect all others if necessary
    oldCurrVar=findobj(figNumber,'Type','axes','XColor',selectColor);
    if newCurrVar~=oldCurrVar,
	set(oldCurrVar,'XColor','k','YColor','k');
	set(oldCurrVar,'LineWidth',1);
    end

    % Now hilight the new selection
    set(newCurrVar,'XColor',selectColor,'YColor',selectColor);
    set(newCurrVar,'LineWidth',3);

    % Set all current variable display registers ...
    varNameHndl=findobj(figNumber,'Type','uicontrol','Tag','currvarname');
    set(varNameHndl,'String',[' ' getfis(fis,varType,varIndex,'name')],'Enable','on');
    varTypeHndl=findobj(figNumber,'Type','uicontrol','Tag','currvartype');
    set(varTypeHndl,'String',varType);
    varRangeHndl=findobj(figNumber,'Type','uicontrol','Tag','currvarrange');
    set(varRangeHndl,'String',fmat2str(getfis(fis,varType,varIndex,'range'),4));
    rmvarMenuHndl=findobj(figNumber,'Type','uimenu','Tag','removevar');
    set(rmvarMenuHndl,'Enable','on')
    
    if strcmp(get(figNumber,'SelectionType'),'open'),
	% Open the MF Editor with the right variable in view
	fisName=getfis(fis,'name');
	guiName='Membership Function Editor';
    	newFigNumber=findobj(0,'Name',[guiName ': ' fisName]);
    	if ~isempty(newFigNumber),
	    statmsg(figNumber,['Updating ' guiName]);
	    figure(newFigNumber);
 	    mfedit('#update',varType,varIndex);
        else
	    statmsg(figNumber,['Opening ' guiName]);
	    mfedit(fis,varType,varIndex);
    	end

    end

    watchoff(figNumber)

elseif strcmp(action,'#varname'),
    %====================================
    figNumber=watchon; 
    fis=get(figNumber,'UserData');

    currVarAxes=findobj(figNumber,'Type','axes','XColor',selectColor);
    varIndex=get(currVarAxes,'UserData');
    tag=get(currVarAxes,'Tag');
    if strcmp(tag(1:5),'input'),
	varType='input';
    else
	varType='output';
    end

    varNameHndl=findobj(figNumber,'Type','uicontrol','Tag','currvarname');
    newName=deblank(get(varNameHndl,'String'));
    % Strip off the leading space
    newName=fliplr(deblank(fliplr(newName)));
    % Replace any remaining blanks with underscores
    newName(find(newName==32))=setstr(95*ones(size(find(newName==32))));
    set(varNameHndl,'String',[' ' newName]);

    if strcmp(varType,'input'),
	varNames=getfis(fis,'inLabels');
    else
	varNames=getfis(fis,'outLabels');
    end
    msgStr=['Renaming ' varType ' variable ' num2str(varIndex) ' to "' newName '"'];
    statmsg(figNumber,msgStr);

    % Change the name of the label in the input-output diagram
    txtHndl=get(currVarAxes,'XLabel');
    set(txtHndl,'String',newName);

    fis=setfis(fis,varType,varIndex,'name',newName);
    pushundo(figNumber,fis);
    updtfis(figNumber,fis,[2 3 4 5]);
    watchoff(figNumber);

elseif strcmp(action,'#methodchange'),
    %====================================
    figNumber=watchon;
    mthHndl=gco;
    fis=get(figNumber,'UserData');
    mthList=get(mthHndl,'String');
    numMth=size(mthList,1);

    % The UserData for the popup will tell which method is being 
    % changed, e.g. andmethod, ormethod, impmethod, etc.
    mthName=get(mthHndl,'Tag');
    newMthValue=get(mthHndl,'Value');
    newMth=deblank(mthList(newMthValue,:));
    newMth=fliplr(deblank(fliplr(newMth)));
    oldMth=getfis(fis,mthName);
    oldMthValue=findrow(oldMth,mthList);
    if strcmp(newMth,'Custom...'),
	% Handle customized methods...
	mthName2=strrep(mthName,'method',' method');
	tString=['Adding customized ' mthName2];
	statmsg(figNumber,tString);

	cmthdlg(figNumber,fis,mthName);

 	% In case there's a Cancel, return to the old value
	set(mthHndl,'Value',oldMthValue);

    elseif newMthValue~=oldMthValue,
	% Only change things if the method has actually changed
	mthName2=strrep(mthName,'method',' method');
	tString=['Changing ' mthName2 ' to "' newMth '"'];
	statmsg(figNumber,tString);
        fis=setfis(fis,mthName,newMth);

    	% Handle undo    
	pushundo(figNumber,fis)
        updtfis(figNumber,fis,[4 5]);
%    	set(figNumber,'UserData',fis);
    end

%    statmsg(figNumber,'Ready');
    watchoff(figNumber);

elseif strcmp(action,'#openruleedit'),
    %====================================
    figNumber=watchon;
    if strcmp(get(figNumber,'SelectionType'),'open'),
  	ruleeditHndl=findobj(figNumber,'Type','uimenu','Tag','ruleedit');
	set(figNumber,'CurrentMenu',ruleeditHndl);
        fisgui #findgui
    end
    watchoff(figNumber)

elseif strcmp(action,'#plotfis'),
    %====================================
    figNumber=gcf;
    fis=get(figNumber,'UserData');
    set(figNumber,'Nextplot','replace')
    numInputs=getfis(fis,'numInputs');
    numOutputs=getfis(fis,'numOutputs');
    numInputMFs=getfis(fis,'numInputMFs');
    numOutputMFs=getfis(fis,'numOutputMFs');
    numRules=getfis(fis,'numRules');
    ruleList=getfis(fis,'ruleList');
    fisName=getfis(fis,'name');
    fisType=getfis(fis,'type');

    mainAxHndl=gca;
    set(mainAxHndl,'Units','pixel','Visible','off')
    mainAxPos=get(mainAxHndl,'Position');
    axis([mainAxPos(1) mainAxPos(1)+mainAxPos(3) ...
	mainAxPos(2) mainAxPos(2)+mainAxPos(4)]);
    xCenter=mainAxPos(1)+mainAxPos(3)/2;
    yCenter=mainAxPos(2)+mainAxPos(4)/2;
    axList=[];

    if get(0,'ScreenDepth')>2,
    	inputColor=[1 1 0.5];
    	outputColor=[0.5 1 1];
    else
    	inputColor=[1 1 1];
    	outputColor=[1 1 1];
	set(gcf,'Color',[1 1 1])
    end

    % For plotting three cartoon membership functions in the box
    xMin=-1; xMax=1;
    x=(-1:0.1:1)';
    y1=exp(-(x+1).^2/0.32); y2=exp(-x.^2/0.32); y3=exp(-(x-1).^2/0.32);
    xlineMatrix=[x x x];
    ylineMatrix=[y1 y2 y3];

    % Inputs first
    fontSize=10;
    boxWid=(1/3)*mainAxPos(3);
    xInset=boxWid/5;
    if numInputs>0,
	boxHt=(1/(numInputs))*mainAxPos(4);
    	yInset=boxHt/5;
    end

    for varIndex=1:numInputs,
        boxLft=mainAxPos(1);
        boxBtm=mainAxPos(2)+mainAxPos(4)-boxHt*varIndex;
        axPos=[boxLft+xInset boxBtm+yInset boxWid-2*xInset boxHt-2*yInset];

        % Draw the line that connects the input to the main block
        axes(mainAxHndl);
        % Make it a dotted line if the variable is not used in the rule base
   	if numRules==0,
    	    lineStyle='--';
        elseif ~any(ruleList(:,varIndex)), 
    	    lineStyle='--';
        else
	    lineStyle='-';
        end
        xInputCenter=axPos(1)+axPos(3);
        yInputCenter=axPos(2)+axPos(4)/2;
        line([xInputCenter xCenter],[yInputCenter yCenter], ...
	    'LineStyle',lineStyle, ...
	    'LineWidth',3, ...
	    'Color','black');
       % Now draw the little arrowhead on the line
   %    perpSlope=(xInputCenter-xCenter)/(yCenter-yInputCenter);
   %    arrowPt=[(xCenter+xInputCenter)/2 (yCenter+yInputCenter)/2];
   %    delta=(xCenter-xInputCenter)/10;
   %    line([xArrowPt xArrowPt

       	varName=getfis(fis,'input',varIndex,'name');
       	axName=['input' num2str(varIndex)];
       	axHndl=axes( ...
            'Units','pixel', ...
            'Box','on', ...
            'XTick',[],'YTick',[], ...	
	    'XLim',[xMin xMax],'YLim',[-0.1 1.1], ...
	    'Color',inputColor, ...
	    'Tag',axName, ...
	    'UserData',varIndex, ...
            'Position',axPos);
        axList=[axList axHndl];

	line(xlineMatrix,ylineMatrix,'Color','black');
       	xiInset=(xMax-xMin)/10;
       	axis([xMin-xiInset xMax+xiInset -0.1 1.1])

       	% Lay down a patch that simplifies clicking on the region
       	patchHndl=patch([xMin xMax xMax xMin],[0 0 1 1],'black');
       	set(patchHndl, ...
	    'EdgeColor','none', ...
	    'FaceColor','none', ...
	    'ButtonDownFcn','fuzzy #selectvar');

        % Now put on the variable name as a label
%        xlabel([varName ' (' num2str(numInputMFs(varIndex)) ')']);
        xlabel(varName);
        labelName=[axName 'label'];
        set(get(axHndl,'XLabel'), ...
	    'FontSize',fontSize, ...
	    'Color','black', ...
	    'Tag',labelName, ...
	    'ButtonDownFcn','fuzzy #selectvar');
    end

    % Now for the outputs
    if numOutputs>0,
	boxHt=(1/(numOutputs))*mainAxPos(4);
    	yInset=boxHt/5;
    end

    for varIndex=1:numOutputs,
       	boxLft=mainAxPos(1)+2*boxWid;
        boxBtm=mainAxPos(2)+mainAxPos(4)-boxHt*varIndex;
        axPos=[boxLft+xInset boxBtm+yInset boxWid-2*xInset boxHt-2*yInset]; 

        % Draw the line connect the center block to the output
        axes(mainAxHndl);
        % Make it a dotted line if the variable is not used in the rule base
   	if numRules==0,
    	    lineStyle='--';
        elseif ~any(ruleList(:,varIndex+numInputs)), 
	    lineStyle='--';
        else
	    lineStyle='-';
        end
        line([axPos(1) xCenter],[axPos(2)+axPos(4)/2 yCenter], ...
	    'LineWidth',3, ...
	    'LineStyle',lineStyle, ...
	    'Color','black');

       	varName=getfis(fis,'output',varIndex,'name');
       	axName=['output' num2str(varIndex)];
       	axHndl=axes( ...
            'Units','pixel', ...
            'Box','on', ...
	    'Color',outputColor, ...
            'XTick',[],'YTick',[], ...	
  	    'Tag',axName, ...
	    'UserData',varIndex, ...
            'Position',axPos);
       	axList=[axList axHndl];
       	if ~strcmp(fisType,'sugeno'),
   	    % Don't try to plot outputs it if it's a Sugeno-style system
	    x=[-1 -0.5 0 0.5 1]';
	    xlineMatrix=[x x x];
	    ylineMatrix=[0 1 0 0 0;0 0 1 0 0; 0 0 0 1 0]';
	    line(xlineMatrix,ylineMatrix,'Color','black');
   	    xoInset=(xMax-xMin)/10;
 	    axis([xMin-xoInset xMax+xoInset -0.1 1.1])
       	else
	    set(axHndl,'XLim',[xMin xMax],'YLim',[-0.1 1.1])
	    text(0,0.5,'f(u)', ...
    	       	'FontSize',fontSize, ...
    	       	'Color','black', ...
    	       	'HorizontalAlignment','center');
       	end

       	% Lay down a patch that simplifies clicking on the region
       	patchHndl=patch([xMin xMax xMax xMin],[0 0 1 1],'black');
       	set(patchHndl, ...
	    'EdgeColor','none', ...
	    'FaceColor','none', ...
	    'ButtonDownFcn','fuzzy #selectvar');

%        xlabel([varName ' (' num2str(numOutputMFs(varIndex)) ')']);
        xlabel(varName);
        labelName=[axName 'label'];
        set(get(axHndl,'XLabel'), ...
	    'FontSize',fontSize, ...
	    'Color','black', ...
	    'Tag',labelName, ...
	    'ButtonDownFcn','fuzzy #selectvar');
    end

    % Now draw the box in the middle
    boxLft=mainAxPos(1)+boxWid;
    boxBtm=mainAxPos(2);
    boxHt=mainAxPos(4);
    yInset=boxHt/4;
    axPos=[boxLft+xInset boxBtm+yInset boxWid-2*xInset boxHt-2*yInset];
    axHndl=axes( ...
       	'Units','pixel', ...
       	'Box','on', ...
       	'XTick',[],'YTick',[], ...	
       	'YLim',[-1 1],'XLim',[-1 1], ...
       	'XColor','black','YColor','black', ...
       	'LineWidth',2, ...
        'ButtonDownFcn','fuzzy #openruleedit', ...
        'Color','white', ...
        'Position',axPos);
    axList=[axList axHndl];
    text(0,1/3,fisName, ...
        'Tag','fisname', ...
        'FontSize',fontSize, ...
        'ButtonDownFcn','fuzzy #openruleedit', ...
        'Color','black', ...
        'HorizontalAlignment','center');
    text(0,-1/3,['(' fisType ')'], ...
        'FontSize',fontSize, ...
        'ButtonDownFcn','fuzzy #openruleedit', ...
        'Color','black', ...
        'HorizontalAlignment','center');
%    text(0,-1/2,[num2str(numRules) ' rules'], ...
%        'ButtonDownFcn','fuzzy #openruleedit', ...
%       	'FontSize',fontSize, ...
%       	'Color','black', ...
%       	'HorizontalAlignment','center');
    set(get(axHndl,'Title'),'FontSize',fontSize,'Color','black');

    for count=1:length(axList),
       	axes(axList(count));
    end

    set(figNumber,'Nextplot','new')
    hndlList=findobj(figNumber,'Units','pixels');
    set(hndlList,'Units','normalized')

elseif strcmp(action,'#help');
    %====================================
    figNumber=watchon;
    hthelp('fuzzy.m');
    watchoff(figNumber)

end;    % if strcmp(action, ...
