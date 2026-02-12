% project1_part3.m
% Applies geometric transformations to align with reference image.

clear all;

%% Load and preprocess filter data
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

<｜tool▁sep｜>new_string

RGB_enhanced = hubbleEnhance('asinhK', RGB_image, 10000);
RGB_enhanced_uint8 = uint8(RGB_enhanced * 255);

%% Apply transformations (rotation 180 deg matches reference)
RGB_rot180 = my_imrotate(RGB_enhanced_uint8, 180, 'bilinear', 'crop');
RGB_flipH = flip(RGB_enhanced_uint8, 2);
RGB_flipV = flip(RGB_enhanced_uint8, 1);
RGB_rot180_flipH = flip(my_imrotate(RGB_enhanced_uint8, 180, 'bilinear', 'crop'), 2);
RGB_rot90ccw = my_imrotate(RGB_enhanced_uint8, 90, 'bilinear', 'crop');
RGB_rot90cw = my_imrotate(RGB_enhanced_uint8, -90, 'bilinear', 'crop');
RGB_final = RGB_rot180;

figure('Name', 'Part 3: Final Transformed Image', 'Position', [200, 200, 1000, 1000]);
imshow(RGB_final);
title('Final Transformed Image of Abell 1689 (Rotated 180°)');

fprintf('Part 3 - Transformation: rotation 180 deg\n');
