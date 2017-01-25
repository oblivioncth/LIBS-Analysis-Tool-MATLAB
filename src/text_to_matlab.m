%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function test_rock_filename = text_to_matlab
%
% This function is designed to be called by lasergui.m. It shall prompt the
% user for a directory containing text files that they wish to test with
% their PLS model. The function will look to see if the folder contains a
% .mat file containing the data already converted from .txt. If this .mat
% file exists, the function returns the file. Otherwise it will convert
% each txt file to a vector and concatenate them to the test_rock_data
% matrix (one txt file's observations per row), then save and return this
% matrix.
%
% This version of the code is meant to work only with test data 12288 in
% length.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function test_rock_filename = text_to_matlab(dir_in,mode,settingsSave_dir,TStamp)

% Save original directory and prompt user for directory containing test
% data
orig_dir = pwd;
test_rock_filename = [];

switch mode
    case 1
        singlefolder = dir_in;
        setcount = 1;
    case 2
        setfolder = dir_in;
        setlist = dir(setfolder);
        setlist = extractfield(setlist,'name');
        setlist = setlist(3:numel(setlist));
        setcount = numel(setlist); 
end

w = waitbar(0,'Converting testing data to .mat format...','Name','Please Wait...');
try
    frames = java.awt.Frame.getFrames();
    frames(end).setAlwaysOnTop(1);
catch
end
waitbar(1/5,w)
for t = 1:setcount
    waitbar((1/5+3/5*(t/setcount)),w)
    % Determine folder if in Testing Set mode
    switch mode
        case 1
            folder = singlefolder;
            foldMark = strfind(folder,'\');
            rock_type = folder(foldMark(end)+1:end);
        case 2
            folder = [setfolder,'\',setlist{t}];
            rock_type = setlist{t};
    end
    % Use user-specified folder to generate filename of .mat file
    test_rock_filename{t} = strcat(rock_type,'.mat');

    % Get the filenames for each .txt file in a list and the number of files.
    dirListing = dir(fullfile(folder,'*.txt'));
    nfiles = length(dirListing);

    % Initialize test_rock_data matrix.
    test_rock_data = [];

    % Place data from each text file on its own row in test_rock_data
    for i=1:nfiles
        fileName = fullfile(folder,dirListing(i).name);
        test_rock_data(i,:) = dlmread(fileName,'\t','B11..B12298');
    end
    save_dir = check_create_dir(['LAT Results\Testing Data - Conversion to mat\',TStamp],settingsSave_dir,3);
    save([save_dir, '\', test_rock_filename{t}], 'test_rock_data');
    disp(['Converted test data for ', rock_type, ' saved to ', save_dir])

end
waitbar(1,w)
cd(orig_dir)
delete(w)
