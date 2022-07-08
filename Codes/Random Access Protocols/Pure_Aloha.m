clc 
close all

% T = throughput
% p_X_0 = probability that no packets are generated during the time [−τ, τ ]
% L = total offered load
L = 0:0.001:2;
p_X_0 = exp(-2*L);
T = L.*p_X_0;

figure(1)
plot(L,T);
ylabel("T(Throughout)");
xlabel("L(load)"); 
title('Throughput of Pure Aloha');

% E = Efficiency, N = Number of Nodes, p = Probability of retransmission
N = 10;
p = 0:0.001:1;
E = zeros(size(p));
E = N.*p.*power((1-p),2*(N-1));
figure(2)
subplot(3,1,1);
plot(p,E);
ylabel("Efficiency for N = 10");
xlabel("p->"); 

N = 20;
E = N.*p.*power((1-p),2*(N-1));

subplot(3,1,2);
plot(p,E);
ylabel("Efficiency for N = 20");
xlabel("p->"); 

N = 30;
E = N.*p.*power((1-p),2*(N-1));

subplot(3,1,3);
plot(p,E);
ylabel("Efficiency for N = 20");
xlabel("p->"); 
