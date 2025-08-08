
clear,close all

% Define file name and open file for writing
currentDate = datetime('now', 'Format', 'yyyy_MM_dd_HH_mm_ss');
directory = 'C:\Users\david\OneDrive\Área de Trabalho\fct\2023-2024\2ºSemestre\ONL\';
fileName = fullfile(directory, ['Trabalho_1_rank_2_data_', char(currentDate), '.txt']);
fid=fopen(fileName,'w');

% Write header to file
fprintf(fid,'%4s %12s %12s %12s %12s\n','k','x(1)','x(2)','f(x)','||grad_f||');

% Load the function and its gradient from the external file

[f,g,h] = myfunctions();

% Initial values and parameters
x    = [1.2,1.2]';
epsi = 1*10^(-4);
Kmax = 500;
% f    = @(x) 2*x(1)^2+x(2)^2-2*x(1)*x(2)+2*x(1)^3+x(1)^4;
% g    = @(x) [4*x(1)-2*x(2)+6*x(1)^2+4*x(1)^3;2*x(2)-2*x(1)];
% h    = @(x) [4+12*x(1)+12*x(1)^2 -2;-2 2];
k    = 0;
y    = f(x);
Bk_1 = @(sk,Bk,yk) Bk + (yk*yk')/(yk'*sk) - (Bk*sk*sk'*Bk)/(sk'*Bk*sk);%Rank 2
% Bk_1 = @(sk,Bk,yk) Bk + ((yk-Bk*sk)*(yk-Bk*sk)')/((yk-Bk*sk)'*sk );%Rank 1

%line search and backtracking parameters
ro     = 1/2;
alfa0  = 1;
c1     = 10^(-4);
Bk   = eye(2);



% Solve
tic;

while norm(g(x),2) > epsi && k < Kmax
    
%     p = -h(x)\g(x); % -> newton method
    p       = -Bk\g(x);
    
%     Line Search with Backtracking
    alfa = alfa0;
    while f(x + alfa*p) > (f(x) + c1*alfa*g(x)'*p)
       alfa = alfa * ro;     
    end
    x_next  = x + p*alfa;
%     x_next  = x + p;

%   Rank  update
    sk      = x_next - x;
    yk      = g(x_next) - g(x);
    x       = x_next;
    Bk      = Bk_1(sk,Bk,yk);
    
    k       = k + 1;   
    
    fprintf(fid,'%4d %12.4e %12.4e %12.4e %12.4e\n',k, x(1),x(2),f(x),norm(g(x),2));
    plot(k,norm(g(x),2),'b*')
    hold on;

end
tempo_decorrido = toc;


% Write best solution, stopping condition, and other details to file
fprintf(fid,'\nBest Solution:\n');
fprintf(fid,'x_best = [%f, %f]\n', x(1), x(2));
fprintf(fid,'f_best = %.4e\n', f(x));
fprintf(fid,'Norm of gradient at best solution = %.4e\n', norm(g(x),2));
if k < 500 
    fprintf(fid,'Stopping condition: Gradient norm threshold reached\n');
else
    fprintf(fid,'Stopping condition: Maximum iterations reached\n');
end
    
fprintf(fid,'Number of iterations: %d\n', k);
fprintf(fid,'Tempo de execução: %.4f segundos\n', tempo_decorrido);


fclose(fid);

