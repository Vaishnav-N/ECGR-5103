% project1_part1_answers.m
% Part 1: RGB association, filter frequency response, and enhancement curves.

clear all;

%% RGB association (nearest-neighbor by wavelength)
fprintf('Part 1 - RGB association:\n');
fprintf('  F475W (475 nm) -> Blue\n');
fprintf('  F625W (625 nm) -> Green\n');
fprintf('  F775W (775 nm) -> Red\n\n');

%% Filter wavelengths and gaps
fprintf('Filter wavelengths (nm): F475W=475, F625W=625, F775W=775\n');
fprintf('  Visible range: 400-700 nm. F775W is near-IR (775 nm).\n');
fprintf('  Gap between F475W and F625W: ~500-550 nm\n');
fprintf('  Gap between F625W and F775W: ~650-700 nm\n\n');

%% Input-output curves: s=r^0.14 and s=asinh(r*13000)/asinh(13000)
r = 0:0.01:1;
s_powK = r.^0.14;
s_asinhK = asinh(r*13000) / asinh(13000);

figure('Name', 'Part 1 Question 3: Enhancement Function Curves', ...
       'Position', [100, 100, 1000, 700]);
plot(r, s_powK, 'b-', 'LineWidth', 2.5);
hold on;
plot(r, s_asinhK, 'r-', 'LineWidth', 2.5);
xlabel('Input Intensity, r', 'FontSize', 12);
ylabel('Output Intensity, s', 'FontSize', 12);
title('Input-Output Response Curves for Enhancement Functions', 'FontSize', 14);
legend('s = r^{0.14}', 's = asinh(r*13000)/asinh(13000)', 'Location', 'best', 'FontSize', 11);
grid on;
hold off;

fprintf('Enhancement curve samples:\n');
fprintf('  r=0.01: powK=%.4f, asinhK=%.4f\n', 0.01^0.14, asinh(0.01*13000)/asinh(13000));
fprintf('  r=0.10: powK=%.4f, asinhK=%.4f\n', 0.1^0.14, asinh(0.1*13000)/asinh(13000));
fprintf('  r=0.50: powK=%.4f, asinhK=%.4f\n', 0.5^0.14, asinh(0.5*13000)/asinh(13000));
fprintf('  r=0.90: powK=%.4f, asinhK=%.4f\n', 0.9^0.14, asinh(0.9*13000)/asinh(13000));
fprintf('  r=1.00: powK=%.4f, asinhK=%.4f\n', 1.0, 1.0);
