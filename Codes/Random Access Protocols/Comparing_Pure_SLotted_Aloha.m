clc 
close all

% T = throughput
% p_X_0 = probability that no packets are generated during the time [−τ, τ ]
% L = total offered load in pure aloha
L = 0:0.001:2;
p_X_0 = exp(-2*L);
T_Pure = L.*p_X_0;

% T = throughput
% p_X_0 = probability that no packets are generated during the time [0,τ ]
% L = total offered load in slotted aloha
L = 0:0.001:2;
p_X_0 = exp(-L);
T_Slotted = L.*p_X_0;

plot(L,T_Pure);
ylabel("T(Throughout)");
xlabel("L(load)"); 
title('Throughput of Pure and Slotted ALOHA');
hold on 

plot(L,T_Slotted);
hold off
legend('Pure Aloha','SLotted Aloha')



