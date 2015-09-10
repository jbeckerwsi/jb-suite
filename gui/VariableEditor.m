function varargout = VariableEditor(varargin)
% VARIABLEEDITOR MATLAB code for VariableEditor.fig
%      VARIABLEEDITOR, by itself, creates a new VARIABLEEDITOR or raises the existing
%      singleton*.
%
%      H = VARIABLEEDITOR returns the handle to a new VARIABLEEDITOR or the handle to
%      the existing singleton*.
%
%      VARIABLEEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VARIABLEEDITOR.M with the given input arguments.
%
%      VARIABLEEDITOR('Property','Value',...) creates a new VARIABLEEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VariableEditor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VariableEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VariableEditor

% Last Modified by GUIDE v2.5 10-Jun-2015 11:14:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @VariableEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @VariableEditor_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before VariableEditor is made visible.
function VariableEditor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VariableEditor (see VARARGIN)

% Choose default command line output for VariableEditor
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes VariableEditor wait for user response (see UIRESUME)
% uiwait(handles.figure1);
VariableEditor('menuitem_refresh_Callback',hObject,eventdata,guidata(hObject));


% --- Outputs from this function are returned to the command line.
function varargout = VariableEditor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function varName_Callback(hObject, eventdata, handles)
% hObject    handle to varName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of varName as text
%        str2double(get(hObject,'String')) returns contents of varName as a double
global Variables;
if ~isa(Variables,'MeasurementVariable')
    Variables=MeasurementVariable;
end
contents = get(hObject,'String');
Variables(handles.varID.Value).name=contents;
showDetails(handles.varID.Value,handles);

% --- Executes during object creation, after setting all properties.
function varName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to varName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on varName and none of its controls.
function varName_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to varName (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)




function varUnit_Callback(hObject, eventdata, handles)
% hObject    handle to varUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of varUnit as text
%        str2double(get(hObject,'String')) returns contents of varUnit as a double
global Variables;
contents = get(hObject,'String');
Variables(handles.varID.Value).unit=contents;
showDetails(handles.varID.Value,handles);

% --- Executes during object creation, after setting all properties.
function varUnit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to varUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in varType.
function varType_Callback(hObject, eventdata, handles)
% hObject    handle to varType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns varType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from varType
global Variables;
contents = cellstr(get(hObject,'String'));
Variables(handles.varID.Value).type=contents{get(hObject,'Value')};
showDetails(handles.varID.Value,handles);

% --- Executes during object creation, after setting all properties.
function varType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to varType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in varInstrument.
function varInstrument_Callback(hObject, eventdata, handles)
% hObject    handle to varInstrument (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns varInstrument contents as cell array
%        contents{get(hObject,'Value')} returns selected item from varInstrument
global Variables;
global R;

contents = cellstr(get(hObject,'String'));
Variables(handles.varID.Value).instrument=contents{get(hObject,'Value')};
Variables(handles.varID.Value).channel.id=1;
showDetails(handles.varID.Value,handles);

% --- Executes during object creation, after setting all properties.
function varInstrument_CreateFcn(hObject, eventdata, handles)
% hObject    handle to varInstrument (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in varChannel.
function varChannel_Callback(hObject, eventdata, handles)
% hObject    handle to varChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns varChannel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from varChannel
global Variables;
contents = cellstr(get(hObject,'String'));
Variables(handles.varID.Value).channel.id=get(hObject,'Value');
Variables(handles.varID.Value).channel.handle='';
Variables(handles.varID.Value).channel.string=contents{get(hObject,'Value')};
Variables(handles.varID.Value).instr_property=[];
showDetails(handles.varID.Value,handles);

% --- Executes during object creation, after setting all properties.
function varChannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to varChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in varInstr_property.
function varInstr_property_Callback(hObject, eventdata, handles)
% hObject    handle to varInstr_property (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns varInstr_property contents as cell array
%        contents{get(hObject,'Value')} returns selected item from varInstr_property
global Variables;
contents = cellstr(get(hObject,'String'));
Variables(handles.varID.Value).instr_property.id=get(hObject,'Value');
Variables(handles.varID.Value).instr_property.name='';
Variables(handles.varID.Value).instr_property.type='';
%Variables(handles.varID.Value).instr_property.string=contents{get(hObject,'Value')};

showDetails(handles.varID.Value,handles);

% --- Executes during object creation, after setting all properties.
function varInstr_property_CreateFcn(hObject, eventdata, handles)
% hObject    handle to varInstr_property (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when entered data in editable cell(s) in varTable.
function varTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to varTable (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

%column-numbers
col.variable     =1;
col.io           =2;
col.instrument   =3;
col.group        =4;
col.function     =5;
col.transfer     =6;
col.value        =7;
col.unit         =8;

eventdata


% --- Executes when selected cell(s) is changed in varTable.
function varTable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to varTable (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
if numel(eventdata.Indices) ~=2
    return
end
row=eventdata.Indices(1);
showDetails(row,handles,0);


function showDetails(row,handles,refreshTable)
if nargin < 3
    refreshTable=1; %this is to prevent recursion, as refreshtable also will call this method
end

%load details
global Variables;

if row > numel(Variables)
    handles.varType.Value=1;
    handles.varName.String='';
    handles.varUnit.String='';
    handles.varID.Value=numel(Variables)+1;
else
    v=Variables(row);
    if strcmp(v.type,'input')
        handles.varType.Value=1;
    else
        handles.varType.Value=2;
    end
    handles.varUnit.String=v.unit;
    
    handles.varName.String=v.name;
    handles.varID.Value=row;
end
handles.varChannel.String={'main'};
handles.varChannel.Value=1;
handles.varInstr_property.Value=1;
handles.varInstr_property.String={''};
handles.varInstrument.String={''};
handles.varInstrument.Value=1;

if row > numel(Variables)
    return;
end

global R;
handles.varInstrument.String=R.devices;
if ~isempty(v.instrument) && any(ismember(R.devices,v.instrument))
    handles.varInstrument.Value=find(ismember(R.devices,v.instrument));
    d=R.(v.instrument);
    
    %find groups in instrument-driver with >1 instances, this will likely
    %be channels, also add 'main'-channel, pointing to root
    %to keep track save group-handles and displayed string seperately
    %(saves some regex-voodoo)
    groupList={'main'};
    groupHandles={d};
    props=fieldnames(d); % list of properties
    for k=1:numel(props)
        if isa(d.(props{k}),'icgroup')
            n=size(d.(props{k}),2);
            if n > 1
                for i=1:n
                    groupList{end+1}=sprintf('%s(%1.0f)',props{k},i);
                    groupHandles{end+1}=d.(props{k})(i);
                end
            end
        end
    end
    handles.varChannel.String=groupList;
        
    %            
    if ~isempty(v.channel) && isfield(v.channel,'id') %setting the handles and strings here requires the method to be executed once for every channel, but it makes the rest easier
        handles.varChannel.Value=v.channel.id;
        g=groupHandles{v.channel.id};
        v.channel.handle=g;
        v.channel.string=groupList{v.channel.id};
        
        doNotShow={'HwIndex','HwName','Name','Parent','Type','ConfirmationFcn','DriverName','DriverType','InstrumentModel','Interface','LogicalName',...
                    'ObjectVisibility','RsrcName','Status','Tag','Timeout','UserData'};
        usableProperties={};
        propertyTypes={};
        p=setdiff(fieldnames(v.channel.handle),doNotShow);
        for i=1:numel(p)
            if ~isa(g.(p{i}),'icgroup')
                usableProperties{end+1}=p{i};
                propertyTypes{end+1}='prop';
            end
        end
        
        defaultMethods={    'class','connect','ctranspose','delete','devicereset','disconnect','disp','display','end','eq','fieldnames','get','geterror','horzcat',...
                            'icdevice','inspect','instrcallback','instrfind','instrfindall','instrhelp','instrhwinfo','instrnotify','instrument',...
                            'invoke','isa','isequal','isvalid','length','methods','ne','obj2mfile','openvar','propinfo','selftest','set',...
                            'size','subsasgn','subsref','vertcat','icgroup'};
        methodList=setdiff(methods(v.channel.handle),defaultMethods);
        
        for k=1:numel(methodList)
            usableProperties{end+1}=methodList{k};
            propertyTypes{end+1}='method';
        end
        usablePropertiesString={};
        for k=1:numel(usableProperties)
            if strcmp(propertyTypes{k},'method')
                mp='m';
            else
                mp='p';
            end
            usablePropertiesString{k}=sprintf('(%s) %s',mp,usableProperties{k});
        end
        
        if ~exist('usablePropertiesString','var') || isempty(usablePropertiesString) ||isempty(usableProperties)
            usablePropertiesString={'(none)'};
            usableProperties={''};
            propertyTypes={''};
            v.instr_property.id=1;
        end
        handles.varInstr_property.String=usablePropertiesString;
        
        if ~isempty(v.instr_property)
            handles.varInstr_property.Value=v.instr_property.id;
            v.instr_property.name=usableProperties{v.instr_property.id};
            v.instr_property.type=propertyTypes{v.instr_property.id};
        end
        
    else %if ~isempty(v.channel)
        handles.varChannel.Value=1;
        v.channel.id=1;
        v.channel.handle='';
        v.channel.string='';
    end
else %if ~isempty(v.instrument)
    handles.varInstrument.Value=1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%% TRANSFERS %%%%%%%%%%%%%%%%%%%%%%%%%%
transfers=VariableEditor('scanRackForTransfers',R);
for i=1:numel(transfers)
    strings{i}=transfers(i).string;
end

handles.varTransfers.ColumnFormat{1}=strings;

handles.varTransfers.Data={'',''};
for i=1:numel(v.transferChain)
    handles.varTransfers.Data{i,1}=v.transferChain(i).string;
    %rebuild handles
    tID=find(ismember(strings,v.transferChain(i).string));
    v.transferChain(i)=transfers(tID);
end
if isempty(i)
    i=0;
end
handles.varTransfers.Data{i+1,1}='(none)';
handles.varTransfers.UserData=transfers;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if refreshTable==1
    VariableEditor('menuitem_refresh_Callback',handles,NaN,handles);
end


function transfer=scanRackForTransfers(R)

for i=1:numel(R.devices)
    d=R.(R.devices{i});
    
    %find groups in instrument-driver with >1 instances, this will likely
    %be channels, also add 'main'-channel, pointing to root
    %to keep track save group-handles and displayed string seperately
    %(saves some regex-voodoo)
    if i==1
        List={sprintf('%s/main',R.devices{i})};
        Handles={d};
    else
        List{end+1}=sprintf('%s/main',R.devices{i});
        Handles{end+1}=d;
    end
    props=fieldnames(d); % list of properties
    for k=1:numel(props)
        if isa(d.(props{k}),'icgroup')
            n=size(d.(props{k}),2);
            if n > 1
                for i=1:n
                    List{end+1}=sprintf('%s/%s(%1.0f)',R.devices{i},props{k},i);
                    Handles{end+1}=d.(props{k})(i);
                end
            end
        end
    end
end

transfer.string='(none)';
transfer.handle=NaN;
transfer.method='';

for i=1:numel(Handles)
    M=methods(Handles{i});
    ids=find(~cellfun(@isempty,regexp(M,regexptranslate('wildcard','transfer*'))));
    for k=ids'
        transfer(end+1).handle=Handles{i};
        transfer(end).method=M{k};
        transfer(end).string=sprintf('%s/%s',List{i},M{k});
    end
end



% --- Executes during object creation, after setting all properties.
function varTable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to varTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function varID_Callback(hObject, eventdata, handles)
% hObject    handle to varID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of varID as text
%        str2double(get(hObject,'String')) returns contents of varID as a double


% --- Executes during object creation, after setting all properties.
function varID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to varID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menuitem_refresh_Callback(hObject, eventdata, handles)
% hObject    handle to menuitem_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%column-numbers
col.variable     =1;
col.io           =2;
col.instrument   =3;
col.channel      =4;
col.function     =5;
col.transfer     =6;
col.value        =7;
col.unit         =8;
global Variables;
if ~isa(Variables,'MeasurementVariable')
    return;
end
handles.varTable.Data={'','','','','','','',''};
lastSelection=handles.varID.Value;
for i=1:numel(Variables)
    showDetails(i,handles,0);
    handles.varTable.Data{i,col.variable}    =Variables(i).name;
    handles.varTable.Data{i,col.io}          =Variables(i).type;
    handles.varTable.Data{i,col.instrument}  =Variables(i).instrument;
    if ~isempty(Variables(i).channel) && isfield(Variables(i).channel,'string')
        handles.varTable.Data{i,col.channel} =Variables(i).channel.string;
    end
    if ~isempty(Variables(i).instr_property) && isfield(Variables(i).instr_property,'name')
        if strcmp(Variables(i).instr_property.type,'method')
                mp='m';
            else
                mp='p';
        end 
        handles.varTable.Data{i,col.function}=sprintf('(%s) %s',mp,Variables(i).instr_property.name);
    end
    handles.varTable.Data{i,col.unit}  =Variables(i).unit;
    
    if numel(Variables(i).lastValue) > 1
        lastValue=Variables(i).lastValue(1);
    else
        lastValue=Variables(i).lastValue;
    end
    handles.varTable.Data{i,col.value}=lastValue;
end
handles.varTable.Data{i+1,col.variable}='';
if ~isempty(lastSelection) && lastSelection~=0
    showDetails(lastSelection,handles,0);
end


% --------------------------------------------------------------------
function menuitem_saveas_Callback(hObject, eventdata, handles)
% hObject    handle to menuitem_saveas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in button_readAll.
function button_readAll_Callback(hObject, eventdata, handles)
% hObject    handle to button_readAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VariableEditor('menuitem_readAll_Callback',handles,NaN,handles);


% --------------------------------------------------------------------
function menuitem_readAll_Callback(hObject, eventdata, handles)
% hObject    handle to menuitem_readAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Variables;

Variables.read; %read sets the field Variables(n).lastValue
VariableEditor('menuitem_refresh_Callback',handles,NaN,handles);


% --- Executes when entered data in editable cell(s) in varTransfers.
function varTransfers_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to varTransfers (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
row=eventdata.Indices(1);

global Variables;

id=handles.varID.Value;
if isempty(id)
    return
end

transfers=handles.varTransfers.UserData;
Variables(id).transferChain(row)=transfers(find(ismember(handles.varTransfers.ColumnFormat{1},eventdata.NewData)));
keepIDs=[];
for i=1:numel(Variables(id).transferChain)
    if ~strcmp(Variables(id).transferChain(i).string,'(none)')
        keepIDs(end+1)=i;
    end
end

if isempty(keepIDs)
    Variables(id).transferChain=struct('string',{},'handle',{},'method',{});
else
    Variables(id).transferChain=Variables(id).transferChain(keepIDs);
end
showDetails(id,handles);
