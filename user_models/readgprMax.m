function trace = readgprMax(filename, SHOW_PLOTS)
%READGPRMAX Summary of this function goes here
%   Detailed explanation goes here
%
% INPUT
%
%
% OUTPUT
%
%
% USAGE
%
%

% Developed in Matlab 9.12.0.2327980 (R2022a) Update 7 on PCWIN64.
% Douglas O. Carlson, Ph.D. (doug.o.carlson@gmail.com), 2023-09-22 17:17

%%
if nargin == 1
    SHOW_PLOTS = 0;
end
if nargin == 0
    [filename, pathname] = uigetfile('*.out', 'Select gprMax A-scan output file to plot');
    fullfilename = strcat(pathname, filename);
    SHOW_PLOTS = 01;
end
if filename ~= 0
    fullfilename = filename;
    header.title = h5readatt(fullfilename, '/', 'Title');
    header.iterations = double(h5readatt(fullfilename,'/', 'Iterations'));
    tmp = h5readatt(fullfilename, '/', 'dx_dy_dz');
   header.dx = tmp(1);
    header.dy = tmp(2);
    header.dz = tmp(3);
    header.dt = h5readatt(fullfilename, '/', 'dt');
    header.nsrc = h5readatt(fullfilename, '/', 'nsrc');
    header.nrx = h5readatt(fullfilename, '/', 'nrx');

    % Time vector for plotting
    time = linspace(0, (header.iterations - 1) * header.dt, header.iterations)';

    % Initialise structure for field arrays
    fields.ex = zeros(header.iterations, header.nrx);
    fields.ey = zeros(header.iterations, header.nrx);
    fields.ez = zeros(header.iterations, header.nrx);
    fields.hx = zeros(header.iterations, header.nrx);
    fields.hy = zeros(header.iterations, header.nrx);
    fields.hz = zeros(header.iterations, header.nrx);

    % Save and plot fields from each receiver
    for n=1:header.nrx
        path = strcat('/rxs/rx', num2str(n));
        tmp = h5readatt(fullfilename, path, 'Position');
        header.rx(n) = tmp(1);
        header.ry(n) = tmp(2);
        header.rz(n) = tmp(3);
        path = strcat(path, '/');
        fields.ex(:,n) = h5read(fullfilename, strcat(path, 'Ex'));
        fields.ey(:,n) = h5read(fullfilename, strcat(path, 'Ey'));
        fields.ez(:,n) = h5read(fullfilename, strcat(path, 'Ez'));
        fields.hx(:,n) = h5read(fullfilename, strcat(path, 'Hx'));
        fields.hy(:,n) = h5read(fullfilename, strcat(path, 'Hy'));
        fields.hz(:,n) = h5read(fullfilename, strcat(path, 'Hz'));

        if SHOW_PLOTS
            fh1=figure('Name', strcat('rx', num2str(n)));
            ax(1) = subplot(3,2,1); plot(time, fields.ex(:,n), 'r', 'LineWidth', 2), grid on, xlabel('Time [s]'), ylabel('Field strength [V/m]'), title('E_x')
            ax(2) = subplot(3,2,3); plot(time, fields.ey(:,n), 'r', 'LineWidth', 2), grid on, xlabel('Time [s]'), ylabel('Field strength [V/m]'), title('E_y')
            ax(3) = subplot(3,2,5); plot(time, fields.ez(:,n), 'r', 'LineWidth', 2), grid on, xlabel('Time [s]'), ylabel('Field strength [V/m]'), title('E_z')
            ax(4) = subplot(3,2,2); plot(time, fields.hx(:,n), 'b', 'LineWidth', 2), grid on, xlabel('Time [s]'), ylabel('Field strength [A/m]'), title('H_x')
            ax(5) = subplot(3,2,4); plot(time, fields.hy(:,n), 'b', 'LineWidth', 2), grid on, xlabel('Time [s]'), ylabel('Field strength [A/m]'), title('H_y')
            ax(6) = subplot(3,2,6); plot(time, fields.hz(:,n), 'b', 'LineWidth', 2), grid on, xlabel('Time [s]'), ylabel('Field strength [A/m]'), title('H_z')
            set(ax,'FontSize', 16, 'xlim', [0 time(end)]);

            % Options to create a nice looking figure for display and printing
            set(fh1,'Color','white','Menubar','none');
            X = 40;   % Paper size
            Y = 20;   % Paper size
            xMargin = 0; % Left/right margins from page borders
            yMargin = 0;  % Bottom/top margins from page borders
            xSize = X - 2*xMargin;    % Figure size on paper (width & height)
            ySize = Y - 2*yMargin;    % Figure size on paper (width & height)

            % Figure size displayed on screen
            set(fh1, 'Units','centimeters', 'Position', [0 0 xSize ySize])
            movegui(fh1, 'center')

            % Figure size printed on paper
            set(fh1,'PaperUnits', 'centimeters')
            set(fh1,'PaperSize', [X Y])
           set(fh1,'PaperPosition', [xMargin yMargin xSize ySize])
            set(fh1,'PaperOrientation', 'portrait')
        end
    end
end
trace.fields.ez = fields.ez;
trace.header.dt = header.dt;
trace.header.iterations = header.iterations;





end
