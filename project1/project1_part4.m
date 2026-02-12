% project1_part4.m
% ECGR 5103: Difference image and rotation angle optimization.

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

%% Preprocess (patch [1200:4700], clamp, normalize)
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

% Apply enhancement
RGB_enhanced = hubbleEnhance('asinhK', RGB_image, 10000);
RGB_enhanced_uint8 = uint8(RGB_enhanced * 255);

RGB_transformed = my_imrotate(RGB_enhanced_uint8, 180, 'bilinear', 'crop');

%% Difference image: log10(abs(I1-I2)+1)
try
    I2_ref = imread('Abell_1689_reference.jpg');
    
    % Convert to double and normalize
    I2_ref_double = double(I2_ref) / 255.0;
    
    % Resize reference image to match our image size
    [rows, cols, ~] = size(RGB_transformed);
    I2_resized = imresize(I2_ref_double, [rows, cols], 'bilinear');
    
    % Convert our image to double
    I1_double = double(RGB_transformed) / 255.0;
    
    % Compute difference image: log10(abs(I1-I2)+1)
    diff_image = log10(abs(I1_double - I2_resized) + 1);
    
    % Display difference image
    figure('Name', 'Difference Image', 'Position', [100, 100, 1200, 600]);
    subplot(1,2,1);
    imshow(RGB_transformed);
    title('Our Transformed Image');
    
    subplot(1,2,2);
    imshow(diff_image, []);
    title('Difference Image: log10(abs(I1-I2)+1)');
    colorbar;
    
catch
    fprintf('Part 4.1: Abell_1689_reference.jpg not found.\n');
end

%% Error vs. rotation angle (theta +/- 5 deg)
if exist('I2_resized', 'var')
    initial_theta = 180;
    theta_range = (initial_theta - 5):0.5:(initial_theta + 5);
    error_values = zeros(size(theta_range));
    I2_gray = rgb2gray(I2_resized);
    I1_gray = rgb2gray(I1_double);
    
    for i = 1:length(theta_range)
        theta = theta_range(i);
        I_rotated = my_imrotate(I1_gray, theta - initial_theta, 'bilinear', 'crop');
        
        if size(I_rotated) ~= size(I2_gray)
            I_rotated = imresize(I_rotated, size(I2_gray), 'bilinear');
        end
        
        error_values(i) = sum(abs(I_rotated(:) - I2_gray(:)));
        
    end
    
    [min_error, min_idx] = min(error_values);
    optimal_theta = theta_range(min_idx);
    
    fprintf('Part 4 - Optimal angle: %.2f deg, min error: %e\n', optimal_theta, min_error);
    
    figure('Name', 'Rotation Angle Optimization', 'Position', [200, 200, 1000, 600]);
    plot(theta_range, error_values, 'b-', 'LineWidth', 2);
    hold on;
    plot(optimal_theta, min_error, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
    xlabel('Rotation Angle (degrees)');
    ylabel('Sum of Absolute Error');
    title('Error vs. Rotation Angle');
    legend('Error', 'Optimal Angle', 'Location', 'best');
    grid on;
    hold off;
    
else
    fprintf('Part 4.2: Skipped (reference image not found).\n');
end
