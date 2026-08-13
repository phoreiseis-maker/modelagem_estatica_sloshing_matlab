
# Simulador Numérico de Variação de CG por Sloshing em Carga Líquida

![MATLAB](https://img.shields.io/badge/MATLAB-R2025a-blue)
![Engenharia Aeroespacial](https://img.shields.io/badge/Campo-Engenharia_Aeroespacial-orange)

Algoritmo desenvolvido em **MATLAB** para calcular estaticamente o deslocamento do Centro de Gravidade (CG) longitudinal ($X$) e vertical ($Z$) de uma aeronave provocado pelo efeito de *sloshing* (deslocamento da lâmina d'água) em um reservatório axissimétrico de 2 Litros (geometria baseada em garrafa PET de 2L).

## Destaques da Modelagem Téorica e Numérica

- **Geometria Discontínua por Seções:** Modelagem do reservatório dividida em 4 regiões geométricas distintas (bocal cúbico, corpo cilíndrico, transição parabólica e fundo cônico).
- **Condições de Contorno (Sistema Linear $4 \times 4$):** Solução do perfil do bocal por interpolação cúbica para garantir continuidade de derivada na abertura ($\frac{dy}{dx} = -0,2$).
- **Busca da Lâmina d'Água (Método da Bissecção):** Algoritmo iterativo para encontrar a altura do nível do fluido ($h$) em função do ângulo de ataque ($\alpha$), garantindo a conservação da massa/volume do fluido com tolerância de $10^{-4}\text{ L}$.
- **Integração de Riemann e Geometria de Fatias:** Cálculo de volume e centroides ($z_{\text{fatia}}$) através da integração por fatias circulares parciais.
- **Integração Veicular (Teorema de Varignon):** Combinação dinâmica dos momentos da estrutura vazia da aeronave com a massa do combustível/fluido líquido.

---

## Formulação Matemática

### 1. Sistema do Bocal Cúbico
O perfil do bocal é obtido pela resolução do sistema matricial $A \cdot x = B$:

$$
\begin{bmatrix} 
x_2^3 & x_2^2 & x_2 & 1 \\ 
x_3^3 & x_3^2 & x_3 & 1 \\ 
3x_2^2 & 2x_2 & 1 & 0 \\ 
3x_3^2 & 2x_3 & 1 & 0 
\end{bmatrix} 
\begin{bmatrix} a \\ b \\ c \\ d \end{bmatrix} = 
\begin{bmatrix} y_2 \\ y_3 \\ 0 \\ -0,2 \end{bmatrix}
$$

### 2. Segmento Circular Parcial e CG Local
Para uma determinada altura $h_{\text{local}}$ da lâmina d'água sob inclinação $\alpha$:

$$\theta_c = 2 \arccos\left(-\frac{h_{\text{local}}}{R}\right)$$

$$A_{\text{fatia}} = \frac{1}{2} R^2 (\theta_c - \sin\theta_c)$$

$$z_{\text{fatia}} = -\frac{2}{3} \frac{R^3 \sin^3(\theta_c / 2)}{A_{\text{fatia}}}$$

---

## 🛠️ Aplicação Prática

O algoritmo permite ajustar o **volume alvo** para qualquer valor até a capacidade total da garrafa (2L) e simular ângulos de ataque ($\alpha$) positivos e negativos. Os dados gerados fornecem o valor exato de **altura na régua a 0°**, permitindo a validação experimental em bancada antes do voo.
