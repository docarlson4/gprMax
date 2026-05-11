clc
clear
close all

cd(fileparts(which(mfilename)))
addpath C:\Users\dougo\OneDrive\Documents\MATLAB\

Constants


dbstop if error

%%

[~, pc_name] = system('hostname'); pos_fac = 1;
if strcmpi(pc_name(1:end-1), 'dcarlson7560l'), pos_fac = 0.9; end

%% Load Modeled Impulse Response
trace = readgprMax('SFCWtest.out', 0);
RFImpulse = trace.fields.ez;
RFDt = trace.header.dt;
num_iter = trace.header.iterations;
RFTime = (0.5:num_iter - 0.5)'*RFDt;
RFFreq = 1/RFDt;
vel = c0/sqrt(6);

%% Radar Parameters: Frequency Step
PulseDuration = 0.05e-6;
RPI = 2*PulseDuration;
Np = 201;
f1 = 1e9;
fN = 4e9;
f = linspace(f1, fN, Np);
Df = f(2)-f(1);
BW = (Np-1)*Df;
DR = vel/(2*BW);
RU = Np * DR;
NRange = linspace(0,RU,Np);

SFTotalT = 1/Df;
FFTSize = 2^16;
SFDt = 1/(2*Df*(FFTSize/2));
SFTime = 0:SFDt:SFTotalT-SFDt;

%% Convolved Impulse Response with Gaussian Dot Norm

PulseFc = 1.5e9;

% gprMax gaussiandotnorm pulse
chi = 1/PulseFc;
delay = RFTime - chi;
zeta = 2 * (pi*PulseFc)^2;
normalize = sqrt(exp(1)/(2*zeta));
Pulse = -2 * zeta * delay .* exp(-zeta * delay.^2) .* normalize;

figure
plot(RFTime, RFImpulse)

% Obtain convolved response
PGPRC = filter(RFImpulse, 1, Pulse);
figure
plot(RFTime, PGPRC)

%% Create Stepped Frequency Source Excitation

% Determine time index for ramping up response - avoids noise in
% simulation
Ramp = ceil(4./(f*RFDt));

% Local oscillator source
OSC = zeros(num_iter, Np);
OSC_90 = zeros(num_iter, Np);
RFCW = zeros(num_iter, Np);
for k = 1:Np
    
    OSC(1:Ramp(k), k) = 0.25*f(k)*RFTime(1:Ramp(k)).*sin(2*pi*f(k)*RFTime(1:Ramp(k)));
    OSC(Ramp(k)+1:num_iter, k) = sin(2*pi*f(k)*RFTime(Ramp(k)+1:num_iter));
    OSC_90(1:Ramp(k), k) = 0.25*f(k)*RFTime(1:Ramp(k)).*cos(2*pi*f(k)*RFTime(1:Ramp(k)));
    OSC_90(Ramp(k)+1:num_iter, k) = cos(2*pi*f(k)*RFTime(Ramp(k)+1:num_iter));

    % Create received modelled gprMax response for every frequency by
    % convolving the impoulse response with the local OSC source
    RFCW(:,k) = filter(RFImpulse, 1, OSC(:,k));

end

figure
plot(RFTime, RFCW(:,10))

%% Perform Mixing
MixerI = RFCW .* OSC;
MixerQ = RFCW .* OSC_90;

%% Create Low Pass Filter and Apply to Mixer Output
% A = zeros(6, Np);
% B = zeros(6, Np);
I = zeros(num_iter,Np);
Q = zeros(num_iter,Np);
for k = 1:Np
    [b,a] = butter(5, f(k)*2/RFFreq);
    I(:,k) = filtfilt(b,a,MixerI(:,k));
    Q(:,k) = filtfilt(b,a,MixerQ(:,k));
%     [B(:,k), A(:,k)] = deal(b',a');
end

%% Build Frequency Domain Response
SF = I(round(num_iter/2),:) + 1j*Q(round(num_iter/2),:);

% figure
% subplot(211)
% plot(dB(SF))
% subplot(212)
% plot(angle(SF))

%% Prepare Frequency Array to  Populate the SF Components

WW = zeros(FFTSize, 1);
% Introduce a small delay if needed
SFDelay = exp(-2j*pi*f*1e-9);

WW( round(f1/Df)+1 : round(fN/Df)+1 ) = SFDelay.*SF.*hamming(Np)';
% Mirror for negative frequencies
WW( FFTSize - round(f1/Df)+1 : -1: FFTSize - round(fN/Df)+1 ) = ...
    conj( WW( round(f1/Df)+1 : round(fN/Df)+1 ) );

% Perform IFFT to get real part
SFCWPulse = FFTSize * real( ifft(WW) );

figure
plot(SFCWPulse)

%% Filter Impulse Responce of Channel
N = numel(RFTime);
Ts = mean(diff(RFTime))*1;

% [ImpResp, FreqResp] = ButterworthFilterDesign(11, f1-500*MHz, fN+500*MHz, 1/Ts, N, 0);
fs = 1/Ts;
fpass = [f1,fN];
fstop = fpass + [-1,1]*50*MHz;
apass = .1; % dB
astop = 20; % dB
show_plots = true;
[b, a] = ButterworthFilterDesign(fs, fpass, fstop, apass, astop, show_plots);
[ImpResp, FreqResp] = freqz(b, a, N, fs);

%%
figure
subplot(211)
plot(RFTime/ns, RFImpulse)
xlim([0,10])

subplot(212)
hold on
plot(RFTime/ns, filter(RFImpulse, 1, ImpResp'))
plot(RFTime/ns, PGPRC/100)
xlim([0,10])
% fvtool(ImpResp)

