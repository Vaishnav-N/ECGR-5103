function error = matchError_Abell1689(Isrc, Itarget, unknown_vec)
% matchError_Abell1689 - Sum of squared differences between source and target after rotation.
%
% Inputs:
%   Isrc        - Source image
%   Itarget     - Reference image
%   unknown_vec - Rotation angle (degrees)
%
% Outputs:
%   error       - Sum of squared differences

INVALID_PIXEL = -1;
theta = unknown_vec(1);

Icurrent = imrotate(Isrc, theta, 'bilinear', 'crop');

target_dims = size(Itarget);
Icurrent_vec = double(Icurrent(:));
Itarget_vec = double(Itarget(:));

if length(Icurrent_vec) ~= length(Itarget_vec)
    Icurrent = imresize(Icurrent, target_dims(1:2), 'bilinear');
    Icurrent_vec = double(Icurrent(:));
end

Icurrent_vec(Icurrent_vec == 0) = INVALID_PIXEL;

valid_location_indices = find(Icurrent_vec ~= INVALID_PIXEL);

if ~isempty(valid_location_indices)
    error_vec = Icurrent_vec(valid_location_indices) - Itarget_vec(valid_location_indices);
    error = error_vec' * error_vec;
else
    error = Inf;
end

end
