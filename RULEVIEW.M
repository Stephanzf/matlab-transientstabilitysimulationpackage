function ruleview(action);
%RULEVIEW Rule viewer and fuzzy inference diagram.
%	RULEVIEW(FIS) opens the Rule Viewer, or Inference Diagram
%	Viewer, for the fuzzy inference system associated with
%	the matrix FIS. RULEVIEW('FILENAME') will search the MATLAB
%	path and open the system FILENAME.FIS if it finds it.
%
%	The Rule Viewer displays, in one screen, all parts of 
%	the fuzzy inference process from inputs to outputs. Each 
%	row of plots corresponds to one rule, and each column of 
%	plots corresponds to either an input variable (yellow, on 
%	the left) or an output variable (blue, on the right). You
%	can change the system input either by typing a specific 
%	value into the Input window or by moving the long yellow 
%	index lines that go down each input variable's column of 
%	plots.
%	                                                   
%	The aggregate membership function for each output variable 
%	is shown in the bottom right along with the defuzzified 
%	output value.                         
%	                                                   
%	See also FUZZY, MFEDIT, RULEEDIT, and SURFVIEW.

%	Ned Gulley, 3-30-94
%	Copyright (c) 1994-95 by The MathWorks, Inc.
%	$Revision: 1.24 $  $Date: 1995/02/17 13:08:10 $

inputColor=[1 1 0.8];
outputColor=[0.8 1 1];

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
    numRules=getfis(fis,'numRules');
    figNumber=figure( ...
        'Name',['Rule Viewer: ' fisName], ...
        'NumberTitle','off', ...
	'MenuBar','none', ...
	'Visible','off', ...
	'UserData',fis, ...
	'Tag','ruleview', ...
	'BackingStore','off');
    figPos=get(figNumber,'position');

    %====================================
    % The MENUBAR items
    % First create the menus standard to every GUI
    fisgui #initialize
 
    editHndl=findobj(figNumber,'Type','uimenu','Tag','editmenu');
	uimenu(editHndl, ...
	    'Label','Undo', ...
	    'Enable','off');

    labelStr=menulabel('&Options ');
    optHndl=uimenu(figNumber, ...
	'Label',labelStr, ...
	'Tag','optionsmenu');
	formatHndl=uimenu(optHndl,'Label','Rule display format', ...
	    'Tag','dispformat');
	    callbackStr='ruleview #dispformat';
	    uimenu(formatHndl,'Label','Verbose', ...
	   	'Checked','on', ...
	    	'Tag','verbose', ...
	    	'Callback',callbackStr);
	    uimenu(formatHndl,'Label','Symbolic', ...
	   	'Checked','off', ...
	    	'Tag','symbolic', ...
	    	'Callback',callbackStr);
	    uimenu(formatHndl,'Label','Indexed', ...
	   	'Checked','off', ...
	    	'Tag','indexed', ...
	    	'Callback',callbackStr);

    %===================================
    % Information for all objects
    frmColor=192/255*[1 1 1];
    btnColor=192/255*[1 1 1];
    popupColor=192/255*[1 1 1];
    editColor=255/255*[1 1 1];
    border=6;
    spacing=6;
    maxRight=figPos(3);
    maxTop=figPos(4);
    btnWid=90;
    btnHt=22;

    bottom=border;
    top=bottom+2*btnHt+5*spacing;
    right=maxRight-border;
    left=border;
 
    %====================================
    % The MAIN frame
    % This frame is given a name so that it can be located later on
    % using "findobj". The UserData for this frame will contain the
    % matrix of line handles used in the callbacks.
    name='dataframe';
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
	right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 0 1 0];
    frmHndl=uicontrol( ...
        'Style','frame', ...
	'Units','pixel', ...
        'Position',frmPos, ...
	'Tag',name, ...
	'BackgroundColor',frmColor);

    %====================================
    % The INPUT frame 
    top=top-spacing;
    bottom=top-btnHt;
    left=border+spacing;
    right=maxRight-border-2*btnWid-5*spacing;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
	right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 0 1 0];
    topFrmHndl=uicontrol( ...
        'Style','frame', ...
	'Units','pixel', ...
        'Position',frmPos, ...
	'BackgroundColor',frmColor);

    %------------------------------------
    % The INPUT text window
    labelStr='Input:';
    pos=[left bottom btnWid btnHt];
    helpHndl=uicontrol( ...
        'Style','text', ...
	'BackgroundColor',frmColor, ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'Units','pixel', ...
        'String',labelStr);

    %------------------------------------
    % The INPUT edit window
    callbackStr='ruleview #updateinputs';
    name='inputdisp';
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
    % The CLOSE/HELP frame 
    right=maxRight-border-spacing;
    left=right-2*btnWid-spacing;
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
    callbackStr='ruleview #help';
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
	right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 0 1 0];
    dataFrmHndl=uicontrol( ...
        'Style','frame', ...
	'Units','pixel', ...
        'Position',frmPos, ...
	'BackgroundColor',frmColor);

    %------------------------------------
    % The STATUS text window
    labelStr=['Opened system ' fisName ', ' num2str(numRules) ' rules'];
    name='status';
    pos=[left bottom right-left btnHt];
    hndl=uicontrol( ...
        'Style','text', ...
	'BackgroundColor',frmColor, ...
	'HorizontalAlignment','left', ...
        'Position',pos, ...
	'Units','pixel', ...
	'Tag',name, ...
        'String',labelStr);

    ruleview #update

    % Normalize all coordinates
    hndlList=findobj(figNumber,'Units','pixels');
    set(hndlList,'Units','normalized');
 
    % Uncover the figure
    set(figNumber, ...
	'Visible','on', ...
	'NextPlot','new');

elseif strcmp(action,'#update'),
    %====================================
    figNumber=watchon;
    fis=get(figNumber,'UserData');

    % Find and destroy all axes if they exist, since we might be updating
    % a previously existing system
    axHndlList=findobj(figNumber,'Type','axes');
    delete(axHndlList);
    set(figNumber,'Units','pixel')

    inputDispHndl=findobj(figNumber,'Type','uicontrol','Tag','inputdisp');
    set(inputDispHndl,'Enable','off');

    % First some error-checking
    numInputs=getfis(fis,'numInputs');
    numOutputs=getfis(fis,'numOutputs');
    if (numInputs<1) | (numOutputs<1),
	statmsg(figNumber,'Need at least one input and one output to view rules');
	watchoff(figNumber)
	return
    end
    numRules=getfis(fis,'numRules');
    if numRules<1,
	statmsg(figNumber,'Need at least one rule to view rules');
	watchoff(figNumber)
	return
    end

    border=6; 
    spacing=6;
    btnHt=22;
    figPos=get(figNumber,'Position');
    maxRight=figPos(3);
    maxTop=figPos(4);
    axColor=160/255*[1 1 1];

    bottom=border;
    top=bottom+2*btnHt+5*spacing;
    right=maxRight-border;
 
    % The mainAxPos is a border that defines where the rules will be displayed
    % Getting it the right size was mostly trial and error
    mainAxPos=[border top-bottom+border*6 maxRight-border*2 maxTop-top-border*10];

    % Now build all the appropriate axes
    % For each rule, there will be as many axes as (numInputs+numOutputs)
    ruleList=getfis(fis,'ruleList');
    numRules=size(ruleList,1);
    numInputMFs=getfis(fis,'numInputMFs');
    numOutputMFs=getfis(fis,'numOutputMFs');
    numInputs=length(numInputMFs);
    numOutputs=length(numOutputMFs);
    inRange=getfis(fis,'inRange');
    outRange=getfis(fis,'outRange');
    totalVars=numInputs+numOutputs;
    fisType=getfis(fis,'Type');

    boxWid=(1/totalVars)*(maxRight-border*2);
    boxHt=(1/(numRules+1))*(maxTop-top-border*2);
    xInset=boxWid/5;
    yInset=boxHt/10;

    % Here we're precalculating all MF x and y values for plotting later
    numPts=101;
    [xIn,yIn,xOut,yOut,R]=discfis(fis,numPts);

    inputVector1=get(inputDispHndl,'Value');
    inputValidFlag=0;
    % If the previous value of the input vector is still valid, use it.
    if length(inputVector1)==numInputs,
	if all(inputVector1'>inRange(:,1)) & all(inputVector1'<inRange(:,2)),
	    inputValidFlag=1;
  	end
    end
    if inputValidFlag,
 	inputVector=inputVector1;
    else
    	inputVector=mean(inRange');
    end

    % Do the actual FIS evaluation
    [v,irr,orr,arr]=evalfis(inputVector,fis);

    axHndlMat=zeros(numRules+1,totalVars);
    if strcmp(fisType,'sugeno'),
    	sugenoOutputRange=sugmax(fis);
    end

    for ruleIndex=1:(numRules+1),
  	boxBtm=(rem(numRules+1-ruleIndex,(numRules+1))/(numRules+1))*mainAxPos(4)+ ...
	    mainAxPos(2);
	for varIndex=1:totalVars,
    	    boxLft=(rem(varIndex-1,totalVars)/totalVars)*mainAxPos(3)+mainAxPos(1);

	    if (varIndex==1) & (ruleIndex<=numRules),
    		%====================================
		% RULE NUMBER
    		%====================================
		% Every rule number has its own axis
		xInset2=xInset*0.1;
		yInset2=yInset*0.2;
	    	axPos=[boxLft+xInset2 boxBtm+yInset+yInset2 ...
		    xInset-2*xInset2 boxHt-2*yInset-2*yInset2];
            	axes( ...
		    'Units','pixel', ...
		    'Box','on', ...
		    'XTick',[],'YTick',[], ...
		    'Visible','off', ...
		    'XLim',[-1 1],'YLim',[-1 1], ...
        	    'Position',axPos);
		text(0,0,num2str(ruleIndex), ...
		    'ButtonDownFcn','ruleview #disprule', ...
		    'FontSize',9, ...
		    'Tag','rulelabel', ...
		    'HorizontalAlignment','center');
	    end

	    axPos=[boxLft+xInset boxBtm+yInset boxWid-2*xInset boxHt-2*yInset];
            axHndlMat(ruleIndex,varIndex)=axes( ...
		'Units','pixel', ...
		'Box','on', ...
		'XColor',axColor,'YColor',axColor, ...
		'XTick',[],'YTick',[], ...
        	'Position',axPos);

	    if (ruleIndex<=numRules) & (varIndex<=numInputs),
    		%====================================
		% INPUT MFs
    		%====================================
		% Here we are plotting the input variable membership functions
		% R is the modified rule list returned by discfis.
		mfColIndex=abs(R(ruleIndex,varIndex));
		% Use abs because negative refers to the use of NOT
		
		if ruleIndex==1, 
		    % Plot the variable name at the top of each column
		    varName=getfis(fis,'input',varIndex,'name');
		    title(varName,'FontSize',10);
		end

		if mfColIndex,
		    % Don't plot it if the index is zero
		    x=xIn(:,mfColIndex);
		    y=yIn(:,mfColIndex);
		    if R(ruleIndex,varIndex)<0,
			% Invert the MF if a NOT has been applied
			y=1-y;
		    end
		    line(x,y);
		    xMin=min(x);
		    xMax=max(x);
		    set(gca,'XLim',[xMin xMax],'YLim',[-0.05 1.05]);
		    xData=[xMin; x; xMax];
		    yData=min(irr(ruleIndex,varIndex),[0; y; 0]);
		    MFHndlMat(ruleIndex,varIndex)=patch( ...
			xData,yData,[0.8 0.8 0], ...
			'EraseMode','xor');
		end

		if ruleIndex==numRules, 
		    % Display the axis limits
		    set(gca,'XTick',[xMin xMax],'FontSize',10);
		end

	    end

	    if (ruleIndex<=numRules) & (varIndex>numInputs),
    		%====================================
		% OUTPUT MFs
    		%====================================
		% Here we are plotting the output variable membership functions
		% Remember the index may be negative
		outputVarIndex=varIndex-numInputs;
		% we have to subtract off the number of inputs since the
		% inputs are given before the outputs

		if ruleIndex==1, 
		    % Plot the variable name at the top of each column
		    varName=getfis(fis,'output',varIndex-numInputs,'name');
		    title(varName,'FontSize',10);
		end

		mfIndex=abs(ruleList(ruleIndex,varIndex));
		if mfIndex,
		    % Plot it only if the index is nonzero
	    	    mfColIndex=sum(numOutputMFs(1:(outputVarIndex-1)))+mfIndex;
		    if strcmp(fisType,'mamdani'),
			% MAMDANI system
			x=xOut(:,mfColIndex);
		    	y=yOut(:,mfColIndex);
		        if R(ruleIndex,varIndex)<0,
			    % Invert the MF if a NOT has been applied
			    y=1-y;
		    	end
		    	xMin=min(x);
		    	xMax=max(x);
		    	set(gca,'XLim',[xMin xMax],'YLim',[-0.05 1.05]);
			xData=[xMin; x; xMax];
			yData=[0; orr(:,ruleIndex+(varIndex-numInputs-1)*numRules); 0];
		    	MFHndlMat(ruleIndex,varIndex)=patch( ...
			    xData,yData,[0 0.8 0.8], ...
			    'EraseMode','xor');
		    	line(x,y, ...
			     'Color','cyan');
		    else
			% SUGENO system
			range=getfis(fis,'output',varIndex-numInputs,'range');
			% The next line represents an educated guess at what the x axis
			% limits should be
			outRange=sugenoOutputRange(varIndex-numInputs,:);
			outRange=outRange+0.1*(outRange(2)-outRange(1))*[-1 1];
			outRange=eval(fmat2str(outRange,4));
			set(gca, ...
			    'XLim',outRange, ...
			    'YLim',[-0.05 1.05]);
			xData2=[1 1]*orr(ruleIndex,varIndex-numInputs);
			yData2=[0 1];
			% The handle for the thin line will be carried by the fat line
			lineHndl=line(xData2,yData2, ...
			    'LineWidth',2, ...
			    'LineStyle','-', ...
			    'EraseMode','xor', ...
			    'Visible','on', ...
			    'Color',[0 0.9 0.9]);
			xData1=xData2;
			yData1=[0 1]*arr(ruleIndex,varIndex-numInputs);
			MFHndlMat(ruleIndex,varIndex)=line(xData1,yData1, ...
			    'LineWidth',4, ...
			    'EraseMode','xor', ...
			    'UserData',lineHndl, ...
			    'Color','cyan');
		    end
		end
	    end

	    if (ruleIndex>numRules) & (varIndex<=numInputs),
    		%====================================
		% MOVEABLE INDEX LINES
    		%====================================
		% Draw in moveable input index lines
		% This axes position covers all axes in this input column
	        axPos=[boxLft+xInset mainAxPos(2) boxWid-2*xInset mainAxPos(4)];
	    	colIndex=sum(numInputMFs(1:(varIndex-1)))+1;
		xMin=inRange(varIndex,1);
		xMax=inRange(varIndex,2);
		inputVal=inputVector(varIndex);
            	set(gca, ...
		    'Visible','off', ...
		    'Units','pixel', ...
		    'XLim',[xMin xMax],'YLim',[0 1], ...
        	    'Position',axPos);
		line([1 1]*inputVal,[0.05 1], ...
		    'LineWidth',0.5, ...
		    'Color',[1 1 0], ...
		    'ButtonDownFcn','ruleview #clickline', ...
		    'EraseMode','xor', ...
		    'UserData',varIndex, ...
		    'Tag','indexline', ...
		    'LineStyle','-');
		% The following patch is used to allow click-anywhere 
		% positioning of the index line
		patchHndl=patch([xMin xMax xMax xMin xMin],[0 0 1 1 0],'black');
		set(patchHndl, ...
		    'ButtonDownFcn','ruleview #patchclick', ...
		    'FaceColor','none', ...
		    'EdgeColor','none');
		xlabel(num2str(inputVal,3), ...
		    'FontSize',10, ...
		    'EraseMode','background');
		set(get(gca,'XLabel'),'Visible','on');
	    end

	    if (ruleIndex>numRules) & (varIndex>numInputs),
    		%====================================
		% AGGREGATE MF PLOT
    		%====================================
		varName=getfis(fis,'output',varIndex-numInputs,'name');
	    	mfColIndex=sum(numOutputMFs(1:(varIndex-numInputs-1)))+1;
  		if mfColIndex<=size(xOut,2),
		    x=xOut(:,mfColIndex);
		else
		    x=zeros(size(arr,1),1);
		end
		compStr=computer;
		if compStr(1:2)=='PC',
		    eraseMode='normal';
  		else
		    eraseMode='background';
		end	
		xlabel(num2str(v(varIndex-numInputs),3), ...
		    'FontSize',10,'EraseMode',eraseMode);
		if strcmp(fisType,'mamdani'),
		    % MAMDANI
		    xMin=outRange(varIndex-numInputs,1);
		    xMax=outRange(varIndex-numInputs,2);
		    set(gca, ...
		    	'XLim',[xMin xMax],'YLim',[-0.1 1.1], ...
		    	'XTick',[xMin xMax], ...
			'FontSize',10, ...
		    	'XColor','w','YColor','w')
		    xData=[xMin; x; xMax];
		    yData=[0; arr(:,varIndex-numInputs); 0];
		    MFHndlMat(ruleIndex,varIndex)=patch( ...
		    	xData,yData,[0 0.8 0.8], ...
		    	'EraseMode','xor');
		    line(v(varIndex-numInputs)*[1 1],[-0.05 1.05], ...
		    	'Color','white', ...
	    	    	'MarkerSize',12, ...
	    	    	'LineWidth',3, ...
		    	'EraseMode','xor')
		else
		    % SUGENO system
		    set(gca, ...
			'XLim',outRange, ...
			'YLim',[-0.05 1.05], ...
			'XTick',outRange, ...
		    	'XColor','w','YColor','w')
		    lineHndl=line(v(varIndex-numInputs)*[1 1],[-0.05 1.05], ...
		    	'Color','white', ...
	    	    	'MarkerSize',15, ...
	    	    	'LineWidth',2, ...
		    	'EraseMode','normal');

		    xData=orr(:,varIndex-numInputs)';
		    xData=[xData; xData; NaN*ones(size(xData))];
		    yData=arr(:,varIndex-numInputs)';
		    yData=[zeros(size(yData)); yData; NaN*ones(size(yData))];

		    MFHndlMat(ruleIndex,varIndex)=line(xData(:),yData(:), ...
			'EraseMode','background', ...
			'LineWidth',4, ...
			'UserData',lineHndl, ...
			'Color','cyan');
		end
	    end
    	end
    end

    % The UserData will contain the varIndex to simplify 
    % calculations later on.
    set(inputDispHndl, ...
	'Value',inputVector, ...
	'String',[' ' fmat2str(inputVector,4)]);

    % Get handles to axes for plotting
    frameName='dataframe';
    dataFrmHndl=findobj(figNumber,'Type','uicontrol', ...
	'Style','frame','Tag',frameName);
    set(dataFrmHndl,'UserData',MFHndlMat);

    % Normalize all coordinates
    hndlList=findobj(figNumber,'Units','pixels');
    set(hndlList,'Units','normalized');
 
    set(inputDispHndl,'Enable','on');
    watchoff(figNumber)

elseif strcmp(action,'#clickline'),
    %====================================
    figNumber=gcf;
    set(figNumber,'WindowButtonMotionFcn','ruleview #dragline');
    set(figNumber,'WindowButtonUpFcn','ruleview #updateinputs');
    ruleview #dragline

elseif strcmp(action,'#dragline'),
    %====================================
    lineHndl=gco;
    axHndl=get(lineHndl,'Parent');
    textHndl=get(axHndl,'XLabel');
    figNumber=gcf;
    ptMat=get(axHndl,'CurrentPoint');
    x=ptMat(1,1);
    xLims=get(axHndl,'XLim');
    if (x < xLims(1)),
    	x=xLims(1);
    elseif (x > xLims(2)),
    	x=xLims(2);
    end
    set(lineHndl,'XData',[x x]);
    set(textHndl,'String',num2str(x(1),3));

% Uncomment the following lines if you want to see continuous update
% during a line drag
%    ruleview #updateinputs
%    set(figNumber,'WindowButtonMotionFcn','ruleview #dragline');
%    set(figNumber,'WindowButtonUpFcn','ruleview #updateinputs');

elseif strcmp(action,'#updateinputs'),
    %====================================
    figNumber=gcf;
    fis=get(figNumber,'UserData');
    numInputs=getfis(fis,'numinputs');
    numOutputs=getfis(fis,'numoutputs');

    if strcmp(get(gco,'Type'),'line'),
	% We're here because the moveable line indices have been moved
    	lineHndl=gco;
    	xData=get(lineHndl,'XData');
    	varIndex=get(lineHndl,'UserData');
    	inputDispHndl=findobj(figNumber,'Type','uicontrol','Tag','inputdisp');
    	inputVector=get(inputDispHndl,'Value');
  	inputVector(varIndex)=xData(1);
    	set(inputDispHndl,'Value',inputVector);
    	set(inputDispHndl,'String',[' ' fmat2str(inputVector,4)]);    
    else
	% We're here because the input vector text field has been changed
	inputDispHndl=gco;

	% Error-checking
	% The backupInputVector is the previous (or safety) value
	backupInputVector=get(inputDispHndl,'Value');
	% Use try-catch eval statement to keep out ASCII trash

    	newInputStr=get(inputDispHndl,'String');
    	% We'll put the brackets in later; no point in dealing with the hassle
    	index=[find(newInputStr=='[') find(newInputStr==']')];
    	newInputStr(index)=32*ones(size(index));
    	newInputStr=['[' newInputStr ']'];

    	% Use eval try-catch to prevent really weird stuff...
    	inputVector=eval(newInputStr,'backupInputVector');
        if length(inputVector)<numInputs,
	    inputVector=backupInputVector;
	else
	    inputVector=inputVector(1:numInputs);
	end

    	inRange=getfis(fis,'inRange');
	for count=1:numInputs,
	    % Find the appropriate index line
	    indexLineHndl=findobj(figNumber, ...
		'Type','line','Tag','indexline','UserData',count);
	    textHndl=get(get(indexLineHndl,'Parent'),'XLabel');
	    xLims=inRange(count,:);

	    % Check to make sure each input is within its limits
    	    if (inputVector(count) < xLims(1)),
		inputVector(count)=xLims(1);
            elseif (inputVector(count) > xLims(2)),
		inputVector(count)=xLims(2);
            end
    	    set(indexLineHndl,'XData',inputVector(count)*[1 1]);
	    set(textHndl,'String',num2str(inputVector(count),3));
	end

    	set(inputDispHndl,'Value',inputVector);
    	set(inputDispHndl,'String',[' ' fmat2str(inputVector,4)]);
    end
   
    % Get handles to axes for plotting
    frameName='dataframe';
    dataFrmHndl=findobj(figNumber,'Type','uicontrol', ...
	'Style','frame','Tag',frameName);
    MFHndlMat=get(dataFrmHndl,'UserData');

    % Remove the button motion and button up functions
    set(figNumber,'WindowButtonMotionFcn',' ');
    set(figNumber,'WindowButtonUpFcn',' ');

    [v,IRR,ORR,ARR]=evalfis(inputVector,fis);

    numRules=getfis(fis,'numRules');
    fisType=getfis(fis,'type');
    %====================================
    % Update INPUTS (we only need to update ONE of the inputs)
    for ruleIndex=1:numRules,
	for varIndex=1:numInputs,
	    % If the handle is zero, then the plot doesn't exist, so
	    % don't mess with anything
	    if MFHndlMat(ruleIndex,varIndex),
	    	axHndl=get(MFHndlMat(ruleIndex,varIndex),'Parent');
	    	lineHndl=findobj(axHndl,'Type','line');
	    	yData=get(lineHndl,'YData');
	    	yData=min(yData,IRR(ruleIndex,varIndex));
	    	yData=[0 yData 0];

	    	set(MFHndlMat(ruleIndex,varIndex), ...
	    	    'YData',yData);
	    end
	end
    end

    %====================================
    % Update OUTPUTS
    if strcmp(fisType,'mamdani'),
	% MAMDANI system
	% Update individual rule output displays (implication)
    	for ruleIndex=1:numRules
	    for varIndex=(1:numOutputs)+numInputs,
	    	yData=ORR(:,ruleIndex+(varIndex-numInputs-1)*numRules);
	    	yData=[0 yData' 0];
	    	lineHndl=MFHndlMat(ruleIndex,varIndex);
 		if lineHndl,
		    % Don't update it if it doesn't exist
		    set(lineHndl,'YData',yData);
		end
	    end
    	end

	% Update aggregate output display
    	for varIndex=(1:numOutputs)+numInputs,
	    patchHndl=MFHndlMat(numRules+1,varIndex);
	    axHndl=get(patchHndl,'Parent');
	    set(get(axHndl,'XLabel'),'String',num2str(v(varIndex-numInputs),3));
	    yData=ARR(:,varIndex-numInputs);
	    yData=[0 yData' 0];
	    set(patchHndl, ...
	    	'YData',yData);
 	    lineHndl=findobj(axHndl,'Type','line');
	    set(lineHndl,'XData',v(varIndex-numInputs)*[1 1]);
    	end
    else
	% SUGENO system
    	for ruleIndex=1:numRules
	    for varIndex=(1:numOutputs)+numInputs,
		thickLineHndl=MFHndlMat(ruleIndex,varIndex);
		% Don't update it if it doesn't exist
		if thickLineHndl,
		    thinLineHndl=get(MFHndlMat(ruleIndex,varIndex),'UserData');
		    xData2=[1 1]*ORR(ruleIndex,varIndex-numInputs);
		    set(thinLineHndl,'XData',xData2);
		    yData=[0 1]*ARR(ruleIndex,varIndex-numInputs);
	    	    set(MFHndlMat(ruleIndex,varIndex), ...
	    	    	'XData',xData2,'YData',yData);
		end
	    end
    	end

	% Update aggregate output display
    	for varIndex=(1:numOutputs)+numInputs,
	    xData=ORR(:,varIndex-numInputs)';
	    xData=[xData; xData; NaN*ones(size(xData))];
	    yData=ARR(:,varIndex-numInputs)';
	    yData=[zeros(size(yData)); yData; NaN*ones(size(yData))];

	    lineHndl1=MFHndlMat(numRules+1,varIndex);

	    axHndl=get(lineHndl1,'Parent');
	    set(get(axHndl,'XLabel'),'String',num2str(v(varIndex-numInputs),3));
	    set(lineHndl1, ...
	    	'XData',xData(:),'YData',yData(:));

	    % Now reposition the output index line
	    lineHndl2=get(lineHndl1,'UserData');
	    xData2=v(varIndex-numInputs)*[1 1];
	    set(lineHndl2,'XData',xData2);
    	end
    end

elseif strcmp(action,'#patchclick'),
    %====================================
    patchHndl=gco;
    figNumber=gcf;
    axHndl=get(patchHndl,'Parent');
    lineHndl=findobj(axHndl,'Type','line');
    set(figNumber,'CurrentObject',lineHndl);
    ruleview #clickline

elseif strcmp(action,'#input'),
    %====================================
    inputHndl=gco;
    figNumber=gcf;

elseif strcmp(action,'#disprule'),
    %====================================
    % Display the rule that the user has clicked on
    txtHndl=gco;
    figNumber=gcf;
    selectColor=[1 1 0];

    % Find and reset any previously highlighted rules
    oldTxtHndl=findobj(figNumber,'Type','text','Tag','rulelabel','FontSize',14);
    if length(oldTxtHndl)>0,
    	set(oldTxtHndl,'Color','white','FontSize',10,'FontWeight','normal');
    end
    set(txtHndl,'Color',selectColor,'FontSize',14,'FontWeight','bold');

    % Find out what display format is preferred
    formatHndl=findobj(figNumber,'Type','uimenu','Tag','dispformat');
    dispFormat=get(findobj(formatHndl,'Checked','on'),'Tag');
    fis=get(figNumber,'UserData');
    ruleIndexStr=get(txtHndl,'String');
    ruleIndex=str2num(ruleIndexStr);
    if strcmp(dispFormat,'indexed'),
	ruleStr=['Rule ' num2str(ruleIndex) '. ' showrule(fis,ruleIndex,'indexed')];
    else
    	ruleStr=['Rule ' showrule(fis,ruleIndex,dispFormat)];
    end
    % The next line is a hack to make sure that the "|" character will display
    % properly in a text uicontrol
    ruleStr=str2mat(ruleStr,' ');
    statmsg(figNumber,ruleStr);

elseif strcmp(action,'#dispformat');
    %====================================
    figNumber=watchon;
    currHndl=get(figNumber,'CurrentMenu');
    verHndl=findobj(figNumber,'Type','uimenu','Tag','verbose');
    symHndl=findobj(figNumber,'Type','uimenu','Tag','symbolic');
    indHndl=findobj(figNumber,'Type','uimenu','Tag','indexed');
    set([verHndl symHndl indHndl],'Checked','off');
    set(currHndl,'Checked','on');
    watchoff(figNumber)

elseif strcmp(action,'#help');
    figNumber=watchon;
    hthelp('ruleview.m');
    watchoff(figNumber)
       
end;    % if strcmp(action, ...
