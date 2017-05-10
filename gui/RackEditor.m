function varargout = RackEditor(varargin)
% RACKEDITOR MATLAB code for RackEditor.fig
%      RACKEDITOR, by itself, creates a new RACKEDITOR or raises the existing
%      singleton*.
%
%      H = RACKEDITOR returns the handle to a new RACKEDITOR or the handle to
%      the existing singleton*.
%
%      RACKEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RACKEDITOR.M with the given input arguments.
%
%      RACKEDITOR('Property','Value',...) creates a new RACKEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before instrument_editor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to instrument_editor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RackEditor

% Last Modified by GUIDE v2.5 25-Jan-2017 18:28:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RackEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @RackEditor_OutputFcn, ...
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
drawnow; % to make the profiler happy
% End initialization code - DO NOT EDIT


% --- Executes just before instrument_editor is made visible.
function RackEditor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to instrument_editor (see VARARGIN)

% Choose default command line output for instrument_editor
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes instrument_editor wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%add filename to title
global R;
if isa(R,'Rack')
    if ~isempty(R.filename)
        [~,filename,ext]=fileparts(R.filename);
        hObject.Name=sprintf('%s - %s%s',hObject.Name,filename,ext);
    end
end

% --- Outputs from this function are returned to the command line.
function varargout = RackEditor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function menuitem_saveas_Callback(hObject, eventdata, handles)
% hObject    handle to menuitem_saveas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf('save as...\n');
[filename, pathname] = uiputfile({'*.instr','Instrument List (*.instr)'},'Save as...');
data=handles.instrument_table.Data;
save(sprintf('%s/%s',pathname,filename),'data');


% --------------------------------------------------------------------
function menuitem_load_Callback(hObject, eventdata, handles)
% hObject    handle to menuitem_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf('load\n');
[filename, pathname] = uigetfile({'*.instr','Instrument List (*.instr)';'*.*','*.*'},'Open');
load(sprintf('%s/%s',pathname,filename),'-mat');
handles.instrument_table.Data=data;
global R;
R.filename=sprintf('%s/%s',pathname,filename);
%RackEditor('menuitem_apply_Callback',hObject,eventdata,guidata(hObject));



% --------------------------------------------------------------------
function menuitem_quit_Callback(hObject, eventdata, handles)
% hObject    handle to menuitem_quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure1_CloseRequestFcn(hObject.Parent.Parent,eventdata,handles);



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf('bye\n');
% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on selection change in instrument_list.
function instrument_list_Callback(hObject, eventdata, handles)
% hObject    handle to instrument_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global R;
if ~isa(R,'Rack')
    R=Rack(handles.select_visa_vendor.Text{handlex.select_visa_vendor.value});
end
hObject.String=R.devices;
hObject.String{end+1}='.....(create new)';
if hObject.Value > numel(hObject.String)
    hObject.Value=1;
end
% Hints: contents = cellstr(get(hObject,'String')) returns instrument_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from instrument_list


% --- Executes during object creation, after setting all properties.
function instrument_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to instrument_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
instrument_list_Callback(hObject, eventdata, handles);



% --- Executes on selection change in select_visa_vendor.
function select_visa_vendor_Callback(hObject, eventdata, handles)
% hObject    handle to select_visa_vendor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns select_visa_vendor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from select_visa_vendor


% --- Executes during object creation, after setting all properties.
function select_visa_vendor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_visa_vendor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% FIXME
% the automated detection seems to be borked up on the lab-pc, takes 4
% minutes ... (on other pc, however it works fine)
    %visaInfo=instrhwinfo('visa');
    %availableVisa=visaInfo.InstalledAdaptors;
    %availableVisa{end+1}='dummy';
availableVisa={'ni','agilent','tek','dummy'};
hObject.String=availableVisa;
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function instrument_table_CreateFcn(hObject, eventdata, handles)
% hObject    handle to instrument_table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
l=instrhwinfo('matlab');
hObject.ColumnFormat{3}=sort(l.InstalledDrivers); %set possible values of column 3 to list of available device drivers
menuitem_refresh_Callback(hObject, eventdata, guihandles(hObject));    
%RackEditor('menuitem_refresh_Callback',hObject,eventdata,guidata(hObject))


% --- Executes on button press in connect_all.
function connect_all_Callback(hObject, eventdata, handles)
% hObject    handle to connect_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuitem_connect_all_Callback(hObject, eventdata, handles);


% --- Executes on button press in apply.
function apply_Callback(hObject, eventdata, handles)
% hObject    handle to apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuitem_apply_Callback(hObject, eventdata, handles);

% --- Executes on button press in refresh.
function refresh_Callback(hObject, eventdata, handles)
% hObject    handle to refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuitem_refresh_Callback(hObject,eventdata,handles);

% --------------------------------------------------------------------
function menuitem_refresh_Callback(hObject, eventdata, handles)
fprintf('refresh\n');
% hObject    handle to menuitem_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global R;
if ~isa(R,'Rack')
    R=Rack(handles.select_visa_vendor.String{handles.select_visa_vendor.Value});
end
%handles=hObject.Parent.Children;
tab=handles.instrument_table;
tab.Data={'','',NaN,'',0};

for i=1:numel(R.devices)
    d=R.(R.devices{i});
    tab.Data{i,1}=R.devices{i};
    if ~strcmp(d.DriverType,'MATLAB generic')
        tab.Data{i,2}=d.Interface.RsrcName;
    else
        tab.Data{i,2}='generic';
    end
    tab.Data{i,3}=d.DriverName(1:end-4);
    tab.Data{i,4}=d.Type;
    tab.Data{i,5}=strcmp('open',d.Status);
end
if numel(R.devices)==0
    i=0;
end

tab.Data{i+1,1}='';
tab.Data{i+1,2}='';
tab.Data{i+1,3}='';
tab.Data{i+1,4}='';
tab.Data{i+1,5}=0;
    
% --------------------------------------------------------------------
function menuitem_apply_Callback(hObject, eventdata, handles)
fprintf('apply\n');
% hObject    handle to menuitem_apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=handles.instrument_table.Data;
RackEditor('menuitem_disconnect_all_Callback',hObject,eventdata,guidata(hObject));

%create new Rack from table-data
global R;
instrreset;
fprintf('new\n');
R=Rack(handles.select_visa_vendor.String{handles.select_visa_vendor.Value});
[rows, ~]=size(data);
for i=1:rows-1
    if ~isempty(data{i,2}) && ~isempty(str2num(data{i,2}))
        interf=sprintf('GPIB0::%1.0f::0::INSTR',str2num(data{i,2}));
    else
        interf=data{i,2};
    end
    %fprintf('%s.mdd\n',data{i,3})
    R.add(data{i,1},interf,sprintf('%s.mdd',data{i,3}));
end
RackEditor('menuitem_refresh_Callback',hObject,eventdata,guidata(hObject));



% --------------------------------------------------------------------
function menuitem_connect_all_Callback(hObject, eventdata, handles)
fprintf('connect all\n');
% hObject    handle to menuitem_connect_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global R;
for i=1:numel(R.devices)
    if strcmp(R.(R.devices{i}).status,'closed')
        connect(R.(R.devices{i}));
        RackEditor('menuitem_refresh_Callback',hObject,eventdata,guidata(hObject));
    end
end



% --------------------------------------------------------------------
function menuitem_disconnect_all_Callback(hObject, eventdata, handles)
fprintf('disconnect all\n');
% hObject    handle to menuitem_disconnect_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global R;
for i=1:numel(R.devices)
    if strcmp(R.(R.devices{i}).status,'open')
        disconnect(R.(R.devices{i}));
        RackEditor('menuitem_refresh_Callback',hObject,eventdata,guidata(hObject));
    end
end

% --- Executes when entered data in editable cell(s) in instrument_table.
function instrument_table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to instrument_table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
changedCol=eventdata.Indices(2);
changedRow=eventdata.Indices(1);
global R;
if changedCol==5 % connect/disconnect
    if eventdata.NewData==0
        h=msgbox(sprintf('disconnecting %s ...',hObject.Data{changedRow,1}),'Please wait...','modal');
        disconnect(R.(hObject.Data{changedRow,1}));
        close(h);
    elseif eventdata.NewData==1
        h=msgbox(sprintf('connecting %s ...',hObject.Data{changedRow,1}),'Please wait...','modal');
        connect(R.(hObject.Data{changedRow,1}));
        close(h);
    end
else
    if hObject.Data{changedRow,5}==1 %if instrument is connected prevent any data change in table
       hObject.Data{changedRow,changedCol}=eventdata.PreviousData;
    end
end

%prevent duplicate names
if changedCol==1
    if isempty(eventdata.NewData)
        choice=questdlg(sprintf('Delete instrument %s?',eventdata.PreviousData),'Confirm delete','yes','no','no');
        switch choice
            case 'yes'
                hObject.Data(changedRow,:)=[];
            case 'no'
                hObject.Data{changedRow,changedCol}=eventdata.PreviousData;
        end               
    elseif ismember(eventdata.NewData,hObject.Data(~([1:size(hObject.Data,1)]==changedRow),1))
        errordlg('names must be unique!');
        hObject.Data{changedRow,changedCol}=eventdata.PreviousData;
    else
        if changedRow==size(hObject.Data,1) && changedCol==1 %% entered name in last row last row: add new row
            hObject.Data{changedRow+1,1}='';
        end
    end
end    
        


% --------------------------------------------------------------------
function menuitem_save_Callback(hObject, eventdata, handles)
% hObject    handle to menuitem_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf('save\n');


% --------------------------------------------------------------------
function menuitem_what_is_Callback(hObject, eventdata, handles)
% hObject    handle to menuitem_what_is (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox('This tool is used to edit the virtual instrument rack','What is this?');

% --------------------------------------------------------------------
function menuitem_about_Callback(hObject, eventdata, handles)
% hObject    handle to menuitem_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox('RackEditor, Jonathan Becker 2015 <jonathan.becker@wsi.tum.de>','About');


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over refresh.
function refresh_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
