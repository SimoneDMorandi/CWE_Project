% phase_statistics.m
% --------------------------------------------------------------------------
% Reads the 20 per-phase profiles exported by journal_phaseavg.jou and
% computes the cross-phase (period) statistics.
%
% Cross-phase mean  ~ time mean over one shedding period
% Cross-phase RMS   = sqrt(mean((x - mean).^2))  -> FLUCTUATION rms (std).
%   If your reference uses the full rms sqrt(mean(x.^2)), use rms_full instead.
%
% Outputs (CSV + figures):
%   cp_stats.csv        x/B , Cp_mean , Cp_rms
%   centreline_u.csv    x/B , Ux/U mean , Ux/U rms        (U mean on centreline + its rms)
%   centreline_v.csv    x/B , Vmean/U
%   lateral_u.csv       y/B , U mean , (U/U) , u rms , (u rms /U)
% --------------------------------------------------------------------------

%% ---- user parameters ----
B      = 1.0;     % <-- square side length (normalisation length)
Uref   = 1.0;     % <-- reference velocity
nph    = 20;      % number of phases
ext    = '';   % extension Fluent wrote (often none or .xy) -- adjust if needed

%% ---- Cp on body ----
[xb_cp, cp_mean, cp_rms] = aggregate('cp_parete_ph_%d', nph, ext, B, false);
writematrix([xb_cp cp_mean cp_rms], 'cp_stats.csv');

%% ---- streamwise velocity on the centreline ----
[xb_u, u_mean, u_rms] = aggregate('ux_centreline_ph_%d', nph, ext, B, true);
writematrix([xb_u u_mean/Uref u_rms/Uref], 'centreline_u.csv');

%% ---- transverse velocity on the centreline ----
[xb_v, v_mean, ~] = aggregate('vy_centreline_ph_%d', nph, ext, B, true);
writematrix([xb_v v_mean/Uref], 'centreline_v.csv');

%% ---- streamwise velocity on the lateral line (abscissa = y) ----
[yb_l, ul_mean, ul_rms] = aggregate('u_lateral_ph_%d', nph, ext, B, true);
writematrix([yb_l ul_mean ul_mean/Uref ul_rms ul_rms/Uref], 'lateral_u.csv');

%% ---- quick plots ----
figure; plot(xb_cp, cp_mean, '.-'); xlabel('x/B'); ylabel('C_p (mean)');  title('Mean C_p');
figure; plot(xb_cp, cp_rms , '.-'); xlabel('x/B'); ylabel('C_{p,rms}');    title('RMS C_p');
figure; plot(xb_u, u_mean/Uref, '.-'); xlabel('x/B'); ylabel('U_x/U');     title('Mean U on centreline');
figure; plot(xb_u, u_rms/Uref , '.-'); xlabel('x/B'); ylabel('u_{rms}/U'); title('RMS U on centreline');
figure; plot(xb_v, v_mean/Uref, '.-'); xlabel('x/B'); ylabel('V_{mean}/U');title('Mean V on centreline');
figure; plot(ul_mean/Uref, yb_l, '.-'); ylabel('y/B'); xlabel('U/U');      title('Lateral profile');
figure; plot(ul_rms/Uref , yb_l, '.-'); ylabel('y/B'); xlabel('u_{rms}/U');title('RMS lateral u');

disp('Done. CSVs written to the current folder.');

% ==========================================================================
function [pos_n, m, r] = aggregate(pattern, nph, ext, B, sortpos)
% Reads nph files matching sprintf(pattern,n)+ext, stacks the value column,
% returns normalised position (pos/B), cross-phase mean and fluctuation rms.
    X = [];  pos = [];
    for n = 0:nph-1
        d = read_xy([sprintf(pattern, n) ext]);
        if sortpos
            d = sortrows(d, 1);          % monotone for line surfaces -> safe to align
        end
        if n == 0
            pos = d(:,1);
            X   = zeros(numel(pos), nph);
        else
            if numel(d(:,1)) ~= numel(pos)
                error('Point count differs in %s -- phases not on the same nodes.', ...
                      sprintf(pattern, n));
            end
        end
        X(:, n+1) = d(:,2);
    end
    m     = mean(X, 2);
    r     = sqrt(mean((X - m).^2, 2));   % fluctuation rms (std about the phase mean)
    r_full = sqrt(mean(X.^2, 2));      % <- uncomment for full rms instead
    pos_n = pos / B;
end

function d = read_xy(fname)
% Parses a Fluent XY-plot file: keeps only lines that are two numbers,
% skipping the (title ...) / (labels ...) / ((...)) header lines.
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
