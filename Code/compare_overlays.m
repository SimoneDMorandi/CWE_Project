% compare_overlays.m
% --------------------------------------------------------------------------
% Overlays same-type quantities from several sources (models / simulations)
% on one figure each, for comparison.
%
% HOW TO USE
%   - Set datadir if your files live in a subfolder ('' = current folder).
%   - For each figure below, fill the `files` list with the filenames to
%     overlay (full names, including any extension or none — these are read
%     verbatim). Optionally fill `labels` with legend names; if left empty,
%     the filenames are used.
%   - Every file is read as two numeric columns (independent, value),
%     skipping any header / parenthesis lines, so Fluent .xy, plain .txt and
%     extension-less files all work. Comma- or whitespace-separated both OK.
%
% Each file = one curve on its figure. Put as many as you like per list.
% --------------------------------------------------------------------------

datadir = '';   % e.g. 'data/'  (leave '' for current folder)

F = {};

% --- 1) Mean Cp on body:  x/B vs Cp -------------------------------------
%      (sources: med_cp_parete files, mean(cp) files, any model)
f = base('Mean C_p on body', 'x/B', 'C_p', false);
f.files  = {'bearman_med_cp_parete.txt','DNS_3D_med_cp_parete.txt','lee_med_cp_parete.txt','LES_3D_med_cp_parete.txt','ohtsuki_med_cp_parete.txt','dimat_cp_medio_parete.txt'};        % <-- FILL: e.g. {'med_cp_parete_modelA','mean_cp_modelB'}
f.labels = {};        % <-- optional
F{end+1} = f;

% --- 2) RMS Cp on body:  x/B vs Cp --------------------------------------
%      (sources: rms(cp) files, rms-different-models files)
f = base('RMS C_p on body', 'x/B', 'C_{p,rms}', false);
f.files  = {'dimat_cp_rms_parete.txt','pocha_rms_cp_parete.txt','ohtsuki_rms_cp_parete.txt','LES_3D_rms_cp_parete.txt','lee_rms_cp_parete.txt','DNS_3D_rms_cp_parete.txt','bearman_rms_cp_parete.txt'};        % <-- FILL
f.labels = {};
F{end+1} = f;

% --- 3) Mean Ux on centreline (y=0):  x/B vs Ux/U -----------------------
%      (sources: ux_y=0 files, mean-ux-y=0 files)
f = base('Mean U_x on centreline (y=0)', 'x/B', 'U_x/U', false);
f.files  = {'durao_med_ux_y=0.txt','LES_3D_med_ux_y=0.txt','Lyn_med_ux_y=0.txt'};        % <-- FILL
f.labels = {};
F{end+1} = f;

% --- 4) ux at x=0.5 (rear face), PHASE 1:  profile vs y -----------------
%      swapxy=true -> velocity on horizontal axis, y on vertical (lateral look)
f = base('u_x at x=0.5, phase 1', 'U_x/U', 'y/B', true);
f.files  = {'dimat_ph_1_ux_x=05.txt',''};        % <-- FILL (phase-1 files from each simulation)
f.labels = {};
F{end+1} = f;

% --- 5) ux at x=0.5 (rear face), PHASE 9:  profile vs y -----------------
f = base('u_x at x=0.5, phase 9', 'U_x/U', 'y/B', true);
f.files  = {'dimat_ph_9_ux_x=05.txt'};        % <-- FILL (phase-9 files)
f.labels = {};
F{end+1} = f;

% --- 6) uy at y=0 (centreline), PHASE 1:  profile vs x ------------------
f = base('u_y at y=0, phase 1', 'x/B', 'U_y/U', false);
f.files  = {'dimat_ph_1_uy_y=0.txt',};        % <-- FILL (phase-1 files)
f.labels = {};
F{end+1} = f;

% --- 7) uy at y=0 (centreline), PHASE 9:  profile vs x ------------------
f = base('u_y at y=0, phase 9', 'x/B', 'U_y/U', false);
f.files  = {'dimat_ph_9_uy_y=0.txt'};        % <-- FILL (phase-9 files)
f.labels = {};
F{end+1} = f;

%% ---- draw every figure ----
for i = 1:numel(F)
    g = F{i};
    if isempty(g.files)
        fprintf('Skipping "%s" (no files listed).\n', g.name);
        continue;
    end
    figure('Name', g.name, 'Color', 'w'); hold on; box on; grid on;
    leg = {};
    for k = 1:numel(g.files)
        d = read_xy(fullfile(datadir, g.files{k}));
        if g.swapxy
            plot(d(:,2), d(:,1), '-', 'LineWidth', 1.2, 'MarkerSize', 3);
        else
            plot(d(:,1), d(:,2), '-', 'LineWidth', 1.2, 'MarkerSize', 3);
        end
        if k <= numel(g.labels) && ~isempty(g.labels{k})
            leg{k} = g.labels{k};
        else
            leg{k} = g.files{k};
        end
    end
    xlabel(g.xlabel); ylabel(g.ylabel); title(g.name);
    legend(leg, 'Interpreter', 'none', 'Location', 'best');
end

% ==========================================================================
function f = base(name, xl, yl, swapxy)
    f = struct('name', name, 'xlabel', xl, 'ylabel', yl, ...
               'swapxy', swapxy, 'files', {{}}, 'labels', {{}});
end

function d = read_xy(fname)
% Two numeric columns from any text file; skips headers / Fluent paren lines.
    fid = fopen(fname, 'r');
    if fid < 0, error('Cannot open %s', fname); end
    d = [];
    while true
        ln = fgetl(fid);
        if ~ischar(ln), break; end
        ln = strrep(ln, ',', ' ');        % tolerate comma separators
        v  = sscanf(ln, '%f');
        if numel(v) >= 2, d(end+1, :) = v(1:2)'; end %#ok<AGROW>
    end
    fclose(fid);
    if isempty(d), error('No numeric data parsed from %s', fname); end
end
