% plot_reports.m
% Reads Fluent report-definition .out files and plots Time Step vs the
% reported quantity.
%
% Each file is assumed to share the same structure:
%   "header line in quotes"
%   (parenthesised column labels)
%   timeStep   flowTime   report-def-value

clear
clc
close all
 
%% Files to process.
% Column 1: filename on disk
% Column 2: label for the y-axis / title
reports = {
    'drag.out',     'Report Def Drag'
    'lift.out',     'Report Def Lift'
    'moment.out',   'Report Def Moment'
    'ulateral.out', 'Report Def u_{lateral}'
    'umean.out',    'Report Def u_{mean}'
};
 
%% Looping over every report file.
for k = 1:size(reports, 1)
    filename = reports{k, 1};
    label    = reports{k, 2};
 
    % Skipping.
    if exist(filename, 'file') ~= 2
        warning('File not found, skipping: %s', filename);
        continue
    end
 
    [timeStep, value] = readReport(filename);
 
    if isempty(timeStep)
        warning('No data rows found in %s - skipping.', filename);
        continue
    end
 
    %% Plotting
    figure('Name', [label ' vs Time Step'], 'NumberTitle', 'off');
 
    plot(timeStep, value, 'b-o', 'LineWidth', 0.5, 'MarkerSize', 5, ...
         'MarkerFaceColor', 'b');
 
    xlabel('Time Step',                'FontSize', 12);
    ylabel(label,                      'FontSize', 12);
    title([label ' vs Time Step'],     'FontSize', 14);
    grid on;
    xlim([min(timeStep) max(timeStep)]);
end
 
%% Utilities
function [timeStep, value] = readReport(filename)
% Parses one Fluent file.
    fid = fopen(filename, 'r');
    if fid == -1
        error('Cannot open file: %s', filename);
    end
 
    timeStep = [];
    value    = [];
 
    while ~feof(fid)
        line = strtrim(fgetl(fid));
 
        % Skipping empty lines, header strings, and parenthesised column labels.
        if isempty(line) || line(1) == '"' || line(1) == '('
            continue
        end
 
        % Reading three numeric columns: timeStep  flowTime  report-def-value.
        vals = sscanf(line, '%f %f %f');
        if numel(vals) == 3
            timeStep(end+1) = vals(1); %#ok<AGROW>
            value(end+1)    = vals(3); %#ok<AGROW>
        end
    end
 
    fclose(fid);
end