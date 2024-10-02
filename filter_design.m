function filter_design
  pkg load signal 
  pkg load symbolic
  warning('off', 'all');
  clear;clc;close all;
  
  printf(['\n\n-------------------------------------------------------\n', ...
  'Bienvenido al script de diseño de filtros DSP. ', ...
  '\nEste script se utliza para el calculo de los filtros.', ...
  ' \nSigue las instrucciones para obtener los mejores resultados. \n', ...
  '-------------------------------------------------------\n\n']);

  [fmin, fmax] = voice_range('testamento1.wav');

  printf(['El rango de la voz es de ', num2str(fmin),' Hz a ', ... 
  num2str(fmax), 'Hz']);
 
  printf(['\n\n-------------------------------------------------------\n', ...
  'Filtro Pasabajas de orden 2 \n']);
  [b,a,zero,pole] = filter_lowpass_order_2(fmin,fmax,Fs=44100);

  % Mostrar los coeficientes
  disp('Coeficientes b:');
  disp(b);
  disp('Coeficientes a:');
  disp(a);

  printf(['\n\n-------------------------------------------------------\n', ...
  'Filtro Muesca de orden 2 \n']);
  [b,a,zero,pole] = band_stop_filter_order_2(fmin,fmax,Fs=44100);
  % Mostrar los coeficientes
  disp('Coeficientes b:');
  disp(b);
  disp('Coeficientes a:');
  disp(a);

  printf(['\n\n-------------------------------------------------------\n', ...
  'Filtro Pasa Bandas de orden 2 \n']);
  [b,a,zero,pole] = band_pass_filter_order_2(fmin,fmax,Fs=44100);
  % Mostrar los coeficientes
  disp('Coeficientes b:');
  disp(b);
  disp('Coeficientes a:');
  disp(a);

  printf(['\n\n-------------------------------------------------------\n', ...
  'Filtro Pasa Altas de orden 2 \n']);
  [b,a,zero,pole] = filter_highpass_order_2(fmin,fmax,Fs=44100);
  % Mostrar los coeficientes
  disp('Coeficientes b:');
  disp(b);
  disp('Coeficientes a:');
  disp(a);



endfunction

function [fmin, fmax] = voice_range(filename)
  % Load the audio file
  [y, Fs] = audioread(filename);
  y = mean(y, 2);  %  from stereo to mono audio

  % Compute the frequency spectrum
  Y = fft(y);
  L = length(y);
  f = Fs*(0:(L/2))/L;
  P = abs(Y/L);

  % Determine the energy threshold
  threshold = max(P) * 0.1;

  % Find where the spectrum exceeds the threshold
  freq_without_noise = find(P(1:L/2+1) > threshold);

  % Determine the frequency range of the voice
  fmin = f(min(freq_without_noise));
  fmax = f(max(freq_without_noise));
  


  figure('Name', 'Espectro de Frecuencia de la Voz');
  plot(f, P(1:L/2+1));
  xlim([0 8000]);  % Only show the frequency range from 0 to 8000 Hz
  set_plot_style('Espectro de Frecuencia de la Voz','Frecuencia (Hz)', ...
  'Amplitud');
  hold on;
  line([fmin fmin], [0 max(P)], 'Color', 'red', 'LineStyle', '--');
  line([fmax fmax], [0 max(P)], 'Color', 'red', 'LineStyle', '--');
  legendFontSize = 12;
  legend('Espectro', [num2str(fmin) ' Hz - ' num2str(fmax) ' Hz']);
  hold off;

endfunction

function set_plot_style(title_str = "", x_label = "n", y_label = "y[n]")
    %SET_PLOT_STYLE Sets a standardized style for plots.
    %
    %   set_plot_style() applies a standardized style to the current plot, 
    %   including enabling the grid, setting a default font size, and 
    %   configuring the x and y labels. An optional title string can be 
    %   provided, which will be interpreted in TeX format.
    %
    %   Syntax:
    %       set_plot_style(title_str)
    %
    %   Input:
    %       title_str - (Optional) A string specifying the title of the plot. 
    %                   Default is an empty string.
    %
    %   Example:
    %       plot(1:10, sin(1:10));
    %       set_plot_style("Sine Wave");
    %
    grid on;
    set(gca, "FontSize", 24);
    title(title_str, "interpreter", 
    "tex");
    xlabel(x_label, "FontSize", 24);
    ylabel(y_label, "FontSize", 24);
endfunction

function [b,a,zero,pole] = filter_lowpass_order_2(fmin,fmax,Fs=44100)
  % Filtro Pasabajas de orden 2

  wc = 2*pi*fmax*1.25/Fs;

  syms p real;
  b0 =  (1-p)^2/4;
  eq = - 1/sqrt(2) + b0 * abs((e^(i*wc)+1)^2) / abs((e^(i*wc)-p)^2);

  solutions = solve(eq, p);
  p = eval(real(solutions));
  p = p(p<1);

  % Soluciones de p
  printf('Soluciones\n\np:\n');
  disp(p);

  % Calcula b0
  b0 = (1-p)^2/4;
  disp('b0:');
  disp(b0);

  % Coeficientes de H(z) considerando b0
  zero = [-1 -1]; % un cero de orden 2 en -1
  pole = [p p]; % p es de segundo orden

  % Obtener la función de transferencia
  [b,a] = zp2tf(zero, pole, b0); 


  % Obtener la respuesta en frecuencia
  [H, f] = freqz(b, a, 4096, Fs);

  % Dibujar el diagrama de Bode
  figure('Name', 'Filtro Pasabajas de orden 2');
  plot(f, 20*log10(abs(H)));
  set_plot_style('Diagrama de Bode Filtro Pasabajas de orden 2', ...
  'Frecuencia (Hz)', 'Magnitud (dB)');
  hold on;
  yLimits = get(gca, 'ylim'); % Obtener los límites actuales del eje Y

  % Dibujar las líneas para fmin, fmax, y frecuencia de corte
  lineWidth = 2;
  line([fmin fmin], yLimits, 'Color', 'red', 'LineStyle', '--', ...
  'LineWidth', lineWidth);
  line([fmax fmax], yLimits, 'Color', 'red', 'LineStyle', '--', ...
  'LineWidth', lineWidth);
  line([1.25*fmax 1.25*fmax], yLimits, 'Color', 'green', 'LineStyle', ...
  '--', 'LineWidth', lineWidth);

  legendFontSize = 12;
  lgd = legend('Espectro', [num2str(fmin) ' Hz - ' num2str(fmax) ' Hz'], ...
  ['wc = ' num2str(fmax*1.25) ' Hz ']);
  set(lgd, 'FontSize', legendFontSize);
  hold off;
  grid on;



endfunction

function [b,a,zero,pole] = band_stop_filter_order_2(fmin,fmax,Fs=44100)
  % Filtro Muesca de orden 3
  w0 = 2*pi*(fmin+fmax)/2*1/Fs;

  syms r real;
  eq = (1-2*cos(w0)+1)/(1-2*r*cos(w0)+r^2) == (1+2*cos(w0)+1)/(1+2*r*cos(w0)+r^2);
  solutions = solve(eq,r);
  r = eval(real(solutions));
  r = r(r<1);

  % Soluciones de r
  printf('Soluciones\n\nr:\n');
  disp(r);

  % Given parameters and coefficients
  zero = [exp(i*w0) exp(-i*w0)];
  pole = [r*exp(i*w0) r*exp(-i*w0)];
  b0 = ((1-2*cos(w0)+1)/(1-2*r*cos(w0)+r^2))^(-1);
  [b,a] = zp2tf(zero, pole, b0); 

  % Obtain frequency response
  [H, f] = freqz(b, a, 4096, Fs);

  % Normalize H by its max value
  maxH = max(abs(H));
  b = b / maxH;
  a = a;  % 'a' coefficients remain unchanged

  % Re-generate 'b' and 'a' after normalization
  [b,a] = zp2tf(zero, pole, b0 / maxH);

  % Dibujar el diagrama de Bode
  figure('Name', 'Filtro Muesca de orden 2');
  plot(f, 20*log10(abs(H)));
  set_plot_style('Diagrama de Bode Filtro Muesca de orden 2', ...
  'Frecuencia (Hz)', 'Magnitud (dB)');
  hold on;
  yLimits = get(gca, 'ylim'); % Obtener los límites actuales del eje Y

  % Dibujar las líneas para fmin, fmax, y frecuencia de corte
  lineWidth = 2;
  line([fmin fmin], yLimits, 'Color', 'red', 'LineStyle', '--', ...
  'LineWidth', lineWidth);
  line([fmax fmax], yLimits, 'Color', 'red', 'LineStyle', '--', ...
  'LineWidth', lineWidth);
  line([(fmin+fmax)/2 (fmin+fmax)/2], yLimits, 'Color', 'green', 'LineStyle', ...
  '--', 'LineWidth', lineWidth);

  legendFontSize = 12;
  lgd = legend('Espectro', [num2str(fmin) ' Hz - ' num2str(fmax) ' Hz'], ...
  ['w0 = ' num2str((fmin+fmax)/2) ' Hz ']);
  set(lgd, 'FontSize', legendFontSize);
  xlim([0 3000]);  % Only show the frequency range from 0 to 8000 Hz
  hold off;
  grid on;

endfunction

function [b a zero pole] = band_pass_filter_order_2(fmin,fmax,Fs=44100)
  % Filtro Pasa Banda de orden 2
  w0 = 2*pi*(fmin+fmax)/2*1/Fs;
  wc = 2*pi*fmax*1/Fs;

  temp1 = abs(1-exp(-i*2*w0));
  temp2 = abs(1-exp(-i*2*wc));

  syms r real;
  b0 = abs(1-2*r*cos(w0)*exp(-i*w0)+r^2*exp(-i*2*w0))/temp1;
  eq = 1/sqrt(2) == b0*temp2/abs(1-2*r*cos(w0)*exp(-i*wc)+r^2*exp(-i*2*wc));

  r_value = vpasolve(eq, r, [0 1]);
  r = double(r_value);

  % Soluciones de r
  printf('Soluciones\n\nr:\n');
  disp(r);

  % Coeficientes de H(z) considerando b0
  zero = [1 -1];
  pole = [r*e^(i*w0) r*e^(-i*w0)];
  b0 = abs((1-2*r*cos(w0)*e^(-j*w0)+r^2*e^(-j*2*w0))/(1-e^(-j*2*w0)));
  % Obtener la-described de transferencia
  [b,a] = zp2tf(zero, pole, b0);

  % Obtener la respuesta en frecuencia
  [H, f] = freqz(b, a, 4096, Fs);



  % Dibujar el diagrama de Bode
  figure('Name', 'Filtro  Pasa Bandas de orden 2');
  plot(f, 20*log10(abs(H)));
  set_plot_style('Diagrama de Bode Filtro  Pasa Bandas de orden 2', ...
  'Frecuencia (Hz)', 'Magnitud (dB)');
  hold on;
  yLimits = get(gca, 'ylim'); % Obtener los límites actuales del eje Y

  % Dibujar las líneas para fmin, fmax, y frecuencia de corte
  lineWidth = 2;
  line([fmin fmin], yLimits, 'Color', 'red', 'LineStyle', '--', ...
  'LineWidth', lineWidth);
  line([fmax fmax], yLimits, 'Color', 'red', 'LineStyle', '--', ...
  'LineWidth', lineWidth);
  line([(fmin+fmax)/2 (fmin+fmax)/2], yLimits, 'Color', 'green', 'LineStyle', ...
  '--', 'LineWidth', lineWidth);
  line([fmax fmax], yLimits, 'Color', 'blue', 'LineStyle', ...
  '--', 'LineWidth', lineWidth-1);

  legendFontSize = 12;
lgd = legend('Espectro', [num2str(fmin) ' Hz - ' num2str(fmax) ' Hz'], ...
['wc = ' num2str(fmax) ' Hz '], ['w0 = ' num2str((fmin+fmax)/2) ' Hz ']);
set(lgd, 'FontSize', legendFontSize);
hold off;
grid on;

endfunction


function [b,a,zero,pole] = filter_highpass_order_2(fmin,fmax,Fs=44100)
  fmin = fmin*8;
  % Filtro Pasa Altas de orden 2
  wc = 2*pi*fmin*1/Fs;

  syms p;
  b0 =  (1+p)^2/4;
  eq = 1/sqrt(2) == b0 * (e^(i*wc)-1)^2 / (e^(i*wc)-p)^2;

  solutions = solve(eq, p);
  p = eval(real(solutions));
  p = p(1);

  % Soluciones de p
  printf('Soluciones\n\np:\n');
  disp(p);

  % Calcula b0
  b0 = (1+p)^2/4;
  disp('b0:');
  disp(b0);

  % Coeficientes de H(z) considerando b0
  zero = [1 1]; % un cero de orden 2 en 1
  pole = [p p]; % p es de segundo orden

  % Obtener la función de transferencia
  [b,a] = zp2tf(zero, pole, b0); 


  % Obtener la respuesta en frecuencia
  [H, f] = freqz(b, a, 4096, Fs);

  % Dibujar el diagrama de Bode
  figure('Name', 'Filtro Pasa Altas de orden 2');
  plot(f, 20*log10(abs(H)));
  set_plot_style('Diagrama de Bode Filtro Pasa Altas de orden 2', ...
  'Frecuencia (Hz)', 'Magnitud (dB)');
  hold on;
  yLimits = get(gca, 'ylim'); % Obtener los límites actuales del eje Y

  % Dibujar las líneas para fmin, fmax, y frecuencia de corte
  lineWidth = 2;
  line([fmin fmin], yLimits, 'Color', 'red', 'LineStyle', '--', ...
  'LineWidth', lineWidth);
  line([fmax fmax], yLimits, 'Color', 'red', 'LineStyle', '--', ...
  'LineWidth', lineWidth);
  line([fmin fmin], yLimits, 'Color', 'green', 'LineStyle', ...
  '--', 'LineWidth', lineWidth);

  legendFontSize = 12;
  lgd = legend('Espectro', [num2str(fmin) ' Hz - ' num2str(fmax) ' Hz'], ...
  ['wc = ' num2str(fmin) ' Hz ']);
  set(lgd, 'FontSize', legendFontSize);
  xlim([0 1000]);
  hold off;
  grid on;

endfunction