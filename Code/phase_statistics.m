%% phase_statistics.m
% --------------------------------------------------------------------------
% Reads the 20 per-phase profiles exported by journal file and
% computes the period statistics.
%
% Cross-phase mean
% Cross-phase RMS 
%
% Outputs (CSV + figures):
%   cp_stats.csv        x/B , Cp_mean , Cp_rms
%   lateral_u.csv       y/B , U mean , (U/U) , u rms , (u rms /U)
% --------------------------------------------------------------------------

%% Parameters.
B      = 1.0;     % Square side length
Uref   = 1.0;     % Reference velocity
nph    = 20;      % Number of phases
ext    = '';      % Extension for Fluent

%% Cp on body.
[xb_cp, cp_mean, cp_rms] = aggregate('cp_parete_ph_%d', nph, ext, B, false);
writematrix([xb_cp cp_mean cp_rms], 'cp_stats.csv');

%% Streamwise velocity on the lateral line.
[yb_l, ul_mean, ul_rms] = aggregate('u_lateral_ph_%d', nph, ext, B, true);
writematrix([yb_l ul_mean ul_mean/Uref ul_rms ul_rms/Uref], 'lateral_u.csv');

%% Plotting.
figure; plot(xb_cp, cp_mean, '.-'); xlabel('x/B'); ylabel('C_p (mean)');  title('Mean C_p');
figure; plot(xb_cp, cp_rms , '.-'); xlabel('x/B'); ylabel('C_{p,rms}');    title('RMS C_p');
figure; plot(ul_mean/Uref, yb_l, '.-'); ylabel('y/B'); xlabel('U/U');      title('Lateral profile');
figure; plot(ul_rms/Uref , yb_l, '.-'); ylabel('y/B'); xlabel('u_{rms}/U');title('RMS lateral u');

disp('Done. CSVs written to the current folder.');

% Utilities.
function [pos_n, m, r] = aggregate(pattern, nph, ext, B, sortpos)
% Reads nph files matching sprintf(pattern,n)+ext, stacks the value column,
% returns normalised position (pos/B), cross-phase mean and fluctuation rms.
    X = [];  pos = [];
    for n = 0:nph-1
        d = read_xy([sprintf(pattern, n) ext]);
        if sortpos
            d = sortrows(d, 1);          
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
    r     = sqrt(mean((X - m).^2, 2));   % Fluctuation rms.
    r_full = sqrt(mean(X.^2, 2));    
    pos_n = pos / B;
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
