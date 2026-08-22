clc; clear all; close all;

% =========================================================================
% SIMULADOR DE VARIAÇÃO DE CG POR EFEITO DE SLOSHING EM RESERVATÓRIO 2L
% Autor: [Pedro Henrique Oliveira dos Reis] - Engenharia Aeroespacial (UnB)
% =========================================================================

% =========================================================================
% 1. ENTRADAS DO PROJETO 
% =========================================================================
volume_alvo_litros = 1.39;  % Volume desejado (Litros)
angulo_graus = 10;         % Ângulo de Ataque (graus): positivo = bico para cima

% =========================================================================
% 2. RESOLUÇÃO DO SISTEMA CÚBICO DO BOCAL INVERTIDO: x=0 na ponta do bocal)
% =========================================================================
% x2_inv = 349 - 219 = 130 mm (Transição para o corpo)
% x3_inv = 349 - 349 = 0 mm   (Ponta do bocal)
x2 = 130.00; y2 = 51.4;  
x3 = 0.00;   y3 = 12.00;  

A = [ x2^3,   x2^2,  x2,  1;   
      x3^3,   x3^2,  x3,  1;   
      3*x2^2, 2*x2,  1,   0;   
      3*x3^2, 2*x3,  1,   0 ]; 
B = [y2; y3; 0; -0.2]; % Derivada -0.2 na ponta para abrir no sentido do corpo
coef = A\B;

% =========================================================================
% 3. ALGORITMO DE BUSCA (BISSECÇÃO) - ESTADO INICIAL (A 0 GRAUS)
% =========================================================================
b_min = -200.0; b_max = 200.0;
b_0 = 0;
for iter = 1:100
    b_teste = (b_min + b_max) / 2;
    [vol_teste, ~, ~] = calcular_volume_e_cg(0, b_teste, coef);
    if abs(vol_teste - volume_alvo_litros) < 1e-4
        b_0 = b_teste;
        break;
    end
    if vol_teste < volume_alvo_litros
        b_min = b_teste;
    else
        b_max = b_teste;
    end
    b_0 = b_teste;
end

% =========================================================================
% 4. ALGORITMO DE BUSCA (BISSECÇÃO) - ESTADO INCLINADO
% =========================================================================
b_min = -200.0; b_max = 200.0;
b_encontrado = 0;
for iter = 1:100
    b_teste = (b_min + b_max) / 2;
    [vol_teste, ~, ~] = calcular_volume_e_cg(angulo_graus, b_teste, coef);
    if abs(vol_teste - volume_alvo_litros) < 1e-4
        b_encontrado = b_teste;
        break;
    end
    if vol_teste < volume_alvo_litros
        b_min = b_teste;
    else
        b_max = b_teste;
    end
    b_encontrado = b_teste;
end

% Avaliação dos estados finais
[vol_0, cg_x_0, cg_z_0] = calcular_volume_e_cg(0, b_0, coef);
[vol_final, cg_x_final, cg_z_final] = calcular_volume_e_cg(angulo_graus, b_encontrado, coef);

raio_corpo = 49.70;
altura_na_regua = raio_corpo + b_0; % Nível a 0° no corpo cilíndrico

% =========================================================================
% 5. EXIBIÇÃO DOS RESULTADOS DA GARRAFA
% =========================================================================
disp('==================================================');
disp('   RESULTADOS DA SIMULAÇÃO - GARRAFA INVERTIDA    ');
disp('==================================================');
fprintf('Volume Alvo Solicitado : %.3f Litros\n', volume_alvo_litros);
fprintf('Volume Obtido no Modelo: %.3f Litros\n', vol_final);
fprintf('Ângulo de Ataque (α)   : %d Graus\n', angulo_graus);
fprintf('Parâmetro b da reta    : %.2f mm\n', b_encontrado);
disp('--------------------------------------------------');
fprintf('VALOR PARA VALIDAÇÃO EM BANCADA (A 0°):\n');
fprintf('-> Altura da água na régua: %.1f mm a partir do fundo do corpo\n', altura_na_regua);
disp('--------------------------------------------------');
fprintf('COMPORTAMENTO DO CG LONGITUDINAL (X):\n');
fprintf('-> Posição inicial do CG (0°): %.2f mm (a partir do bocal em x=0)\n', cg_x_0);
fprintf('-> Nova Posição do CG (%d°):  %.2f mm\n', angulo_graus, cg_x_final);
fprintf('-> DESLOCAMENTO DO CG        : %.2f mm\n', cg_x_final - cg_x_0);
disp('--------------------------------------------------');
fprintf('COMPORTAMENTO DO CG VERTICAL (Z):\n');
fprintf('-> Posição do CG em Z (0°):  %.2f mm (em relação ao eixo central)\n', cg_z_0);
fprintf('-> Posição do CG em Z (%d°): %.2f mm\n', angulo_graus, cg_z_final);
fprintf('-> Deslocamento Vertical em Z: %.2f mm\n', cg_z_final - cg_z_0);

% =========================================================================
% 6. INTEGRAÇÃO COM A AERONAVE (Teorema de Varignon - 2 GARRAFAS SIMÉTRICAS)
% =========================================================================
num_garrafas = 2; % Número de tanques/garrafas na aeronave

massa_aeronave_vazia = 4.4;  % Em kg
X_cg_aeronave = 450.0;        % Posição X do CG da aeronave vazia (mm)
Z_cg_aeronave = 120.0;        % Posição Z do CG da aeronave vazia (mm)

% Posição do bocal de AMBAS as garrafas (alinhadas no eixo X e Z):
X_pos_garrafa = 300.0;        % Distância do bico da aeronave até os bocais (mm)
Z_pos_garrafa = 100.0;        % Altura do eixo central das garrafas (mm)

densidade_agua = 1.0; 

% Massa e Volume Totais de Água (2 Garrafas):
vol_agua_total = num_garrafas * vol_final;             % Volume somado em Litros
massa_agua_total = vol_agua_total * densidade_agua;   % Massa somada em kg

% CG da água no referencial da aeronave (idêntico ao de 1 garrafa por simetria)
X_cg_agua_aeronave = X_pos_garrafa + cg_x_final;
Z_cg_agua_aeronave = Z_pos_garrafa + cg_z_final;

% Teorema de Varignon com a Massa Total de Água:
massa_total = massa_aeronave_vazia + massa_agua_total;

X_cg_total = (massa_aeronave_vazia * X_cg_aeronave + massa_agua_total * X_cg_agua_aeronave) / massa_total;
Z_cg_total = (massa_aeronave_vazia * Z_cg_aeronave + massa_agua_total * Z_cg_agua_aeronave) / massa_total;

% =========================================================================
% EXIBIÇÃO DOS RESULTADOS
% =========================================================================
disp('==================================================');
disp('   RESULTADOS COMBINADOS (AERONAVE + 2 GARRAFAS)  ');
disp('==================================================');
fprintf('Número de Garrafas Usadas  : %d unidades\n', num_garrafas);
fprintf('Volume de Água por Garrafa : %.3f Litros\n', vol_final);
fprintf('Volume Total de Água       : %.3f Litros\n', vol_agua_total);
fprintf('Massa Total (Aero + Água)  : %.2f kg\n', massa_total);
disp('--------------------------------------------------');
fprintf('CG Longitudinal (X Total)  : %.2f mm\n', X_cg_total);
fprintf('CG Vertical     (Z Total)  : %.2f mm\n', Z_cg_total);
disp('==================================================');
% =========================================================================
% FUNÇÃO LOCAL DE INTEGRAÇÃO (SEÇÕES INVERTIDAS GEOMETRICAMENTE)
% =========================================================================
function [vol_litros, X_cg, Z_cg] = calcular_volume_e_cg(angulo_deg, b_reta, coef)
    dm = 0.01;
    x_valores = 0:dm:349.00;
    
    % Ângulo positivo -> bico sobe -> água vai para o fundo (x altos) -> m é POSITIVO
    m = tan(degtorad(angulo_deg)); 
    
    volume_total_mm3 = 0;
    soma_momento_x = 0;
    soma_momento_z = 0;
    
    a = coef(1); b = coef(2); c = coef(3); d = coef(4);
    
    for x = x_valores
        % 1. Determina o Raio da Garrafa Invertida
        if x >= 0 && x <= 130.00
            % Bocal (Cúbica)
            R = a*x^3 + b*x^2 + c*x + d;
        elseif x > 130.00 && x <= 279.00
            % Corpo Cilíndrico
            R = 49.70;
        elseif x > 279.00 && x <= 299.00
            % Parábola
            x_orig = 349.00 - x; % Transforma para o referencial original da parábola
            R = -0.00495 * x_orig^2 + 0.495 * x_orig + 37.825;
        elseif x > 299.00 && x <= 349.00
            % Cone do Fundo
            x_orig = 349.00 - x; % Transforma para o referencial original do cone
            R = 38.50 + 0.274 * x_orig;
        else
            R = 0;
        end
        
        if R <= 0; continue; end
        
        % 2. Altura local da lâmina d'água
        h_local = m * x + b_reta;
        
        % 3. Área da Fatia e CG Local Z
        if h_local >= R
            area_fatia = pi * (R^2);
            z_fatia = 0;
        elseif h_local <= -R
            area_fatia = 0;
            z_fatia = 0;
        else
            theta_c = 2 * acos(-h_local / R);
            area_fatia = 0.5 * (R^2) * (theta_c - sin(theta_c));
            z_fatia = - (2/3) * (R^3 * (sin(theta_c / 2))^3) / area_fatia;
        end
        
        % 4. Integração de Riemann
        vol_fatia = area_fatia * dm;
        volume_total_mm3 = volume_total_mm3 + vol_fatia;
        
        soma_momento_x = soma_momento_x + (vol_fatia * x);
        soma_momento_z = soma_momento_z + (vol_fatia * z_fatia);
    end
    
    if volume_total_mm3 > 0
        X_cg = soma_momento_x / volume_total_mm3;
        Z_cg = soma_momento_z / volume_total_mm3;
    else
        X_cg = 0;
        Z_cg = 0;
    end
    
    vol_litros = volume_total_mm3 / 1e6;
end