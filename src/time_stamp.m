function [ date_n_time ] = time_stamp( )
%TIME_STAMP Summary of this function goes here
%   Detailed explanation goes here
date_n_time = datestr(now);
colon_find = strfind(date_n_time,':');
date_n_time(colon_find) = '_';
end

