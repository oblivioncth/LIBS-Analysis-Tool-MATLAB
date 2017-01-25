function varargout = lasergui(varargin)
% LASERGUI MATLAB code for lasergui.fig
%      LASERGUI, by itself, creates a new LASERGUI or raises the existing
%      singleton*.
%
%      H = LASERGUI returns the handle to a new LASERGUI or the handle to
%      the existing singleton*.
%
%      LASERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LASERGUI.M with the given input arguments.
%
%      LASERGUI('Property','Value',...) creates a new LASERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before lasergui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to lasergui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help lasergui

% Last Modified by GUIDE v2.5 04-Dec-2015 12:17:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @lasergui_OpeningFcn, ...
                   'gui_OutputFcn',  @lasergui_OutputFcn, ...
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


% --- Executes just before lasergui is made visible.
function lasergui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to lasergui (see VARARGIN)

%Check for existance of settings.txt and if not create it
remakeSettings = 0;
DocFolder = [getenv('userprofile') '\Documents'];
SettingsFolder = check_create_dir('Rowan Technology\Laser Analysis Tool',DocFolder,3);
if(~exist([SettingsFolder '\settings.txt']))
    waitfor(msgbox('No configuration found. It has either been deleted or this is the first time the program is being run. Press OK to create a configuration.','Setup'));
    remakeSettings = 1;
else
    try
        fID = fopen([SettingsFolder '\settings.txt']);
        settingsSaveDir = textscan(fID,'%s',1,'delimiter','\n','headerlines',5);
        settingsSaveDir = settingsSaveDir{1}{1}(12:end);
        if(~strcmp(settingsSaveDir(2:3),':\'))
            waitfor(msgbox('Could not load settings from configuration. Press OK to remake configuration','Setup'));
            remakeSettings = 1; 
        end
    catch
        waitfor(msgbox('Could not load settings from configuration. Press OK to remake configuration','Setup'));
        remakeSettings = 1;
    end
end
if(remakeSettings == 1)
   settingsSaveDir = create_config(SettingsFolder,0);
end
handles.SettingsFolder = SettingsFolder;
handles.settingsSaveDir = settingsSaveDir;
guidata(hObject, handles)

%Load NJ DOT logo and add to GUI
DOT = imread('njdot.png','BackgroundColor',[.941,.941,.941]);
axes(handles.axes1);
imshow(DOT);

% Disable PLS Model and Testing Data edit box on startup
set(handles.testingdataEdit, 'Enable', 'off');
set(handles.plsmodelEdit, 'Enable', 'off');

% Set Calibration Set edit box to inactive on startup
set(handles.calibrationsetEdit,'Enable','inactive')

% Disable Manual PLS edit boxes on startup
set(handles.ncompBaseEdit, 'Enable', 'off');
set(handles.ncompTrapEdit, 'Enable', 'off');
set(handles.ncompCarbEdit, 'Enable', 'off');
set(handles.ncompNoncEdit, 'Enable', 'off');

% Disable Custom Threshold edit boxes on startup
set(handles.customCarbThresh, 'Enable', 'off');
set(handles.customNCarbThresh, 'Enable', 'off');

%Disable Custom Threshold radio buttons on startup
set(handles.defaultButton, 'Enable', 'off');
set(handles.customButton, 'Enable', 'off');


% Disable Run button on startup
set(handles.OKbutton,'Enable','off')

% Choose default command line output for lasergui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes lasergui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = lasergui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in OKbutton.
function OKbutton_Callback(hObject, eventdata, handles)
% hObject    handle to OKbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

newMode = get(handles.OperatingMode, 'SelectedObject');
newMode = get(newMode, 'Tag');
if (strcmp(newMode, 'trainingButton'))
    newMode = 'train';
end
if (strcmp(newMode, 'testingButton'))
    newMode = 'test';
end
if (strcmp(newMode, 'testingsetButton'))
    newMode = 'testset';
end


thresh_mode = get(handles.CustomThresholds, 'SelectedObject');
thresh_mode = get(thresh_mode, 'Tag');
if (strcmp(thresh_mode, 'defaultButton'))
    custom_thresh = [-1 -1];
end
if (strcmp(thresh_mode, 'customButton'))
    custom_thresh = [str2double(get(handles.customCarbThresh, 'String')) str2double(get(handles.customNCarbThresh, 'String'))];
end

ncomp_mode = get(handles.ncompGroup, 'SelectedObject');
ncomp_mode = get(ncomp_mode, 'Tag');
if (strcmp(ncomp_mode, 'ncompAutoButton'))
    ncomp_base = 0;
    ncomp_trap = 0;
    ncomp_carb = 0;
    ncomp_nonc = 0;
end
if (strcmp(ncomp_mode, 'ncompManualButton'))
    ncomp_base = str2double(get(handles.ncompBaseEdit, 'String'));
    ncomp_carb = str2double(get(handles.ncompCarbEdit, 'String'));
    ncomp_nonc = str2double(get(handles.ncompNoncEdit, 'String'));
    ncomp_trap = str2double(get(handles.ncompTrapEdit, 'String'));
end

ncomp = struct('Base', ncomp_base, 'Carbonate', ncomp_carb, 'NonCarbonate', ncomp_nonc, 'Trap', ncomp_trap);
    switch newMode
        case 'train';
                TStamp = time_stamp();
                close;
                laseranalysis(handles.CalibrationData, 'NULL', ncomp, newMode, custom_thresh,'NULL',handles.settingsSaveDir, TStamp);
        case 'test';
     handles.plsdata
                TStamp = time_stamp();
                rock_data = text_to_matlab(handles.txt2mdir,1,handles.settingsSaveDir,TStamp);
                close;
                laseranalysis(rock_data, handles.plsdata, ncomp, newMode, custom_thresh, handles.resultsFigName, handles.settingsSaveDir,TStamp);
        case 'testset';
                TStamp = time_stamp();
                rock_data = text_to_matlab(handles.txt2mdir,2,handles.settingsSaveDir,TStamp);
                close;
                laseranalysis(rock_data, handles.plsdata, ncomp, newMode, custom_thresh, handles.resultsFigName, handles.settingsSaveDir,TStamp);
        
    end
try 
    size = round(directory_size(check_create_dir('LAT Results',handles.settingsSaveDir,3))/1048576);
    if(size >= 200)
        size = num2str(size);
        warndlg(['The current total size of the results directory is ' size 'MB. Consider archeiving or deleting old Testing and Training results to prevent too much disk space from being used'],'Warning!')
    end
catch
    warndlg('Current size of the results directory could not be determined. Make sure to archeive or delete old Testing and Training results, and PLS models periodically to prevent too much disk space from being used','Warning!')
end


function calibrationsetEdit_Callback(hObject, eventdata, handles)
% hObject    handle to calibrationsetEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of calibrationsetEdit as text
%        str2double(get(hObject,'String')) returns contents of calibrationsetEdit as a double


% --- Executes during object creation, after setting all properties.
function calibrationsetEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to calibrationsetEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in selectfilesButton.
function selectfilesButton_Callback(hObject, eventdata, handles)
% hObject    handle to selectfilesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

newMode = get(handles.OperatingMode, 'SelectedObject');
newMode = get(newMode, 'Tag');
if (strcmp(newMode, 'trainingButton'))
    BadCal = 0;
    [Xloc,XlocPath] = uigetfile('.', 'Select the calibration set .mat file to be used for PLS model creation.');
    if (Xloc == 0)
        clearvars Xloc
    else
        try                        %Checks if file is a .mat file
            XlocLabel = Xloc;
            Xloc = [XlocPath Xloc];
            load(Xloc)
        catch
            BadCal = 1;
        end
        if(BadCal ~= 1)
            if (exist('rock_data','var'))     %Checks if .mat file is Calibration data
                handles.CalibrationData = Xloc;
                guidata(hObject, handles)
                clearvars rock_data
                set(handles.calibrationsetEdit,'String',XlocLabel)
                set(handles.testingdataEdit,'String','N/A')
                set(handles.plsmodelEdit,'String','N/A')
                set(handles.OKbutton,'Enable','on')
            else
                BadCal = 1;
            end
        end
        if(BadCal == 1)
            clearvars Xloc XlocLabel
            msgbox('The selected file is either corrupt or not a valid calibration set!','Error','error') 
        end
    end
end
if (strcmp(newMode, 'testingButton'))
    BadTst = 0;
    BadPLS = 0;
    singlefolder = uigetdir('.', 'Select the folder that contains the testing data text files');
    if(singlefolder == 0)
            clearvars singlefolder;   
    else
        handles.txt2mdir = singlefolder;
        guidata(hObject, handles)
        [~,folderdisp] = fileparts(singlefolder);
        LastFile = extractfield(dir(singlefolder),'name');
%         LastFile = char(LastFile(end));
%         try
%             TScheck = textscan(fopen(LastFile), '%s', 1, 'delimiter', '\n', 'headerlines', 0); %Reads first line of text 
%             TScheck = char(TScheck{1});
%         catch
%             BadTst = 1;
%         end
        hastxt=0;
        for i=1:numel(LastFile)
            if strfind(LastFile{i},'.txt')
                hastxt=1;
                break
            end
        end
        if(hastxt)
                [PLSloc,PLSlocPath] = uigetfile('.', 'Select the PLS model .mat file to use.');     
                if (PLSloc == 0)
                    clearvars PLSloc singlefolder
                else
                    try                        %Checks if file is a .mat file
                        PLSlocLabel = PLSloc;
                        PLSloc = [PLSlocPath PLSloc];
                        load(PLSloc)
                    catch
                        BadPLS = 1;
                    end
                    if(BadPLS ~= 1)
                        if (exist('PLS_Model_All','var'))     %Checks if .mat file is Calibration data
                            handles.plsdata = PLSloc;
                            guidata(hObject, handles)
                            clearvars PLS_Model_All
                            set(handles.testingdataEdit,'String',folderdisp)
                            handles.resultsFigName = folderdisp;
                            guidata(hObject, handles)
                            set(handles.plsmodelEdit,'String',PLSlocLabel)
                            set(handles.calibrationsetEdit,'String','N/A')
                            set(handles.OKbutton,'Enable','on')
                        else
                            BadPLS = 1;
                        end
                    end
                end
        else
             BadTst =1;
        end
        if(BadPLS == 1)
            clearvars PLSloc singlefolder PLSlocLabel
            msgbox('The selected file is either corrupt or not a valid PLS-Model!','Error','error') 
        end
        if(BadTst == 1)
            clearvars singlefolder
            msgbox('The selected folder contains either no testing data or corrupt files!','Error','error')
        end
    end
end
if (strcmp(newMode, 'testingsetButton'))
    BadSet = 0;
    BadPLS = 0;
    setfolder = uigetdir('.', 'Select the testing set folder that contains multiple testing data folders');
    if(setfolder == 0)
        clearvars setfolder;
    else
        handles.txt2mdir = setfolder;
        guidata(hObject, handles)
        [~,folderdisp] = fileparts(setfolder);
        LastFile = extractfield(dir(setfolder),'name');
        LastFile = extractfield(dir([setfolder '\' char(LastFile(end))]),'name');
%         LastFile = char(LastFile(end));
%         try
%             TScheck = textscan(fopen(LastFile), '%s', 1, 'delimiter', '\n', 'headerlines', 0); %Reads first line of text 
%             TScheck = char(TScheck{1});
%         catch
%             BadSet = 1;
%         end
%         if(BadSet ~= 1)
        hastxt=0;
        for i=1:numel(LastFile)
            if strfind(LastFile{i},'.txt')
                hastxt=1;
                break
            end
        end
            if(hastxt)
                [PLSloc,PLSlocPath] = uigetfile('.', 'Select the PLS model .mat file to use.');     
                if (PLSloc == 0)
                    clearvars PLSloc singlefolder
                else
                    try                        %Checks if file is a .mat file
                        PLSlocLabel = PLSloc;
                        PLSloc = [PLSlocPath PLSloc];
                        load(PLSloc)
                    catch
                        BadPLS = 1;
                    end
                    if(BadPLS ~= 1)
                        if (exist('PLS_Model_All','var'))     %Checks if .mat file is Calibration data
                            handles.plsdata = PLSloc;
                            guidata(hObject, handles)
                            clearvars PLS_Model_All
                            set(handles.testingdataEdit,'String',folderdisp)
                            handles.resultsFigName = folderdisp;
                            guidata(hObject, handles)
                            set(handles.plsmodelEdit,'String',PLSlocLabel)
                            set(handles.calibrationsetEdit,'String','N/A')
                            set(handles.OKbutton,'Enable','on')
                        else
                            BadPLS = 1;
                        end
                    end
                end
            else
                BadSet = 1;
            end
        %end
        if(BadPLS == 1)
            clearvars PLSloc setfolder
            msgbox('The selected file is either corrupt or not a valid PLS-Model!','Error','error')
        end
        if(BadSet == 1)
            clearvars setfolder
            msgbox('The selected folder contains either no testing data folders or corrupt files!','Error','error')
        end
    end
end




% --- Executes during object creation, after setting all properties.
function OperatingMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OperatingMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when selected object is changed in OperatingMode.
function OperatingMode_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in OperatingMode 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue, 'Tag')
    case 'trainingButton'
        set(handles.calibrationsetEdit, 'Enable', 'inactive');
        set(handles.testingdataEdit, 'Enable', 'off');
        set(handles.plsmodelEdit, 'Enable', 'off');
        set(handles.calibrationsetEdit,'String','')
        set(handles.testingdataEdit,'String','')
        set(handles.plsmodelEdit,'String','')
        set(handles.plsmodelEdit,'String','')
        set(handles.OKbutton,'Enable','off')
        set(handles.defaultButton, 'Enable', 'off');
        set(handles.customButton, 'Enable', 'off');
        set(handles.customCarbThresh, 'Enable', 'off');
        set(handles.customCarbThresh, 'String', '');
        set(handles.customNCarbThresh, 'Enable', 'off');
        set(handles.customNCarbThresh, 'String', '');
        set(handles.defaultButton, 'Value', 1);
        set(handles.ncompAutoButton, 'Value', 1);
        set(handles.ncompAutoButton, 'Enable', 'on');
        set(handles.ncompManualButton, 'Enable', 'on');
        set(handles.ncompBaseEdit, 'Enable', 'off');
        set(handles.ncompTrapEdit, 'Enable', 'off');
        set(handles.ncompCarbEdit, 'Enable', 'off');
        set(handles.ncompNoncEdit, 'Enable', 'off');
        set(handles.ncompBaseEdit, 'String', '');
        set(handles.ncompTrapEdit, 'String', '');
        set(handles.ncompCarbEdit, 'String', '');
        set(handles.ncompNoncEdit, 'String', '');
    case 'testingButton'
        set(handles.calibrationsetEdit, 'Enable', 'off');
        set(handles.testingdataEdit, 'Enable', 'inactive');
        set(handles.plsmodelEdit, 'Enable', 'inactive');
        set(handles.calibrationsetEdit,'String','')
        set(handles.testingdataEdit,'String','')
        set(handles.plsmodelEdit,'String','')
        set(handles.OKbutton,'Enable','off')
        set(handles.defaultButton, 'Enable', 'on');
        set(handles.ncompAutoButton, 'Enable', 'off');
        set(handles.ncompAutoButton, 'Value', 1);
        set(handles.ncompManualButton, 'Enable', 'off');
        set(handles.ncompBaseEdit, 'Enable', 'off');
        set(handles.ncompTrapEdit, 'Enable', 'off')
        set(handles.ncompCarbEdit, 'Enable', 'off');
        set(handles.ncompNoncEdit, 'Enable', 'off');
        set(handles.ncompBaseEdit, 'String', '');
        set(handles.ncompTrapEdit, 'String', '');
        set(handles.ncompCarbEdit, 'String', '');
        set(handles.ncompNoncEdit, 'String', '');
        set(handles.customButton, 'Enable', 'on');
     case 'testingsetButton'
        set(handles.calibrationsetEdit, 'Enable', 'off');
        set(handles.testingdataEdit, 'Enable', 'inactive');
        set(handles.plsmodelEdit, 'Enable', 'inactive');
        set(handles.calibrationsetEdit,'String','')
        set(handles.testingdataEdit,'String','')
        set(handles.plsmodelEdit,'String','')
        set(handles.OKbutton,'Enable','off')
        set(handles.defaultButton, 'Enable', 'on');
        set(handles.ncompAutoButton, 'Enable', 'off');
        set(handles.ncompAutoButton, 'Value', 1);
        set(handles.ncompManualButton, 'Enable', 'off');
        set(handles.ncompBaseEdit, 'Enable', 'off');
        set(handles.ncompTrapEdit, 'Enable', 'off');
        set(handles.ncompCarbEdit, 'Enable', 'off');
        set(handles.ncompNoncEdit, 'Enable', 'off');
        set(handles.ncompBaseEdit, 'String', '');
        set(handles.ncompTrapEdit, 'String', '');
        set(handles.ncompCarbEdit, 'String', '');
        set(handles.ncompNoncEdit, 'String', '');
        set(handles.customButton, 'Enable', 'on');
end



function testingdataEdit_Callback(hObject, eventdata, handles)
% hObject    handle to testingdataEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of testingdataEdit as text
%        str2double(get(hObject,'String')) returns contents of testingdataEdit as a double


% --- Executes during object creation, after setting all properties.
function testingdataEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to testingdataEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcf)

% --- Executes on button press in helpButton.
function helpButton_Callback(hObject, eventdata, handles)
% hObject    handle to helpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
helpText = ({'Operating Mode:',...
            '-----------------------',...
            '    To begin, select which mode you wish to run in: Training Data,',...
            '    Testing Data - Single, or Testing Data - Set.',...
            '',...
            '    Training: Select a calibration set ".mat" file from which to',...
            '    generate a PLS Model.',...
            '',...
            '    Testing Data - Single: Select a rock data folder containing the',...
            '    ".txt" documents obatined from the laser system.',...
            '',...
            '    Testing Data - Set: Select a folder that contains multiple rock',...
            '    data folders, that each contain their own ".txt" documents obtained',...
            '    from the laser system.',...
            '',...
            '    General operation is to run the program in Training Data mode to',...
            '    generate a PLS model from which to test all rock samples. Then,',...
            '    run the program in either Testing Data mode (depending on if one',...
            '    rock or a set are being tested) to analyze any rock(s). Make sure',...
            '    to generate a new PLS model with Training Data mode each time the',...
            '    calibration set is updated.',...
            '',...
            'Number of PLS Components:',...
            '----------------------------------------',...
            '    Allows custom selection of each PLS component value when',...
            '    generating a PLS model. Best left to auto unless experimenting.',...
            '    Only useable in Training Data mode.',...
            '',...
            'Testing Thresholds:',...
            '---------------------------',...
            '    Allows custom selection of the thresholds used to classify',...
            '    rock samples in both Testing Data modes. Rocks at and bellow the',...
            '    "Carbonate" ratio will be classified as carbonates, rocks at',...
            '    and above the "Non-Carbonate" threshold will be classified as',...
            '    non-carbonate, and rocks inbetween both thresholds will be',...
            '    classified as traprocks. Best left to default unless experimenting.',...
            '',...
            'Settings Button:',...
            '----------------------',...
            '    This button will run you through the settings configuration again',...
            '    so you can change options, such as where all results of the tool.',...
            '    will be saved.',...
            });
helpBox = msgbox(helpText, 'Help');
ah = get( helpBox, 'CurrentAxes' );
child = get( ah, 'Children' );
set(child, 'FontSize', 10);
set(helpBox, 'position', [550 150 330 570])
btn_helpBox = findobj(helpBox,'style','pushbutton');
set(btn_helpBox, 'position', [135 5 60 20])





function ncompCarbEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ncompCarbEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ncompCarbEdit as text
%        str2double(get(hObject,'String')) returns contents of ncompCarbEdit as a double
if(~isempty(get(hObject,'String')))
    numCheck = str2num(get(hObject,'String'));
    currentVal = get(hObject,'String');
    if (isempty(numCheck)|| ~isempty(strfind(currentVal, '.')))
        currentVal(regexp(currentVal,'[abcdefghijklmnopqrstuvwxyz.]'))=[];
        set(hObject,'String',currentVal)
        warndlg('Only integers are allowed for this input','Warning!')
    end
end

% --- Executes during object creation, after setting all properties.
function ncompCarbEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ncompCarbEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ncompNoncEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ncompNoncEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ncompNoncEdit as text
%        str2double(get(hObject,'String')) returns contents of ncompNoncEdit as a double
if(~isempty(get(hObject,'String')))
    numCheck = str2num(get(hObject,'String'));
    currentVal = get(hObject,'String');
    if (isempty(numCheck)|| ~isempty(strfind(currentVal, '.')))
        currentVal(regexp(currentVal,'[abcdefghijklmnopqrstuvwxyz.]'))=[];
        set(hObject,'String',currentVal)
        warndlg('Only integers are allowed for this input','Warning!')
    end
end

% --- Executes during object creation, after setting all properties.
function ncompNoncEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ncompNoncEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ncompBaseEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ncompBaseEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ncompBaseEdit as text
%        str2double(get(hObject,'String')) returns contents of ncompBaseEdit as a double
if(~isempty(get(hObject,'String')))
    numCheck = str2num(get(hObject,'String'));
    currentVal = get(hObject,'String');
    if (isempty(numCheck)|| ~isempty(strfind(currentVal, '.')))
        currentVal(regexp(currentVal,'[abcdefghijklmnopqrstuvwxyz.]'))=[];
        set(hObject,'String',currentVal)
        warndlg('Only integers are allowed for this input','Warning!')
    end
end

% --- Executes during object creation, after setting all properties.
function ncompBaseEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ncompBaseEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in ncompGroup.
function ncompGroup_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in ncompGroup 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue, 'Tag')
    case 'ncompAutoButton'
        set(handles.ncompBaseEdit, 'Enable', 'off');
        set(handles.ncompTrapEdit, 'Enable', 'off');
        set(handles.ncompCarbEdit, 'Enable', 'off');
        set(handles.ncompNoncEdit, 'Enable', 'off');
    case 'ncompManualButton'
        set(handles.ncompBaseEdit, 'Enable', 'on');
        set(handles.ncompTrapEdit, 'Enable', 'on');
        set(handles.ncompCarbEdit, 'Enable', 'on');
        set(handles.ncompNoncEdit, 'Enable', 'on');
end

% --- Executes when selected object is changed in CustomThresholds.
function CustomThresholds_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in CustomThresholds 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue, 'Tag')
    case 'defaultButton'
        set(handles.customCarbThresh, 'Enable', 'off');
        set(handles.customNCarbThresh, 'Enable', 'off');
    case 'customButton'
        set(handles.customCarbThresh, 'Enable', 'on');
        set(handles.customNCarbThresh, 'Enable', 'on');
end

function plsmodelEdit_Callback(hObject, eventdata, handles)
% hObject    handle to plsmodelEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of plsmodelEdit as text
%        str2double(get(hObject,'String')) returns contents of plsmodelEdit as a double


% --- Executes during object creation, after setting all properties.
function plsmodelEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plsmodelEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function customCarbThresh_Callback(hObject, eventdata, handles)
% hObject    handle to customCarbThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of customCarbThresh as text
%        str2double(get(hObject,'String')) returns contents of customCarbThresh as a double
if(~isempty(get(hObject,'String')))
    numCheck = str2num(get(hObject,'String'));
    currentVal = get(hObject,'String');
    if (isempty(numCheck)|| ~isempty(strfind(currentVal, '.')))
        currentVal(regexp(currentVal,'[abcdefghijklmnopqrstuvwxyz.]'))=[];
        set(hObject,'String',currentVal)
        warndlg('Only integers are allowed for this input','Warning!')
    end
end

% --- Executes during object creation, after setting all properties.
function customCarbThresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to customCarbThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function customNCarbThresh_Callback(hObject, eventdata, handles)
% hObject    handle to customNCarbThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of customNCarbThresh as text
%        str2double(get(hObject,'String')) returns contents of customNCarbThresh as a double
if(~isempty(get(hObject,'String')))
    numCheck = str2num(get(hObject,'String'));
    currentVal = get(hObject,'String');
    if (isempty(numCheck)|| ~isempty(strfind(currentVal, '.')))
        currentVal(regexp(currentVal,'[abcdefghijklmnopqrstuvwxyz.]'))=[];
        set(hObject,'String',currentVal)
        warndlg('Only integers are allowed for this input','Warning!')
    end
end

% --- Executes during object creation, after setting all properties.
function customNCarbThresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to customNCarbThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ncompTrapEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ncompTrapEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ncompTrapEdit as text
%        str2double(get(hObject,'String')) returns contents of ncompTrapEdit as a double
if(~isempty(get(hObject,'String')))
    numCheck = str2num(get(hObject,'String'));
    currentVal = get(hObject,'String');
    if (isempty(numCheck)|| ~isempty(strfind(currentVal, '.')))
        currentVal(regexp(currentVal,'[abcdefghijklmnopqrstuvwxyz.]'))=[];
        set(hObject,'String',currentVal)
        warndlg('Only integers are allowed for this input','Warning!')
    end
end


% --- Executes during object creation, after setting all properties.
function ncompTrapEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ncompTrapEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in settingsButton.
function settingsButton_Callback(hObject, eventdata, handles)
% hObject    handle to settingsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
confirmChange = questdlg('Are you sure you want to reconfigure the program settings?','Confirmation','Yes','Cancel','Cancel');
if(strcmp(confirmChange,'Yes'))
    settingsSaveDir = create_config(handles.SettingsFolder,1);
    handles.settingsSaveDir = settingsSaveDir;
    guidata(hObject, handles)
end

