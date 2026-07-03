%% integral.m
% --------------------------------------------------------------------------
% Computes integral parameters.
% --------------------------------------------------------------------------

clear 
clc

% Loading Fluent monitor files.
cd_data = readmatrix('drag.out', 'FileType', 'text', 'CommentStyle', '%');
cl_data = readmatrix('lift.out', 'FileType', 'text', 'CommentStyle', '%');

% Columns: [iteration, time, coefficient].
t  = cd_data(:, 2);
CX = cd_data(:, 3);
CY = cl_data(:, 3);

% Integral parameters.
CX_mean = mean(CX);
CX_rms  = rms(CX - mean(CX));      
CY_rms  = rms(CY - mean(CY));    

% Printing results.
fprintf('C̄_X  = %.4f\n', CX_mean);
fprintf('C̃_X  = %.4f\n', CX_rms);
fprintf('C̃_Y  = %.4f\n', CY_rms);

% Strouhal number via FFT of CY.
dt    = mean(diff(t));
N     = length(CY);
f     = (0:N-1) / (N * dt);        % frequency axis [Hz or 1/s]
P     = abs(fft(CY - mean(CY)));

[~, idx] = max(P(1:floor(N/2)));   % Dominant frequency.
f_dom = f(idx);

% Setting B and U_inf.
B     = 1.0;                        
U_inf = 1.0;                        
St    = f_dom * B / U_inf;

fprintf('St    = %.4f\n', St);