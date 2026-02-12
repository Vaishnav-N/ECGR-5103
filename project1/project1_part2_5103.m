% project1_part2_5103.m
% ECGR 5103: Optimizes K for faint and bright objects; plots I/O curves.

clear all;

%% Load filter data
load('HST_MOS_5136_ACS_WFC_F475W_drz.mat');
vars = who('-file', 'HST_MOS_5136_ACS_WFC_F475W_drz.mat');
if isempty(vars)
    load('HST_MOS_5136_ACS_WFC_F475W_drz.mat');
    vars = who;
    vars = setdiff(vars, {'ans', 'varargin', 'varargout', 'vars'});
end
if ~isempty(vars)
    F475W_data = eval(vars{1});
else
    error('Could not find image data in F475W file. Please check variable name.');
end

load('HST_MOS_5136_ACS_WFC_F625W_drz.mat');
vars = who('-file', 'HST_MOS_5136_ACS_WFC_F625W_drz.mat');
if isempty(vars)
    load('HST_MOS_5136_ACS_WFC_F625W_drz.mat');
    vars = who;
    vars = setdiff(vars, {'ans', 'varargin', 'varargout', 'vars', 'F475W_data'});
end
if ~isempty(vars)
    F625W_data = eval(vars{1});
else
    error('Could not find image data in F625W file. Please check variable name.');
end

load('HST_MOS_5136_ACS_WFC_F775W_drz.mat');
vars = who('-file', 'HST_MOS_5136_ACS_WFC_F775W_drz.mat');
if isempty(vars)
    load('HST_MOS_5136_ACS_WFC_F775W_drz.mat');
    vars = who;
    vars = setdiff(vars, {'ans', 'varargin', 'varargout', 'vars', 'F475W_data', 'F625W_data'});
end
if ~isempty(vars)
    F775W_data = eval(vars{1});
else
    error('Could not find image data in F775W file. Please check variable name.');
end

%% Pre-processing
x_range = 1200:4700;
y_range = 1200:4700;

F475W_patch = double(F475W_data(y_range, x_range));
F625W_patch = double(F625W_data(y_range, x_range));
F775W_patch = double(F775W_data(y_range, x_range));

F475W_patch(F475W_patch < 0) = 0;
F625W_patch(F625W_patch < 0) = 0;
F775W_patch(F775W_patch < 0) = 0;

F475W_norm = (F475W_patch - min(F475W_patch(:))) / (max(F475W_patch(:)) - min(F475W_patch(:)));
F625W_norm = (F625W_patch - min(F625W_patch(:))) / (max(F625W_patch(:)) - min(F625W_patch(:)));
F775W_norm = (F775W_patch - min(F775W_patch(:))) / (max(F775W_patch(:)) - min(F775W_patch(:)));

RGB_image = zeros(size(F475W_norm, 1), size(F475W_norm, 2), 3);
RGB_image(:,:,1) = F775W_norm;
RGB_image(:,:,2) = F625W_norm;
RGB_image(:,:,3) = F475W_norm;

%% Optimize K for faint objects
K_powK_range = 0.05:0.01:0.2;
K_asinhK_range = 5000:1000:20000;
test_patch = RGB_image(1:500, 1:500, :);
faint_threshold = 0.1;
faint_mask = test_patch < faint_threshold;

powK_results = zeros(size(K_powK_range));
for i = 1:length(K_powK_range)
    enhanced = hubbleEnhance('powK', test_patch, K_powK_range(i));
    powK_results(i) = mean(enhanced(faint_mask));
end

asinhK_results = zeros(size(K_asinhK_range));
for i = 1:length(K_asinhK_range)
    enhanced = hubbleEnhance('asinhK', test_patch, K_asinhK_range(i));
    asinhK_results(i) = mean(enhanced(faint_mask));
end

[~, powK_opt_idx] = max(powK_results);
K_powK_faint = K_powK_range(powK_opt_idx);

[~, asinhK_opt_idx] = max(asinhK_results);
K_asinhK_faint = K_asinhK_range(asinhK_opt_idx);

%% Optimize K for bright objects
K_powK_bright_range = 0.8:0.05:1.5;
K_asinhK_bright_range = 1000:500:5000;
bright_threshold = 0.7;
bright_mask = test_patch > bright_threshold;

powK_bright_results = zeros(size(K_powK_bright_range));
for i = 1:length(K_powK_bright_range)
    enhanced = hubbleEnhance('powK', test_patch, K_powK_bright_range(i));
    bright_enhanced = enhanced(bright_mask);
    powK_bright_results(i) = std(bright_enhanced(:));
end

asinhK_bright_results = zeros(size(K_asinhK_bright_range));
for i = 1:length(K_asinhK_bright_range)
    enhanced = hubbleEnhance('asinhK', test_patch, K_asinhK_bright_range(i));
    bright_enhanced = enhanced(bright_mask);
    asinhK_bright_results(i) = std(bright_enhanced(:));
end

[~, powK_bright_opt_idx] = max(powK_bright_results);
K_powK_bright = K_powK_bright_range(powK_bright_opt_idx);

[~, asinhK_bright_opt_idx] = max(asinhK_bright_results);
K_asinhK_bright = K_asinhK_bright_range(asinhK_bright_opt_idx);

%% Plot I/O curves at optimal K
r = 0:0.001:1;

figure('Name', 'Part 2 (5103): I/O Curves for Faint Objects', 'Position', [100, 100, 900, 400]);
subplot(1,2,1);
plot(r, r.^K_powK_faint, 'b-', 'LineWidth', 2);
xlabel('Input Intensity, r'); ylabel('Output Intensity, s');
title(sprintf('powK (K=%.3f) - Faint Objects', K_powK_faint)); grid on;
subplot(1,2,2);
plot(r, asinh(r*K_asinhK_faint)/asinh(K_asinhK_faint), 'r-', 'LineWidth', 2);
xlabel('Input Intensity, r'); ylabel('Output Intensity, s');
title(sprintf('asinhK (K=%d) - Faint Objects', K_asinhK_faint)); grid on;

figure('Name', 'Part 2 (5103): I/O Curves for Bright Objects', 'Position', [150, 150, 900, 400]);
subplot(1,2,1);
plot(r, r.^K_powK_bright, 'b-', 'LineWidth', 2);
xlabel('Input Intensity, r'); ylabel('Output Intensity, s');
title(sprintf('powK (K=%.3f) - Bright Objects', K_powK_bright)); grid on;
subplot(1,2,2);
plot(r, asinh(r*K_asinhK_bright)/asinh(K_asinhK_bright), 'r-', 'LineWidth', 2);
xlabel('Input Intensity, r'); ylabel('Output Intensity, s');
title(sprintf('asinhK (K=%d) - Bright Objects', K_asinhK_bright)); grid on;

fprintf('\nPart 2 (5103) - Optimal K:\n');
fprintf('Faint:  powK K=%.3f, asinhK K=%d\n', K_powK_faint, K_asinhK_faint);
fprintf('Bright: powK K=%.3f, asinhK K=%d\n', K_powK_bright, K_asinhK_bright);
