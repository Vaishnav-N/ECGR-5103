% project1.m
% Loads Hubble Abell 1689 filter data, combines to RGB, and applies powK/asinhK enhancements.

clear all;

%% Load filter images
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

%% Extract patch [1200:4700], clamp negatives, normalize to [0,1]
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

%% RGB mapping (F775W->R, F625W->G, F475W->B by wavelength)

RGB_image = zeros(size(F475W_norm, 1), size(F475W_norm, 2), 3);
RGB_image(:,:,1) = F775W_norm;  % Red channel
RGB_image(:,:,2) = F625W_norm;  % Green channel
RGB_image(:,:,3) = F475W_norm;  % Blue channel

RGB_image_uint8 = uint8(RGB_image * 255);

%% Enhance and display 3x1: unmodified, powK(0.13), asinhK(10000)
RGB_enhanced_powK = hubbleEnhance('powK', RGB_image, 0.13);
RGB_enhanced_powK_uint8 = uint8(RGB_enhanced_powK * 255);
RGB_enhanced_asinhK = hubbleEnhance('asinhK', RGB_image, 10000);
RGB_enhanced_asinhK_uint8 = uint8(RGB_enhanced_asinhK * 255);

figure('Name', 'Image Enhancements Comparison', 'Position', [100, 100, 1200, 1500]);
subplot(3,1,1);
imshow(RGB_image_uint8);
title('(1) Un-modified RGB Image');

subplot(3,1,2);
imshow(RGB_enhanced_powK_uint8);
title('(2) Enhanced with powK (K=0.13)');

subplot(3,1,3);
imshow(RGB_enhanced_asinhK_uint8);
title('(3) Enhanced with asinhK (K=10000)');

