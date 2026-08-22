clc; clear all; close all;

% =========================================================================
% 1. DISCRETIZAÇÃO LONGITUDINAL
% =========================================================================
dm = 0.01; 
x = 0:dm:349.00;
y = zeros(size(x)); % Vetor para armazenar os raios em cada x

% =========================================================================
% 2. SISTEMA CÚBICO DO BOCAL (INVERTIDO: x=0 no bocal, x=130 no corpo)
% =========================================================================
x3 = 0.00;   y3 = 12.00; % Ponta do bocal (abertura menor em x=0)
x2 = 130.00; y2 = 51.40; % Transição para o corpo (raio maior em x=130)

A = [ x2^3,   x2^2,  x2,  1;   % y(130) = 51.4
      x3^3,   x3^2,  x3,  1;   % y(0)   = 12.0
      3*x2^2, 2*x2,  1,   0;   % y'(130) = 0  (transição suave para o cilindro)
      3*x3^2, 2*x3,  1,   0 ]; % y'(0)   = -0.2 (abertura do bocal)

B = [y2; y3; 0; -0.2];
coef = A\B;

a = coef(1);
b = coef(2);
c = coef(3);
d = coef(4);

% =========================================================================
% 3. MAPEAMENTO GEOMÉTRICO DAS SEÇÕES (GARRAFA INVERTIDA)
% =========================================================================
for i = 1:length(x)
    xi = x(i);
    
    if xi >= 0 && xi <= 130.00
        % Bocal Cúbico (0 a 130 mm)
        R = a*xi^3 + b*xi^2 + c*xi + d;
        
    elseif xi > 130.00 && xi <= 279.00
        % Corpo Cilíndrico (130 a 279 mm)
        R = 49.70;
        
    elseif xi > 279.00 && xi <= 299.00
        % Parábola (279 a 299 mm)
        x_orig = 349.00 - xi; % Ajusta o referencial
        R = -0.00495 * (x_orig)^2 + 0.495 * x_orig + 37.825;
        
    elseif xi > 299.00 && xi <= 349.00
        % Cone do Fundo (299 a 349 mm)
        x_orig = 349.00 - xi; % Ajusta o referencial
        R = 38.50 + 0.274 * x_orig;
    else
        R = 0;
    end
    
    y(i) = R; % Armazena o raio calculado no vetor de perfil y
end

% =========================================================================
% 4. CÁLCULO DO VOLUME TOTAL DA GARRAFA VAZIA
% =========================================================================
volume_mm3 = sum(pi * (y.^2) * dm); 
volume_litros = volume_mm3 / 1e6;

disp('=======================================');
fprintf('Volume estimado: %.3f litros\n', volume_litros);
disp('=======================================');

% =========================================================================
% 5. PLOT DO PERFIL 2D COMPLETO
% =========================================================================
figure('Color', [1 1 1]);
plot(x, y, 'b', 'LineWidth', 2); hold on;
plot(x, -y, 'b', 'LineWidth', 2); % Contorno inferior simétrico
plot([0 349], [0 0], 'k--', 'LineWidth', 0.8); % Eixo de simetria

grid on;
title('Perfil Interno da Garrafa Invertida (Bocal em x = 0)');
xlabel('Altura (x) em mm');
ylabel('Raio (y) em mm');
axis equal;
