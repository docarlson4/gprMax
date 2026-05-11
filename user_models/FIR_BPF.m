function [b,a] = FIR_BPF(fs, fpass, Ap, show_plots)
%FIR_BPF Summary of this function goes here
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

% Developed in Matlab 9.9.0.2037887 (R2020b) Update 8 on PCWIN64.
% Douglas O. Carlson, Ph.D. (doug.o.carlson@gmail.com), 2023-09-22 19:48

%%

if nargin == 0
    
    % Filter specifications
    fs = 16e9;         % Sampling frequency in Hz
    fpass = [1e9, 4e9];
    %     Fs1 = 30;          % Lower stopband frequency in Hz
    %     Fs2 = 220;         % Upper stopband frequency in Hz
    Ap = 1;            % Passband ripple in dB
    %     As = 60;           % Stopband attenuation in dB
    show_plots = true;
end

Fp1 = fpass(1);          % Lower passband frequency in Hz
Fp2 = fpass(2);         % Upper passband frequency in Hz

% Calculate the normalized frequencies
Wp1 = 2 * Fp1 / fs;
Wp2 = 2 * Fp2 / fs;
% Ws1 = 2 * Fs1 / Fs;
% Ws2 = 2 * Fs2 / Fs;

% Design the FIR filter using the fir1 function
N = 100;           % Filter order
b = fir1(N, [Wp1 Wp2], 'bandpass', kaiser(N+1, Ap), 'noscale');
a = 1;

if show_plots
    % Obtain the frequency response of the filter
    [h, w] = freqz(b, a, 1024, fs);

    % Plot the frequency response
    figure;
    plot(w/1e9, 20*log10(abs(h)));
    grid on;
    xlabel('Frequency (GHz)');
    ylabel('Magnitude (dB)');
    title('FIR Frequency Response');
end

if nargin == 0111
    % Generate a test signal
    t = 0:1/fs:1;      % Time vector
    f_signal = 100;    % Frequency of the input signal in Hz
    input_signal = sin(2 * pi * f_signal * t);
    
    % Apply the filter to the input signal
    output_signal = filter(b, 1, input_signal);
    
    % Plot the original and filtered signals
    figure;
    subplot(2,1,1);
    plot(t, input_signal);
    title('Original Signal');
    xlabel('Time (s)');
    ylabel('Amplitude');
    subplot(2,1,2);
    plot(t, output_signal);
    title('Filtered Signal');
    xlabel('Time (s)');
    ylabel('Amplitude');
end

end
