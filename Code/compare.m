%% compare_statistics.m
% --------------------------------------------------------------------------
% Overlays the phase-averaged statistics against the reference Fluent XY exports,
% plotting matching quantities on the same figures.
% --------------------------------------------------------------------------

clear 
close all
clc

% Parameters
B    = 1.0;     % Normalisation length. 
Uref = 1.0;     % Reference velocity.

% CSV files.
f_cp  = 'cp_stats.csv';
f_vc  = 'centreline_v.csv';
f_lat = 'lateral_u.csv';

% mean cp
dimat_p_m_file = 'dimat_cp_medio_parete.txt';
les_cp_m_file = 'LES_3D_med_cp_parete.txt';
lee_cp_m_file = 'lee_med_cp_parete.txt';
ohtsuki_cp_m_file = 'ohtsuki_med_cp_parete.txt';
bearman_cp_m_file = 'bearman_med_cp_parete.txt';

% rms cp
dimat_p_rms_file = 'dimat_cp_rms_parete.txt';
les_cp_rms_file = 'LES_3D_rms_cp_parete.txt';
pocha_cp_rms_file = 'pocha_rms_cp_parete.txt';
ohtsuki_cp_rms_file = 'ohtsuki_rms_cp_parete.txt';
dns_cp_rms_file = 'DNS_3D_rms_cp_parete.txt';
lee_cp_rms_file = 'lee_rms_cp_parete.txt';
bearman_cp_rms_file = 'bearman_rms_cp_parete.txt';

% mean u on y = 0
UY_file = 'med_ux_y=0.txt';
dimat_y_0_file  = 'dimat_med_ux_y=0.txt';
lyn_y_0_file = 'Lyn_med_ux_y=0.txt';
les_y_0_file = 'LES_3D_med_ux_y=0.txt';
durao_y_0_file = 'durao_med_ux_y=0.txt';

% Loading CSV file.
CP  = loadcsv(f_cp);  

% Loading XY files and more references files.

% mean cp
dimat_p_m = read_xy_safe(dimat_p_m_file); 
les_cp_m = read_xy_safe(les_cp_m_file);
lee_cp_m = read_xy_safe(lee_cp_m_file);
ohtsuki_cp_m = read_xy_safe(ohtsuki_cp_m_file);
bearman_cp_m = read_xy_safe(bearman_cp_m_file);

% rms cp
dimat_p_rms = read_xy_safe(dimat_p_rms_file);  
les_cp_rms = read_xy_safe(les_cp_rms_file);
pocha_cp_rms = read_xy_safe(pocha_cp_rms_file);
ohtsuki_cp_rms = read_xy_safe(ohtsuki_cp_rms_file);
dns_cp_rms = read_xy_safe(dns_cp_rms_file);
lee_cp_rms = read_xy_safe(lee_cp_rms_file);
bearman_cp_rms = read_xy_safe(bearman_cp_rms_file);

% u mean on y=0
dimat_y_0  = read_xy_safe(dimat_y_0_file);
lyn_y_0 = read_xy_safe(lyn_y_0_file);
les_y_0 = read_xy_safe(les_y_0_file);
durao_y_0 = read_xy_safe(durao_y_0_file);
UY = read_xy_safe(UY_file);

%% Figure 1: mean Cp on the body.
% Doubling DIMAT results since they refer to p, not Cp.
% Shifting all data except DIMAT and K-omega by +0.5 to match reference
% frame.
figure; hold on; grid on
if ~isempty(CP)
    plot(CP(:,1),CP(:,2),'-', 'LineWidth', 4.0, 'DisplayName','K-omega');
end
if ~isempty(dimat_p_m)
    plot(dimat_p_m(:,1)/B, 2*dimat_p_m(:,2), 'o',  'LineWidth',1.5, 'DisplayName','DIMAT');
end
if ~isempty(les_cp_m)
    plot(les_cp_m(:,1)/B + 0.5, les_cp_m(:,2), 'd',  'LineWidth',1.5, 'DisplayName','LES');
end
if ~isempty(lee_cp_m)
    plot(lee_cp_m(:,1)/B +0.5, lee_cp_m(:,2), 's',  'LineWidth',1.5, 'DisplayName','Lee');
end
if ~isempty(ohtsuki_cp_m)
    plot(ohtsuki_cp_m(:,1)/B +0.5, ohtsuki_cp_m(:,2), '^',  'LineWidth',1.5, 'DisplayName','Ohtsuki');
end
if ~isempty(bearman_cp_m)
    plot(bearman_cp_m(:,1)/B +0.5, bearman_cp_m(:,2), '+',  'LineWidth',1.5, 'DisplayName','Bearman');
end
xlabel('x/B'); ylabel('C_p (mean)'); title('Mean(C_p)'); legend('Location','best');

%% Figure 2: RMS Cp on the body.
% Doubling DIMAT results since they refer to p, not Cp.
% Shifting all data except DIMAT and K-omega by +0.5 to match reference
% frame.
% Plotting until x/B ~= 2.5 for DIMAT and K-omega.
figure; hold on; grid on

if ~isempty(CP)
    idx_cp = CP(:,1) < 2.5+ eps;
    plot(CP(idx_cp,1), CP(idx_cp,3), '-', 'LineWidth', 4.0, 'DisplayName','K-omega');
end
if ~isempty(dimat_p_rms)
    x_dimat = dimat_p_rms(:,1)/B;
    idx_dimat = x_dimat < 2.5 + eps;
   
    plot(x_dimat(idx_dimat), 2*dimat_p_rms(idx_dimat,2), 'o', 'LineWidth',1.5, 'DisplayName','DIMAT');
end
if ~isempty(les_cp_rms)
    plot(les_cp_rms(:,1)/B +0.5, les_cp_rms(:,2), 'd',  'LineWidth',1.5, 'DisplayName','LES');
end
if ~isempty(lee_cp_rms)
    plot(lee_cp_rms(:,1)/B +0.5,lee_cp_rms(:,2), 's',  'LineWidth',1.5, 'DisplayName','Lee');
end
if ~isempty(ohtsuki_cp_rms)
    plot(ohtsuki_cp_rms(:,1)/B +0.5, ohtsuki_cp_rms(:,2), '^',  'LineWidth',1.5, 'DisplayName','Otsuki');
end
if ~isempty(bearman_cp_rms)
    plot(bearman_cp_rms(:,1)/B +0.5, bearman_cp_rms(:,2), '+','LineWidth',1.5, 'DisplayName','Bearman');
end
if ~isempty(pocha_cp_rms)
    plot(pocha_cp_rms(:,1)/B +0.5, pocha_cp_rms(:,2), 'x',  'LineWidth',1.5, 'DisplayName','Pocha');
end
if ~isempty(dns_cp_rms)
    plot(dns_cp_rms(:,1)/B +0.5, dns_cp_rms(:,2), 'rv',  'LineWidth',1.5, 'DisplayName','DNS');
end
xlabel('x/B'); ylabel('Cp_{rms}'); title('RMS(C_p)'); legend('Location','best');

%% Fig 3: mean u_x on the centreline.
% Plotting starting from x/B ~= 0 for DIMAT.
% Plotting until x/B ~= 10 for DIMAT and K-omega.
figure; grid on; hold on;
if ~isempty(UY)
    x_komega = UY(:,1)/B;
    idx_komega = x_komega < 10+eps;
    plot(x_komega(idx_komega), UY(idx_komega,2), '-', 'LineWidth',4.0, 'DisplayName','K-omega');
end
if ~isempty(dimat_y_0)
    x_dimat_2 = dimat_y_0(:,1)/B;
    idx_dimat_2_start = x_dimat_2 > eps;
    idx_dimat_2_end = x_dimat_2 < (10.0 + eps);
    idx_combined = idx_dimat_2_start & idx_dimat_2_end;
    plot(x_dimat_2(idx_combined), dimat_y_0(idx_combined, 2), 'o', 'LineWidth',1.0, 'DisplayName','DIMAT');
end
if ~isempty(les_y_0)
    plot(les_y_0(:,1), les_y_0(:,2), 'd', 'LineWidth',1.0, 'DisplayName','LES');
end
if ~isempty(lyn_y_0)
    black = [0.0, 0.0, 0.0];
    plot(lyn_y_0(:,1), lyn_y_0(:,2), 'b*','Color', black, 'LineWidth',1.0, 'DisplayName','Lyn');
end
if ~isempty(durao_y_0)
    brown = [0.6, 0.4, 0.2];
    plot(durao_y_0(:,1), durao_y_0(:,2), '>','Color',brown,'LineWidth',1.0, 'DisplayName','Durao');
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
        M = readmatrix(fname);         
    catch
        M = dlmread(fname);     
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
        if numel(v) == 2, d(end+1, :) = v'; end
    end
    fclose(fid);
    if isempty(d), error('No numeric data parsed from %s', fname); end
end