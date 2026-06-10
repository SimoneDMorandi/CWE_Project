% compare_statistics.m
% --------------------------------------------------------------------------
% Overlays the phase-averaged statistics against the reference Fluent XY exports,
% plotting matching quantities on the same figures.
% --------------------------------------------------------------------------

clear 
close all
clc


%% Parameters
B    = 1.0;     % Normalisation length. 
Uref = 1.0;     % Reference velocity.

% CSV files.
f_cp  = 'cp_stats.csv';
f_uc  = 'centreline_u.csv';
f_vc  = 'centreline_v.csv';
f_lat = 'lateral_u.csv';

% DIMAT reference files (Fluent XY).
f_cpm_ref = 'dimat_cp_medio_parete.txt';
f_cpr_ref = 'dimat_cp_rms_parete.txt';
f_uc_ref  = 'dimat_med_ux_y=0.txt';

%% Loading CSV files.
CP  = loadcsv(f_cp);      % [x/B  Cp_mean  Cp_rms]
UC  = loadcsv(f_uc);      % [x/B  Ux/U     u_rms/U]
VC  = loadcsv(f_vc);      % [x/B  V/U]
LAT = loadcsv(f_lat);     % [y/B  U  U/U  u_rms  u_rms/U]

%% Loading XY files and more references files.
CPM_ref = read_xy_safe(f_cpm_ref);   % [curve length  Mean Cp]
CPR_ref = read_xy_safe(f_cpr_ref);   % [curve length  RMS  Cp]
UC_ref  = read_xy_safe(f_uc_ref);    % [x             Mean Ux]
UC_ref2 = read_xy_safe('durao_med_ux_y=0.txt');
UC_ref3 = read_xy_safe('LES_3D_med_ux_y=0.txt');
UC_ref4 = read_xy_safe('Lyn_med_ux_y=0.txt');


%% Figure 1: mean Cp on the body.
figure; hold on; grid on
if ~isempty(CP)
    plot(CP(:,1),CP(:,2),'.-', 'LineWidth',1.0, 'DisplayName','K-omega');
end
if ~isempty(CPM_ref)
    plot(CPM_ref(:,1)/B, CPM_ref(:,2), '.-',  'LineWidth',1.5, 'DisplayName','DIMAT');
end
xlabel('x/B'); ylabel('C_p (mean)'); title('Mean C_p'); legend('Location','best');

%% Figure 2: RMS Cp on the body.
figure; hold on; grid on
if ~isempty(CP)
    plot(CP(:,1),        CP(:,3),      '.-', 'LineWidth',1.0, 'DisplayName','K-omega');
end
if ~isempty(CPR_ref)
    plot(CPR_ref(:,1)/B, CPR_ref(:,2), '-',  'LineWidth',1.5, 'DisplayName','DIMAT');
end
xlabel('x/B'); ylabel('Cp_{rms}'); title('RMS(CP)'); legend('Location','best');

%% Figure 3: RMS streamwise velocity on the centreline.
if ~isempty(UC)
    figure; grid on
    plot(UC(:,1), UC(:,3), '.-', 'LineWidth',1.0);
    xlabel('x/B'); ylabel('u_{rms}/U'); title('RMS U on centreline');
end

%% Figure 4: mean transverse velocity on the centreline.
if ~isempty(VC)
    figure; grid on
    plot(VC(:,1), VC(:,2), '.-', 'LineWidth',1.0);
    xlabel('x/B'); ylabel('V_{mean}/U'); title('Mean V on centreline');
end

%% Figure 5: lateral mean profile.
if ~isempty(LAT)
    figure; grid on
    plot(LAT(:,3), LAT(:,1), '.-', 'LineWidth',1.0);   % U/U vs y/B
    ylabel('y/B'); xlabel('U/U'); title('Lateral profile (mean)');
end

%% Fig 6: lateral RMS profile.
if ~isempty(LAT)
    figure; grid on
    plot(LAT(:,5), LAT(:,1), '.-', 'LineWidth',1.0);   % u_rms/U vs y/B
    ylabel('y/B'); xlabel('u_{rms}/U'); title('Lateral profile (RMS u)');
end

%% Fig 7: mean u_x on the centreline.
figure; grid on; hold on;
%if ~isempty(UC)
%    plot(UC(:,1), UC(:,2), '.-', 'LineWidth',1.0, 'DisplayName','K-omega');
%end
if ~isempty(UC_ref)
    plot(UC_ref(:,1), UC_ref(:,2), '.-', 'LineWidth',1.0, 'DisplayName','DIMAT');
end
if ~isempty(UC_ref2)
    plot(UC_ref2(:,1), UC_ref2(:,2), '.-', 'LineWidth',1.0, 'DisplayName','Durao');
end
if ~isempty(UC_ref3)
    plot(UC_ref3(:,1), UC_ref3(:,2), '.-', 'LineWidth',1.0, 'DisplayName','LES');
end
if ~isempty(UC_ref4)
    plot(UC_ref4(:,1), UC_ref4(:,2), '.-', 'LineWidth',1.0, 'DisplayName','Lyn');
end
xlabel('x/B'); ylabel('Mean u_{x}'); title('Mean u_{x} on y = 0'); legend('Location','best');

disp('Done. Comparison figures created.');

%% Utilities.
function M = loadcsv(fname)
% Reads a writematrix CSV into a numeric matrix.
    M = [];
    if exist(fname, 'file') ~= 2
        warning('CSV not found: %s  (skipped).', fname); return
    end
    try
        M = readmatrix(fname);          % R2019a+
    catch
        M = dlmread(fname);             % older MATLAB / Octave fallback
    end
end

function d = read_xy_safe(fname)
% Wrapper around read_xy.
    if exist(fname, 'file') ~= 2
        cands = { strrep(fname, '=', '_'), strrep(fname, '_y_0', '_y=0') };
        found = '';
        for k = 1:numel(cands)
            if exist(cands{k}, 'file') == 2, found = cands{k}; break; end
        end
        if isempty(found)
            warning('Reference not found: %s  (skipped).', fname); d = []; return
        end
        fname = found;
    end
    d = read_xy(fname);
end

function d = read_xy(fname)
% Parses a Fluent XY-plot file: keeps only lines that are two numbers,
    fid = fopen(fname, 'r');
    if fid < 0, error('Cannot open %s', fname); end
    d = [];
    while true
        ln = fgetl(fid);
        if ~ischar(ln), break; end
        v = sscanf(ln, '%f %f');
        if numel(v) == 2, d(end+1, :) = v'; end %#ok<AGROW>
    end
    fclose(fid);
    if isempty(d), error('No numeric data parsed from %s', fname); end
end