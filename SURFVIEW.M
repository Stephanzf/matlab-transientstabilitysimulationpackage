function surfview(action);
%SURFVIEW Output surface viewer.
%	The Surface Viewer displays the entire output surface 
%	for one output variable and two input variables. More 
%	than two inputs and one output can be accomodated by using 
%	the popup menus just below the plot region.             
%	                                              
%	If there are more than two inputs for a given system, 
%	reference input values must be supplied for the non-varying
%	inputs. This is done using the Ref. Input text field.         
%	                                               
%	A wide variety of plotting and display options are available 
%	from the Options menu.          
%	                                               
%	See also FUZZY, MFEDIT, RULEEDIT, and RULEVIEW.

%	Ned Gulley, 3-30-94
%	Copyright (c) 1994-95 by The MathWorks, Inc.
%	$Revision: 1.22 $  $Date: 1995/02/17 13:08:10 $

if nargin<1,
    % Open up an untitled system.
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
    %====================================
    fisName=getfis(fis,'name');
    % Set up default colormap
    colorMap=jet(150);
    colorMap=colorMap(33:97,:);
    nameStr=['Surface Viewer: ' fisName];
    figNumber=figure( ...
        'Name',nameStr, ...
        'NumberTitle','off', ...
	'Visible','off', ...
	'MenuBar','none', ...
	'UserData',fis, ...
	'Tag','surfview', ...
	'ColorMap',colorMap);
    figPos=get(figNumber,'position');

    %====================================
    % The MENUBAR items
    % First create the menus standard to every GUI
    fisgui #initialize
 
    editHndl=findobj(figNumber,'Type','uimenu','Tag','editmenu');
	uimenu(editHndl,'Label','Undo', ...
	    'Enable','off');

    labelStr=menulabel('&Options ');
    optHndl=uimenu(figNumber, ...
	'Label',labelStr, ...
	'Tag','optionsmenu');
    	plotHndl=uimenu(optHndl, ...
	    'Label','Plot', ...
	    'Tag','plottype');
	    callbackStr='surfview #plotselect';
	    uimenu(plotHndl,'Label','Surface', ...
	    	'Checked','on', ...
	    	'Callback',callbackStr);
	    uimenu(plotHndl,'Label','Lit Surface', ...
	    	'Checked','off', ...
	    	'Callback',callbackStr);
	    uimenu(plotHndl,'Label','Mesh', ...
	    	'Checked','off', ...
	    	'Callback',callbackStr);
	    uimenu(plotHndl,'Label','X Mesh', ...
	    	'Checked','off', ...
	    	'Callback',callbackStr);
	    uimenu(plotHndl,'Label','Y Mesh', ...
	    	'Checked','off', ...
	    	'Callback',callbackStr);
	    uimenu(plotHndl,'Label','Contour', ...
	    	'Checked','off', ...
	    	'Callback',callbackStr);
	    uimenu(plotHndl,'Label','Pseudo-Color', ...
	    	'Checked','off', ...
	    	'Callback',callbackStr);
	    uimenu(plotHndl,'Label','Quiver', ...
	    	'Checked','off', ...
	    	'Callback',callbackStr);
	mapHndl=uimenu(optHndl,'Label','Color Map','Tag','colormap');
	    uimenu(mapHndl,'Label','Default', ...
	    	'Callback','surfview #colormap');
	    uimenu(mapHndl,'Label','Blue', ...
	    	'Callback','surfview #colormap');
	    uimenu(mapHndl,'Label','Hot', ...
	    	'Callback','surfview #colormap');
	    uimenu(mapHndl,'Label','HSV', ...
	    	'Callback','surfview #colormap');
	uimenu(optHndl,'Label','Always evaluate', ...
	    'Separator','on', ...
	    'Checked','on', ...
	    'Tag','alwayseval', ...
	    'Callback','surfview #evaltoggle');

    %===================================
    % Information for all objects
    frmColor=192/255*[1 1 1];
    btnColor=192/255*[1 1 1];
    popupColor=192/255*[1 1 1];
    editColor=255/255*[1 1 1];
    axColor=128/255*[1 1 1];
    border=6;
    spacing=6;
    maxRight=figPos(3);
    maxTop=figPos(4);
    btnWid=90;
    btnHt=22;

    bottom=border;
    top=bottom+4*btnHt+9*spacing;
    right=maxRight-border;
    left=border;
 
    %====================================
    % The MAIN frame
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
	right-left+frmBorder*2 top-bottom+frmBorder*2];
    frmHndl=uicontrol( ...
        'Style','frame', ...
	'Units','pixel', ...
        'Position',frmPos, ...
	'BackgroundColor',frmColor);

    %====================================
    % The AXIS
    axBorder=40;
    axPos=[left+3*axBorder top+axBorder right-left-6.5*axBorder ...
	maxTop-top-border-1.5*axBorder];
    axHndl=axes( ...
	'Units','pixel', ...
        'Position',axPos, ...
	'NextPlot','replace', ...
	'Box','on');
    titleStr=['Output surface for the FIS ' fisName];
    title(titleStr);

    %====================================
    % The DATA frame 
    top=top-spacing;
    bottom=top-spacing-2*btnHt;
    right=maxRight-border-spacing;
    left=border+spacing;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
	right-left+frmBorder*2 top-bottom+frmBorder*2];
    dataFrmHndl=uicontrol( ...
        'Style','frame', ...
	'Units','pixel', ...
        'Position',frmPos, ...
	'BackgroundColor',frmColor);

    dtBtnWid=0.95*btnWid;
    dtBtnWidWide=1.1*dtBtnWid;
    dtBtnWidNarrow=2*dtBtnWid-dtBtnWidWide;
    dtSpacing=(right-left-6*dtBtnWid)/5;
    %------------------------------------
    % The X-AXIS text field
    n=1;
    labelStr='X (input):';
    pos=[left+(n-1)*(dtBtnWid+dtSpacing) top-btnHt dtBtnWidNarrow btnHt];
    ruleDispHndl=uicontrol( ...
        'Style','text', ...
	'BackgroundColor',frmColor', ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'Units','pixel', ...
        'String',labelStr);

    %------------------------------------
    % The X-AXIS popup menu
    n=2;
    name='xaxis';
    callbackStr='surfview #xaxis';
    pos=[left+(n-2)*(dtBtnWid+dtSpacing)+dtBtnWidNarrow+dtSpacing ...
	top-btnHt dtBtnWidWide btnHt];
    ruleDispHndl=uicontrol( ...
        'Style','popupmenu', ...
	'BackgroundColor',popupColor, ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'Callback',callbackStr, ...
	'Units','pixel', ...
	'Tag',name);

    %------------------------------------
    % The Y-AXIS text field
    n=3;
    labelStr='Y (input):';
    pos=[left+(n-1)*(dtBtnWid+dtSpacing) top-btnHt dtBtnWidNarrow btnHt];
    ruleDispHndl=uicontrol( ...
        'Style','text', ...
	'BackgroundColor',frmColor', ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'Units','pixel', ...
        'String',labelStr);

    %------------------------------------
    % The Y-AXIS popup menu
    n=4;
    name='yaxis';
    callbackStr='surfview #yaxis';
    pos=[left+(n-2)*(dtBtnWid+dtSpacing)+dtBtnWidNarrow+dtSpacing ...
	top-btnHt dtBtnWidWide btnHt];
    ruleDispHndl=uicontrol( ...
        'Style','popupmenu', ...
	'BackgroundColor',popupColor, ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'Callback',callbackStr, ...
	'Units','pixel', ...
	'Tag',name);

    %------------------------------------
    % The Z-AXIS text field
    n=5;
    labelStr='Z (output):';
    pos=[left+(n-1)*(dtBtnWid+dtSpacing) top-btnHt dtBtnWidNarrow btnHt];
    ruleDispHndl=uicontrol( ...
        'Style','text', ...
	'BackgroundColor',frmColor', ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'Units','pixel', ...
        'String',labelStr);

    %------------------------------------
    % The Z-AXIS popup menu
    n=6;
    name='zaxis';
    callbackStr='surfview #refinputedit';
    pos=[left+(n-2)*(dtBtnWid+dtSpacing)+dtBtnWidNarrow+dtSpacing ...
	top-btnHt dtBtnWidWide btnHt];
    ruleDispHndl=uicontrol( ...
        'Style','popupmenu', ...
	'BackgroundColor',popupColor, ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'Callback',callbackStr, ...
	'Units','pixel', ...
	'Tag',name);

    %------------------------------------
    % The X-GRID text field
    n=1;
    labelStr='X grids:';
    pos=[left+(n-1)*(dtBtnWid+dtSpacing) top-2*btnHt-spacing dtBtnWidNarrow btnHt];
    ruleDispHndl=uicontrol( ...
        'Style','text', ...
	'BackgroundColor',frmColor', ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'Units','pixel', ...
        'String',labelStr);

    %------------------------------------
    % The X-GRID edit field
    n=2;
    labelStr=' 15';
    name='xgrid';
    callbackStr='surfview #grids';
    pos=[left+(n-2)*(dtBtnWid+dtSpacing)+dtBtnWidNarrow+dtSpacing ...
	top-2*btnHt-spacing dtBtnWidWide btnHt];
    ruleDispHndl=uicontrol( ...
        'Style','edit', ...
	'BackgroundColor',editColor, ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'Callback',callbackStr, ...
	'Units','pixel', ...
	'Tag',name, ...
        'String',labelStr);

    %------------------------------------
    % The Y-GRID text field
    n=3;
    labelStr='Y grids:';
    pos=[left+(n-1)*(dtBtnWid+dtSpacing) top-2*btnHt-spacing dtBtnWidNarrow btnHt];
    ruleDispHndl=uicontrol( ...
        'Style','text', ...
	'BackgroundColor',frmColor', ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'Units','pixel', ...
        'String',labelStr);

    %------------------------------------
    % The Y-GRID edit field
    n=4;
    labelStr=' 15';
    name='ygrid';
    callbackStr='surfview #grids';
    pos=[left+(n-2)*(dtBtnWid+dtSpacing)+dtBtnWidNarrow+dtSpacing ...
	top-2*btnHt-spacing dtBtnWidWide btnHt];
    ruleDispHndl=uicontrol( ...
        'Style','edit', ...
	'BackgroundColor',editColor, ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'Callback',callbackStr, ...
	'Units','pixel', ...
	'Tag',name, ...
        'String',labelStr);

    %------------------------------------
    % The EVALUATE button
    n=6;
    labelStr='Evaluate';
    name='evaluate';
    callbackStr='surfview #evaluate';
    pos=[left+(n-2)*(dtBtnWid+dtSpacing)+dtBtnWidNarrow+dtSpacing ...
	top-2*btnHt-spacing dtBtnWidWide btnHt];
    ruleDispHndl=uicontrol( ...
        'Style','pushbutton', ...
	'BackgroundColor',btnColor, ...
        'Position',pos, ...
	'Callback',callbackStr, ...
	'Units','pixel', ...
	'Enable','off', ...
	'Tag',name, ...
        'String',labelStr);

    %====================================
    % The REFERENCE INPUT frame 
    bottom=border+4*spacing+btnHt;
    top=bottom+btnHt;
    left=border+spacing;
    right=maxRight-border-2*btnWid-5*spacing;

    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
	right-left+frmBorder*2 top-bottom+frmBorder*2];
    topFrmHndl=uicontrol( ...
        'Style','frame', ...
	'Units','pixel', ...
        'Position',frmPos, ...
	'BackgroundColor',frmColor);

    refSpacing=(right-left-3*btnWid)/2;
    %------------------------------------
    % The REFERENCE INPUT text window
    labelStr='Ref. Input:';
    pos=[left bottom btnWid btnHt];
    helpHndl=uicontrol( ...
        'Style','text', ...
	'BackgroundColor',frmColor', ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'Units','pixel', ...
        'String',labelStr);

    %------------------------------------
    % The INPUT edit window
    name='refinputedit';
    callbackStr='surfview #refinputedit';
    pos=[left+btnWid+spacing bottom right-left-btnWid-spacing btnHt];
    inputDispHndl=uicontrol( ...
        'Style','edit', ...
	'BackgroundColor',editColor, ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'Units','pixel', ...
	'Tag',name, ...
	'Callback',callbackStr);

    %====================================
    % The CLOSE frame 
    right=maxRight-border-spacing;
    left=right-2*btnWid-spacing;
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
    callbackStr='surfview #help';
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
    dataFrmHndl=uicontrol( ...
        'Style','frame', ...
	'Units','pixel', ...
        'Position',frmPos, ...
	'BackgroundColor',frmColor);

    %------------------------------------
    % The STATUS text window
    labelStr='Status info go here';
    name='status';
    pos=[left bottom right-left btnHt];
    hndl=uicontrol( ...
        'Style','text', ...
	'BackgroundColor',frmColor', ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'Units','pixel', ...
	'Tag',name, ...
        'String',labelStr);

    surfview #update
    frot3d on

    % Normalize all coordinates
    hndlList=findobj(figNumber,'Units','pixels');
    set(hndlList,'Units','normalized');
 
    % Uncover the figure
    set(figNumber, ...
	'Visible','on');

elseif strcmp(action,'#update');
    %====================================
    figNumber=watchon;
    fis=get(figNumber,'UserData');

    xaxisHndl=findobj(figNumber,'Type','uicontrol','Tag','xaxis');
    yaxisHndl=findobj(figNumber,'Type','uicontrol','Tag','yaxis');
    zaxisHndl=findobj(figNumber,'Type','uicontrol','Tag','zaxis');
    xgridHndl=findobj(figNumber,'Type','uicontrol','Tag','xgrid');
    ygridHndl=findobj(figNumber,'Type','uicontrol','Tag','ygrid');
    plotHndl=findobj(figNumber,'Type','uimenu','Tag','plottype');
    evalHndl=findobj(figNumber,'Type','uimenu','Tag','alwayseval');
    refinputHndl=findobj(figNumber,'Type','uicontrol','Tag','refinputedit');
    hndlList=[xaxisHndl yaxisHndl zaxisHndl xgridHndl ygridHndl ...
	 plotHndl evalHndl refinputHndl];
    set(hndlList,'Enable','off');

    numInputs=getfis(fis,'numInputs');
    numOutputs=getfis(fis,'numOutputs');
    if (numInputs<1) | (numOutputs<1),
	statmsg(figNumber, ...
	    'Need at least one input and one output to view output surface');
	cla	
	watchoff(figNumber)
	return
    end
    numRules=getfis(fis,'numRules');
    if numRules<1,
	statmsg(figNumber,'Need at least one rule to view output surface');
	cla
	watchoff(figNumber)
	return
    end

    % The X-AXIS popup menu
    inLabels=getfis(fis,'inLabels');
    xAxisLabelStr=[32*ones(size(inLabels,1),1) inLabels];
    labelStr=xAxisLabelStr;
    set(xaxisHndl,'String',labelStr);

    % The Y-AXIS popup menu
    inLabels(1,:)=[];
    if ~isempty(inLabels),
    	labelStr=[32*ones(size(inLabels,1)+1,1) str2mat(inLabels,'- none -')];
    else
	labelStr=' - none -';
    end
    set(yaxisHndl,'String',labelStr);

    % The Z-AXIS popup menu
    outLabels=getfis(fis,'outLabels');
    labelStr=[32*ones(size(outLabels,1),1) outLabels];
    set(zaxisHndl,'String',labelStr);

    % The REFERENCE INPUT edit field
    if numInputs==0,
	refInput=[];
    else
 	Range=getfis(fis,'inRange');
    	refInput=mean(Range');
    end
    set(refinputHndl,'UserData',refInput);

    set(hndlList,'Enable','on');
    surfview #refinputedit

elseif strcmp(action,'#refinputedit');
    %====================================
    figNumber=watchon;
    refInputHndl=findobj(figNumber,'Type','uicontrol','Tag','refinputedit');
    % The edit field's UserData is where the actual reference input is stored
    oldRefInput=get(refInputHndl,'UserData');

    fis=get(figNumber,'UserData');
    numInputs=getfis(fis,'numInputs');
    inLabels=getfis(fis,'inLabels');

    % Determine the x axis
    xAxisHndl=findobj(figNumber,'Type','uicontrol','Tag','xaxis');
    xAxisValue=get(xAxisHndl,'Value');
    xAxisList=get(xAxisHndl,'String');
    xAxisStr=deblank(xAxisList(xAxisValue,:));
    xIndex=findrow(xAxisStr,inLabels);
 
    % Determine the y axis
    yAxisHndl=findobj(figNumber,'Type','uicontrol','Tag','yaxis');
    yAxisValue=get(yAxisHndl,'Value');
    yAxisList=get(yAxisHndl,'String');
    yAxisStr=deblank(yAxisList(yAxisValue,:));
    yIndex=findrow(yAxisStr,inLabels);

    newRefInput=eval(get(refInputHndl,'String'),'oldRefInput');

    if length(newRefInput)~=length(oldRefInput),
	newRefInput=oldRefInput;
    end

    % Fill in the spots that are currently occupied by NaN place-holders
    nanIndex=find(isnan(newRefInput));
    newRefInput(nanIndex)=oldRefInput(nanIndex);

    inRange=getfis(fis,'inRange');

    % Guarantee that new input falls within the accepted range for the variable
    newRefInput=max(inRange(:,1)',newRefInput);
    newRefInput=min(inRange(:,2)',newRefInput);
 
    set(refInputHndl,'UserData',newRefInput);

    % Re-insert the NaN place-holders
    if isempty(yIndex),
    	newRefInput(xIndex)=NaN;
    else
    	newRefInput([xIndex yIndex])=[NaN NaN];
    end

    if all(isnan(newRefInput)),
	% If it's nothing but NaNs, then don't let the user edit (or see) the field
    	set(refInputHndl,'String',' ', ...
	    'Enable','off')
    else
    	set(refInputHndl,'String',[' ' fmat2str(newRefInput,4)], ...
	    'Enable','on')
    end

    % Plot right away if always-eval is checked
    evalHndl=findobj(gcf,'Type','uimenu','Tag','alwayseval');
    if strcmp(get(evalHndl,'Checked'),'on'),
	surfview #evaluate
    end
	
    watchoff(figNumber);

elseif strcmp(action,'#xaxis');
    %====================================
    % We need to prevent the x-axis and y-axis from being the same thing
    figNumber=watchon;
    xAxisHndl=get(figNumber,'CurrentObject');
    fis=get(figNumber,'UserData');
    numInputs=getfis(fis,'numInputs');
    inLabels=getfis(fis,'inLabels');
    outLabels=getfis(fis,'outLabels');
    % Determine the x axis
    xAxisValue=get(xAxisHndl,'Value');
    xAxisList=get(xAxisHndl,'String');
    xAxisStr=deblank(xAxisList(xAxisValue,:));
    xIndex=findrow(xAxisStr,inLabels);
    yAxisHndl=findobj(figNumber,'Type','uicontrol','Tag','yaxis');
    yAxisValue=get(yAxisHndl,'Value');
    inLabels(xIndex,:)=[];
    if ~isempty(inLabels),
    	yAxisList=[32*ones(numInputs,1) str2mat(inLabels,'- none -')];
    else
	yAxisList=' - none -';
    end
    set(yAxisHndl,'String',yAxisList);
    set(yAxisHndl,'Value',yAxisValue);
    yAxisStr=deblank(yAxisList(yAxisValue,:));
    yIndex=findrow(yAxisStr,inLabels);

    % Now update the reference input area
    surfview #refinputedit
    watchoff(figNumber);

elseif strcmp(action,'#yaxis');
    %====================================
    % We need to prevent the x-axis and y-axis from being the same thing
    figNumber=watchon;
    % Update the reference input area
    surfview #refinputedit
    watchoff(figNumber);

elseif strcmp(action,'#grids');
    %====================================
    % Calculate immediately if necessary
    gridHndl=gco;
    % Use try-catch to avoid bogus grids
    gridNum=eval(get(gridHndl,'String'),'15');
    gridNum=abs(round(gridNum(1)));
    gridNum=max(gridNum,3);
    gridNum=min(gridNum,100);
    set(gridHndl,'String',[' ' num2str(gridNum)]);
    evalHndl=findobj(gcf,'Type','uimenu','Tag','alwayseval'); 
    if strcmp(get(evalHndl,'Checked'),'on'),
	surfview #evaluate
    end

elseif strcmp(action,'#evaluate');
    %====================================
    figNumber=get(0,'CurrentFigure');
    axHndl=get(figNumber,'CurrentAxes');
    fis=get(figNumber,'UserData');
    statmsg(figNumber,'Calculating new surface');

    % Determine the number of points to be evaluated
    xGridHndl=findobj(figNumber,'Type','uicontrol','Tag','xgrid');
    xGrids=eval(get(xGridHndl,'String'));
    yGridHndl=findobj(figNumber,'Type','uicontrol','Tag','ygrid');
    yGrids=eval(get(yGridHndl,'String'));

    inLabels=getfis(fis,'inLabels');
    outLabels=getfis(fis,'outLabels');

    % Determine the x axis
    xAxisHndl=findobj(figNumber,'Type','uicontrol','Tag','xaxis');
    xAxisValue=get(xAxisHndl,'Value');
    xAxisList=get(xAxisHndl,'String');
    xAxisStr=deblank(xAxisList(xAxisValue,:));
    xIndex=findrow(xAxisStr,inLabels);
 
    % Determine the y axis
    yAxisHndl=findobj(figNumber,'Type','uicontrol','Tag','yaxis');
    yAxisValue=get(yAxisHndl,'Value');
    yAxisList=get(yAxisHndl,'String');
    yAxisStr=deblank(yAxisList(yAxisValue,:));
    yIndex=findrow(yAxisStr,inLabels);

    zAxisHndl=findobj(figNumber,'Type','uicontrol','Tag','zaxis');
    zIndex=get(zAxisHndl,'Value');
    Range=getfis(fis,'inRange');

    % Retrieve the reference input from the edit field's UserData
    refInputHndl=findobj(figNumber,'Type','uicontrol','Tag','refinputedit');
    refInput=get(refInputHndl,'UserData');

    [x,y,z]=gensurf(fis,[xIndex yIndex],zIndex,[xGrids yGrids],refInput);

    % Put the results in the appropriate hiding places
    plotMenuHndl=findobj(figNumber,'Type','uimenu','Tag','plottype');
    cmapMenuHndl=findobj(figNumber,'Type','uimenu','Tag','colormap');
    if isempty(y),
%	set(axHndl,'NextPlot','replace');
%	set(figNumber,'NextPlot','replace');
	plot(x,z,'Color',[.5 1 1],'LineWidth',3);
    	xlabel(deblank(inLabels(xIndex,:)));
    	ylabel(deblank(outLabels(zIndex,:)));
    	set(axHndl,'Box','on')
 	set(plotMenuHndl,'Enable','off');
 	set(cmapMenuHndl,'Enable','off');
	frot3d off
%	set(figNumber,'NextPlot','new');
%	set(axHndl,'NextPlot','new');
    else
    	xlabel(deblank(inLabels(xIndex,:)));
    	ylabel(deblank(inLabels(yIndex,:)));
    	zlabel(deblank(outLabels(zIndex,:)));
    	set(axHndl,'UserData',[x y z],'Box','on')
 	set(plotMenuHndl,'Enable','on');
 	set(cmapMenuHndl,'Enable','on');
	frot3d on
    	surfview #plot
    end
    statmsg(figNumber,'Ready');

elseif strcmp(action,'#plot');
    figNumber=watchon;
    plotMenuHndl=findobj(figNumber,'Type','uimenu','Tag','plottype');
    plotTypeHndl=findobj(plotMenuHndl,'Checked','on');
    plotType=deblank(get(plotTypeHndl,'Label'));
    axHndl=get(figNumber,'CurrentAxes');

    % Unpack the hidden data
    xyz=get(axHndl,'UserData');
    viewData=get(axHndl,'View');
    numCols=size(xyz,2)/3;
    x=xyz(:,1:numCols);
    y=xyz(:,numCols+(1:numCols));
    z=xyz(:,2*numCols+(1:numCols));
    xStr=get(get(axHndl,'XLabel'),'String');
    yStr=get(get(axHndl,'YLabel'),'String');
    zStr=get(get(axHndl,'ZLabel'),'String');

%    set(figNumber,'NextPlot','replace');
    cla

    frot3d on
    colorMap=get(figNumber,'Colormap');
    if all(viewData==[0 90]),
	viewData=[-37.5 30];
    end

    % Generate the plot
    if strcmp(plotType,'Surface'),
	surf(x,y,z);
    elseif strcmp(plotType,'Lit Surface'),
	surfl(x,y,z);
    elseif strcmp(plotType,'Mesh'),
	meshHndl=mesh(x,y,z);
	set(meshHndl,'LineWidth',2);
    elseif strcmp(plotType,'X Mesh'),
	meshHndl=mesh(x,y,z);
	set(meshHndl,'MeshStyle','row','FaceColor','none','LineWidth',2);
    elseif strcmp(plotType,'Y Mesh'),
	meshHndl=mesh(x,y,z);
	set(meshHndl,'MeshStyle','column','FaceColor','none','LineWidth',2);
    elseif strcmp(plotType,'Contour'),
    	% Coordinate the current color order with the current colormap
    	xmap=[1 2 3];
    	mapLen=size(colorMap,1);
    	xmap=xmap(ones(mapLen,1),:);
    	ymap=(1:mapLen)'/mapLen;
    	ymap=[ymap ymap ymap];
	% Set the number of contour intervals for the 3-d contour plot
%	numContours=round(1.5*max(size(x)));
	numContours=20;
    	ximap=[1 2 3];
    	ximap=ximap(ones(numContours,1),:);
    	yimap=(1:numContours)'/numContours;
    	yimap=[yimap yimap yimap];
    	colorOrder=interp4(xmap,ymap,colorMap,ximap,yimap);
    	set(axHndl,'ColorOrder',colorOrder);
	[c,h]=contour3(x,y,z,numContours);
 	for count=1:length(h),
	    set(h(count), ...
		'Color',colorOrder(count,:), ...
		'LineWidth',3);
	end
    elseif strcmp(plotType,'Pseudo-Color'),
	pcolor(x,y,z);
	viewData=[0 90];
	frot3d off
    elseif strcmp(plotType,'Quiver'),
	[px,py]=gradient(z);
	quiver(x,y,px,py,2,'c')
	viewData=[0 90];
	frot3d off
    end

    set(axHndl,'UserData',xyz,'Box','on')
%    set(figNumber,'NextPlot','new');
    xlabel(xStr);
    ylabel(yStr);
    zlabel(zStr);
    xMin=min(min(x)); xMax=max(max(x));
    yMin=min(min(y)); yMax=max(max(y));
    zMin=min(min(z)); zMax=max(max(z));
    if zMin==zMax, zMin=-inf; zMax=inf; end;
    axis([xMin xMax yMin yMax zMin zMax])
    set(axHndl,'View',viewData)
    watchoff(figNumber);

elseif strcmp(action,'#colormap');
    figNumber=watchon;
    menuHndl=get(figNumber,'CurrentMenu');
    newMapName=deblank(get(menuHndl,'Label'));
    if strcmp(newMapName,'Default'),
    	newMap=jet(150);
    	newMap=newMap(33:97,:);
    elseif strcmp(newMapName,'Blue'),
    	newMap=fliplr(pink(120));
    	newMap=newMap(43:107,:);
    elseif strcmp(newMapName,'Hot'),
    	newMap=hot(128);
    	newMap=newMap(43:107,:);
    elseif strcmp(newMapName,'HSV'),
	newMap=hsv;
    end

    colormap(newMap)
    watchoff(figNumber)

elseif strcmp(action,'#shading');
    %====================================
    figNumber=watchon;
    menuHndl=get(figNumber,'CurrentMenu');
    shadingType=deblank(get(menuHndl,'Label'));
    surfHndl=findobj(figNumber,'Type','surface');
    if strcmp(shadingType,'Faceted'),
	set(surfHndl,'FaceColor','flat');
	set(surfHndl,'EdgeColor',mean(get(figNumber,'Colormap')));
    elseif strcmp(shadingType,'Flat'),
	set(surfHndl,'FaceColor','flat');
	set(surfHndl,'EdgeColor','none');
    elseif strcmp(shadingType,'Smooth'),
	set(surfHndl,'FaceColor','interp');
	set(surfHndl,'EdgeColor',mean(get(figNumber,'Colormap')));
    end

    watchoff(figNumber)

elseif strcmp(action,'#evaltoggle');
    %====================================
    figNumber=watchon;
    evalMenuHndl=get(figNumber,'CurrentMenu');
    evalBtnHndl=findobj(figNumber,'Type','uicontrol','Tag','evaluate');
    if strcmp(get(evalMenuHndl,'Checked'),'on'),
	set(evalMenuHndl,'Checked','off');
	set(evalBtnHndl,'Enable','on');
    else
	set(evalMenuHndl,'Checked','on');
	set(evalBtnHndl,'Enable','off');
    end
    watchoff(figNumber)

elseif strcmp(action,'#plotselect');
    %====================================
    figNumber=watchon;
    plotSelectHndl=get(figNumber,'CurrentMenu');
    plotMenuHndl=get(plotSelectHndl,'Parent');
    plotUnselectHndl=findobj(plotMenuHndl,'Checked','on');
    set(plotUnselectHndl,'Checked','off');
    set(plotSelectHndl,'Checked','on');
    surfview #plot
    watchoff(figNumber)

elseif strcmp(action,'#help');
    %====================================
    figNumber=watchon;
    hthelp('surfview.m');
    watchoff(figNumber)
                                               
end;
