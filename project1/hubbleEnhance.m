function outputImage = hubbleEnhance(enhanceType, inputImage, K)
% hubbleEnhance - Apply intensity transformation to Hubble Space Telescope images
%
% This function applies various intensity transformations to enhance
% astronomical images. The function supports power-law and inverse
% hyperbolic sine transformations.
%
% Inputs:
%   enhanceType  - String specifying the enhancement type: 'powK' or 'asinhK'
%   inputImage   - Matrix of image data (NxMx3) containing RGB components
%                  Values should be normalized to [0,1]
%   K            - Scalar parameter controlling the enhancement behavior
%                  For 'powK': exponent value (power)
%                  For 'asinhK': normalizing constant
%
% Outputs:
%   outputImage  - Enhanced image matrix (NxMx3) with values in [0,1]
%
% Example:
%   outputImage = hubbleEnhance('powK', inputImage, 0.11);
%   outputImage = hubbleEnhance('asinhK', inputImage, 10000);

% Validate inputs
if nargin ~= 3
    error('hubbleEnhance requires exactly 3 arguments');
end

if ~ischar(enhanceType) && ~isstring(enhanceType)
    error('enhanceType must be a string');
end

if ~isnumeric(inputImage)
    error('inputImage must be numeric');
end

if ~isscalar(K) || ~isnumeric(K)
    error('K must be a numeric scalar');
end

% Initialize output image with same size as input
outputImage = zeros(size(inputImage));

% Apply the requested enhancement
if strcmp(enhanceType, 'powK')
    % Power-law transformation: Inew(x,y) = (imageData(x,y))^K
    outputImage = inputImage .^ K;
    
elseif strcmp(enhanceType, 'asinhK')
    % Inverse hyperbolic sine transformation: 
    % Inew(x,y) = asinh(imageData(x,y)*K)/asinh(K)
    outputImage = asinh(inputImage * K) / asinh(K);
    
else
    error('Unknown enhancement type. Supported types: ''powK'', ''asinhK''');
end

% Ensure output is in valid range [0,1]
outputImage = max(0, min(1, outputImage));

end
