function out = my_imrotate(img, angle_deg, ~, ~)
% my_imrotate - Rotate image without Image Processing Toolbox
% Usage: out = my_imrotate(img, angle_deg, 'bilinear', 'crop')
% angle_deg: rotation angle in degrees (positive = counterclockwise).

angle_deg = mod(angle_deg, 360);
if angle_deg > 180
    angle_deg = angle_deg - 360;
end

% Multiples of 90: use rot90 (same size for square; crop for non-square)
if abs(mod(angle_deg, 90)) < 1e-6
    k = round(angle_deg / 90);
    out = rot90(img, k);
    [H, W, C] = size(img);
    [Ho, Wo, ~] = size(out);
    if Ho ~= H || Wo ~= W
        % Crop center to original size
        out = crop_center(out, H, W);
    end
    return;
end

% Arbitrary angle: use interp2 (bilinear)
[M, N, numCh] = size(img);
if numCh == 1
    out = rotate_2d(img, angle_deg, M, N);
else
    out = zeros(M, N, numCh, class(img));
    for c = 1:numCh
        out(:,:,c) = rotate_2d(img(:,:,c), angle_deg, M, N);
    end
end
end

function out = rotate_2d(I, angle_deg, M, N)
rad = angle_deg * pi / 180;
cx = (N + 1) / 2;
cy = (M + 1) / 2;
[Xq, Yq] = meshgrid(1:N, 1:M);
% Inverse rotation: source (x,y) for each output pixel
Xs =  cos(rad) * (Xq - cx) + sin(rad) * (Yq - cy) + cx;
Ys = -sin(rad) * (Xq - cx) + cos(rad) * (Yq - cy) + cy;
cl = class(I);
if isinteger(I)
    I = double(I);
end
out = interp2(1:N, 1:M, I, Xs, Ys, 'linear', 0);
if strcmp(cl, 'uint8')
    out = uint8(max(0, min(255, round(out))));
elseif strcmp(cl, 'uint16')
    out = uint16(max(0, min(65535, round(out))));
end
end

function B = crop_center(A, H, W)
[Ha, Wa, C] = size(A);
if C > 1
    B = zeros(H, W, C, class(A));
    for c = 1:C
        B(:,:,c) = crop_center(A(:,:,c), H, W);
    end
    return;
end
r1 = max(1, floor((Ha - H)/2) + 1);
c1 = max(1, floor((Wa - W)/2) + 1);
r2 = min(Ha, r1 + H - 1);
c2 = min(Wa, c1 + W - 1);
B = A(r1:r2, c1:c2);
if size(B,1) < H || size(B,2) < W
    B2 = zeros(H, W, class(A));
    B2(1:size(B,1), 1:size(B,2)) = B;
    B = B2;
end
end
