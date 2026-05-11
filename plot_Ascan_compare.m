% plot_Ascan.m
% Script to save and plot EM fields from a gprMax A-scan
%
% Craig Warren

clc
clearvars
close all

Constants

dbstop if error

pathname = 'C:\Users\dougo\source\repos\gprMax\user_models\';

fRef  = 'monostatic_sphere_3D_off_py.out';
f{1} = fullfile(pathname,fRef);

fScat = 'monostatic_sphere_3D_py.out';
f{2} = fullfile(pathname,fScat);

header.title = h5readatt(f{1}, '/', 'Title');
Ns = double(h5readatt(f{1},'/', 'Iterations'));
tmp = h5readatt(f{1}, '/', 'dx_dy_dz');
header.dx = tmp(1);
header.dy = tmp(2);
header.dz = tmp(3);
Ts = h5readatt(f{1}, '/', 'dt');
header.nsrc = h5readatt(f{1}, '/', 'nsrc');
header.nrx = h5readatt(f{1}, '/', 'nrx');

% Time vector for plotting
time = linspace(0, (Ns - 1) * Ts, Ns)';

% Initialise structure for field arrays
fields.ex = zeros(Ns, 2);
fields.ey = zeros(Ns, 2);
fields.ez = zeros(Ns, 2);
fields.hx = zeros(Ns, 2);
fields.hy = zeros(Ns, 2);
fields.hz = zeros(Ns, 2);

% Save and plot fields from each receiver
for n=1:2
    path = strcat('/rxs/rx', '1');
    tmp = h5readatt(f{n}, path, 'Position');
    header.rx(n) = tmp(1);
    header.ry(n) = tmp(2);
    header.rz(n) = tmp(3);
    path = strcat(path, '/');
    fields.ex(:,n) = h5read(f{n}, strcat(path, 'Ex'));
    fields.ey(:,n) = h5read(f{n}, strcat(path, 'Ey'));
    fields.ez(:,n) = h5read(f{n}, strcat(path, 'Ez'));
    fields.hx(:,n) = h5read(f{n}, strcat(path, 'Hx'));
    fields.hy(:,n) = h5read(f{n}, strcat(path, 'Hy'));
    fields.hz(:,n) = h5read(f{n}, strcat(path, 'Hz'));

    if 01
        fh1=figure('Name', strcat('rx', num2str(n)));
        ax(1) = subplot(3,2,1); plot(time/ns, fields.ex(:,n), 'r', 'LineWidth', 2), grid on, xlabel('Time [ns]'), ylabel('Field strength [V/m]'), title('E_x')
        ax(2) = subplot(3,2,3); plot(time/ns, fields.ey(:,n), 'r', 'LineWidth', 2), grid on, xlabel('Time [ns]'), ylabel('Field strength [V/m]'), title('E_y')
        ax(3) = subplot(3,2,5); plot(time/ns, fields.ez(:,n), 'r', 'LineWidth', 2), grid on, xlabel('Time [ns]'), ylabel('Field strength [V/m]'), title('E_z')
        ax(4) = subplot(3,2,2); plot(time/ns, fields.hx(:,n), 'b', 'LineWidth', 2), grid on, xlabel('Time [ns]'), ylabel('Field strength [A/m]'), title('H_x')
        ax(5) = subplot(3,2,4); plot(time/ns, fields.hy(:,n), 'b', 'LineWidth', 2), grid on, xlabel('Time [ns]'), ylabel('Field strength [A/m]'), title('H_y')
        ax(6) = subplot(3,2,6); plot(time/ns, fields.hz(:,n), 'b', 'LineWidth', 2), grid on, xlabel('Time [ns]'), ylabel('Field strength [A/m]'), title('H_z')
        set(ax,'FontSize', 10, 'xlim', [0 time(end)]/ns, 'FontWeight', 'bold');

        % Options to create a nice looking figure for display and printing
        set(fh1,'Color','white','Menubar','none');
        X = 30;   % Paper size
        Y = 15;   % Paper size
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

%% Remove Reference
e_0 = fields.ey(:,1);
e_1 = fields.ey(:,2);
e_rcv = diff(fields.ey,1,2);

figure
sh(1) = subplot(3,1,1);
plot(sh(1), time/ns,e_rcv)
title('\bf\fontsize{14} Received Waveforms')

sh(2) = subplot(3,1,2);
plot(sh(2), time/ns,e_0)
title('\bf\fontsize{14} No Scatterer')

sh(3) = subplot(3,1,3);
plot(sh(3), time/ns,e_1)
title('\bf\fontsize{14} Scatterer')

xlabel(sh, "\bftime (ns)")
xlim(sh,[0,Ns]*Ts/ns)

% Matched Filter with Ricker Input Signal
fHz = 1.5*GHz;
zet = 2*pi^2*fHz^2;
chi = sqrt(2)/fHz;
gauss = exp(-zet*(time - chi).^2);
dgauss = -2*zet*(time - chi).*exp(-zet*(time - chi).^2)*sqrt(exp(1)/(2*zet));
ricker = -(2*zet*(time - chi).^2-1).*exp(-zet*(time - chi).^2);

figure,plot(time/ns,gauss, time/ns,dgauss, time/ns,ricker)
legend('Gauss','dot-Gauss', 'Ricker')
title('\bf\fontsize{14} Waveforms')

% Autocorrelations
[a_gauss, lags] = xcorr(gauss);
[a_dgauss] = xcorr(dgauss);
[a_ricker] = xcorr(ricker);

tcorr = lags*Ts;

figure
plot(tcorr/ns,a_gauss, tcorr/ns,a_dgauss, tcorr/ns,a_ricker)
xlim([-Ns+1,Ns-1]*Ts/ns)
legend('Gauss','dot-Gauss', 'Ricker')
title('\bf\fontsize{14} Waveform Autocorrelation')


% Cross correlation
wavefrom = e_0;
[c_rcv] = xcorr(e_rcv,wavefrom);
[c_0] = xcorr(e_0,wavefrom);
[c_1] = xcorr(e_1,wavefrom);


figure
sh(1) = subplot(3,1,1);
plot(sh(1), tcorr/ns,c_rcv)
sh(2) = subplot(3,1,2);
plot(sh(2), tcorr/ns,c_0)
sh(3) = subplot(3,1,3);
plot(sh(3), tcorr/ns,c_1)
xlabel(sh, "\bftime (ns)")
xlim(sh,[-Ns+1,Ns-1]*Ts/ns)

%% S21
% Target range
rng_tgt = 25*cm;

max_v = max(abs(c_0));
[~, idxmax] = max(abs(c_rcv));
s21 = max(abs(c_rcv))/max_v; % 45 cm
s21 = max(abs(c_rcv))/max_v; % 25 cm
% S21 from gprMax
S21 = dB(s21);
disp(S21)

lam = c0/1.5e9;
% Half-wavelength Dipole gain
G2 = 2*dB(1.64);

% Interface transmission
et_0 = 1; et_1 = 1/sqrt(6);
T = 4*et_0*et_1/(et_0+et_1)^2;
% 2*dB(T)

switch fScat
    case 'monostatic_cylinder_2D_py.out'
        % 2D case
        % free space
        FS = dB(lam^2/((2*pi)^3*(rng_tgt)^2));
        % RCS Cylinder
        [~, RCS] = CylinderRCSByMode(1*cm, 1.5*GHz, 1,1, 50);

    case 'monostatic_sphere_3D_py.out'
        % 2D case
        % free space
        FS = dB(lam^2/((4*pi)^3*(rng_tgt)^4));
        % RCS Sphere (10 cm)
        rcs = 0.0237; % Gibson: mie
        RCS = dB(rcs);
end

disp(FS + G2 + RCS)
lags(idxmax)*Ts*c0/2

return
%% What are Lags?
% Given r, create a copy s, shifted downward
delay = 100*Ts;
s = circshift(ricker,[delay,0]/Ts);
% Maximum lag should be delay/Ts
[c,lags] = xcorr(s,ricker);

figure
plot(lags*Ts,c)

