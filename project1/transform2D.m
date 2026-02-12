function outputImage = transform2D(inputImage, transformType, params)
% transform2D - Apply 2D geometric transformations to images
%
% This function applies various 2D geometric transformations including
% rotation, reflection, and scaling to image data.
%
% Inputs:
%   inputImage   - Input image matrix (grayscale or RGB)
%   transformType - String specifying transformation type:
%                   'rotate': rotation by angle (params = angle in degrees)
%                   'flipH': horizontal flip (params ignored)
%                   'flipV': vertical flip (params ignored)
%                   'reflect': reflection across line (params = angle in degrees)
%                   'scale': scaling (params = [scaleX, scaleY])
%   params       - Parameters for the transformation
%                  For 'rotate': angle in degrees
%                  For 'reflect': angle in degrees
%                  For 'scale': [scaleX, scaleY]
%                  For 'flipH' or 'flipV': ignored
%
% Outputs:
%   outputImage  - Transformed image matrix
%
% Example:
%   rotated = transform2D(img, 'rotate', 90);
%   flipped = transform2D(img, 'flipH', []);

% Validate inputs
if nargin < 2
    error('transform2D requires at least 2 arguments');
end

if ~ischar(transformType) && ~isstring(transformType)
    error('transformType must be a string');
end

% Apply transformation based on type
if strcmp(transformType, 'rotate')
    if nargin < 3 || isempty(params)
        error('Rotation requires angle parameter');
    end
    angle = params;
    outputImage = imrotate(inputImage, angle, 'bilinear', 'crop');
    
elseif strcmp(transformType, 'flipH')
    % Horizontal flip (flip along vertical axis)
    outputImage = flip(inputImage, 2);
    
elseif strcmp(transformType, 'flipV')
    % Vertical flip (flip along horizontal axis)
    outputImage = flip(inputImage, 1);
    
elseif strcmp(transformType, 'reflect')
    % Reflection across a line at specified angle
    if nargin < 3 || isempty(params)
        error('Reflection requires angle parameter');
    end
    angle = params;
    % Rotate, flip, then rotate back
    temp = imrotate(inputImage, -angle, 'bilinear', 'crop');
    temp = flip(temp, 2);
    outputImage = imrotate(temp, angle, 'bilinear', 'crop');
    
elseif strcmp(transformType, 'scale')
    % Scaling transformation
    if nargin < 3 || isempty(params) || length(params) < 2
        error('Scaling requires [scaleX, scaleY] parameters');
    end
    scaleX = params(1);
    scaleY = params(2);
    [rows, cols, channels] = size(inputImage);
    newRows = round(rows * scaleY);
    newCols = round(cols * scaleX);
    outputImage = imresize(inputImage, [newRows, newCols], 'bilinear');
    
else
    error('Unknown transformation type. Supported: ''rotate'', ''flipH'', ''flipV'', ''reflect'', ''scale''');
end

end
