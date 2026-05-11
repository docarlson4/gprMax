clc
clear
close all

cd(fileparts(which(mfilename)))

dbstop if error

Constants

% Developed in Matlab 9.12.0.2170939 (R2022a) Update 6 on PCWIN64.
% Doug Carlson (doug.o.carlson@gmail.com), 2023-02-26 11:45

%% Get File Name
cwd = pwd;
cd user_models\;
[filename,pathname] = uigetfile('*.out');
if isequal(filename,0)
    cd (cwd);
    error('User selected Cancel');
end
cd (cwd);

fullfilename = fullfile(pathname, filename);

%% Extract Parameters from H5 File
%     Attributes:
%         'gprMax':  '3.1.6'
%         'Title':  'Friis Transmission Test'
%         'Iterations':  2048
%         'nx_ny_nz':  100 130 160 
%         'dx_dy_dz':  0.005000 0.005000 0.005000 
%         'dt':  0.000000
%         'nsrc':  2
%         'nrx':  0
%         'srcsteps':  0 0 0 
%         'rxsteps':  0 0 0 

header.title = h5readatt(fullfilename, '/', 'Title');
header.iterations = double(h5readatt(fullfilename,'/', 'Iterations'));
tmp = h5readatt(fullfilename, '/', 'dx_dy_dz');
header.dx = tmp(1);
header.dy = tmp(2);
header.dz = tmp(3);
header.dt = h5readatt(fullfilename, '/', 'dt');
header.nsrc = h5readatt(fullfilename, '/', 'nsrc');
header.nrx = h5readatt(fullfilename, '/', 'nrx');

header

