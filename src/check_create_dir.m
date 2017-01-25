function  return_dir = check_create_dir( dir_check_name,arg_in, mode )
%Checks if a directory exists based on parameters and then creats it if it
%doesnt. Then returns a directory based on the mode
switch mode
    case 0
    %Just determines the m files directory and retruns it
     m_dir_marker = strfind(arg_in,'\');
     m_dir_marker = m_dir_marker(end);
     m_dir = arg_in(1:m_dir_marker-1);
     return_dir = m_dir;
    case 1
    %Checks for directory in same folder as the m file and creates if not
    %there and then returns the directory of the m file
     m_dir_marker = strfind(arg_in,'\');
     m_dir_marker = m_dir_marker(end);
     m_dir = arg_in(1:m_dir_marker-1);
     check_dir = [m_dir,'\',dir_check_name];
     if(~exist(check_dir,'dir'))
         mkdir(check_dir)
         addpath(check_dir)
     end
     return_dir = m_dir;
    case 2
    %Checks for directory in same folder as the m file and creates if not
    %there and then returns the directory that would be created
     m_dir_marker = strfind(arg_in,'\');
     m_dir_marker = m_dir_marker(end);
     m_dir = arg_in(1:m_dir_marker-1);
     check_dir = [m_dir,'\',dir_check_name];
     if(~exist(check_dir,'dir'))
         mkdir(check_dir)
         addpath(check_dir)
     end
     return_dir = check_dir;
    case 3
    %Checks for given directory that isnt relative to the current mfile
    %and creates it if it doesn't exist
     check_dir = [arg_in,'\',dir_check_name];
     if(~exist(check_dir,'dir'))
         mkdir(check_dir)
         addpath(check_dir)
     end
     return_dir = check_dir;
end