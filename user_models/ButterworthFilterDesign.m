function [b, a] = ButterworthFilterDesign(fs, fpass, fstop, apass, astop, show_plots)
%BUTTERWORTHFILTERDESIGN Summary of this function goes here
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
% Douglas O. Carlson, Ph.D. (doug.o.carlson@gmail.com), 2023-09-22 17:26

%%

% Butterworth Filter Design
if nargin == 0
    cases = ["LPF", "BPF"];
    idx = menu("Choose Filter Type", cases);
    switch cases(idx)
        case "LPF"            
            % Define the filter specifications
            fs = 1000;               % Sampling frequency (Hz)
            fpass = 150;             % Passband frequency (Hz)
            fstop = 200;             % Stopband frequency (Hz)
            apass = 1;               % Passband ripple (dB)
            astop = 60;              % Stopband attenuation (dB)
        case "BPF"            
            % Define the filter specifications
            fs = 1000;               % Sampling frequency (Hz)
            fpass = [100, 200];      % Passband frequency (Hz)
            fstop = [ 50, 250];      % Stopband frequency (Hz)
            apass = 3;               % Passband ripple (dB)
            astop = 40;              % Stopband attenuation (dB)
    end
    show_plots = true;
end

% Convert frequencies to normalized values
wp = fpass / (fs/2);
ws = fstop / (fs/2);

% Determine the filter order
[n, wn] = buttord(wp, ws, apass, astop);

% Design the Butterworth filter
[b, a] = butter(n, wn);

if (nargin == 0) || show_plots
    % Obtain the frequency response of the filter
    [h, w] = freqz(b, a, 1024, fs);
    
    % Plot the frequency response
    figure;
    plot(w/1e9, 20*log10(abs(h)));
    grid on;
    xlabel('Frequency (GHz)');
    ylabel('Magnitude (dB)');
    title('Butterworth Filter Frequency Response');
    
%     % Plot the pole-zero diagram
%     figure;
%     zplane(b, a);
%     grid on;
%     xlabel('Real');
%     ylabel('Imaginary');
%     title('Pole-Zero Diagram');
%     
%     % Plot the step response
%     figure;
%     stepz(b, a);
%     grid on;
%     xlabel('Time');
%     ylabel('Amplitude');
%     title('Step Response');
%     
%     % Plot the impulse response
%     figure;
%     impz(b, a);
%     grid on;
%     xlabel('Time');
%     ylabel('Amplitude');
%     title('Impulse Response');
    
end
if nargin == 0
    clear b
end

end
