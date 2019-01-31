%% Plot_Result
clear;clc;

load('Test_Result_NDD.mat');
load('Test_Result_OffLib.mat');
load('Test_Result_OnLib.mat');



%% confidence level
confidence_alpha = 0.05;
z_alpha = norminv(1-confidence_alpha);

% NDD
delt = 1e2;
hald_wid_NDD = zeros(1, N_NDD/delt);
for i = 1:N_NDD/delt
    I_alpha = z_alpha * std(acc_rate_NDD(1:i*delt));
    hald_wid_NDD(i) = I_alpha / (acc_rate_NDD(i*delt)+1e-30);
end
% off line
hald_wid_OffLib = zeros(1, N_OffLib);
for i = 1:N_OffLib
    I_alpha = z_alpha*std(acc_rate_OffLib(1:i));
    hald_wid_OffLib(i) = I_alpha / (acc_rate_OffLib(i)+1e-30);
end

% on line
hald_wid_OnLib = zeros(1, N_OnLib);
for i = 1:N_OnLib
    I_alpha = z_alpha*std(acc_rate_OnLib(1:i));
    hald_wid_OnLib(i) = I_alpha / (acc_rate_OnLib(i)+1e-30);
end
%% x is half-width
N_hf = 15;
test_num_off = zeros(1,N_hf);
test_num_on = zeros(1,N_hf);
half = zeros(1,N_hf);

for i=1:N_hf
    half(i) = 0.2 - 0.01*i;
    
    hald_wid_OffLib_tmp = hald_wid_OffLib;
    hald_wid_OnLib_tmp = hald_wid_OnLib;
    
    [~,N_valid_off] = max(hald_wid_OffLib_tmp);
    [~,N_valid_on] = max(hald_wid_OnLib_tmp);
    
    hald_wid_OffLib_tmp(1:N_valid_off)=1;
    hald_wid_OffLib_tmp(hald_wid_OffLib_tmp>half(i))=0;
    [~,test_num_off(i)] = max(hald_wid_OffLib_tmp);
    
    hald_wid_OnLib_tmp(1:N_valid_on)=1;
    hald_wid_OnLib_tmp(hald_wid_OnLib_tmp>half(i))=0;
    [~,test_num_on(i)] = max(hald_wid_OnLib_tmp);
    test_num_on(i) = test_num_on(i) + 100;
end

%% accuracy
figure;
% offline
fig_NDD = plot(acc_rate_NDD, 'k-', 'linewidth', 2.5);
ax1 = gca;
legend('NDD Evaluation');
set(ax1,'XColor','k','YColor','k');
axis(ax1,[-inf, inf, 0, 2e-3]);
set(gca,'FontName','Times New Roman','FontSize',14);

figure;
x_NDD = [delt:delt:N_NDD];
plot(x_NDD,hald_wid_NDD, 'k-', 'linewidth',2.5);
hold on 
plot(x_NDD,0.2*ones(1,size(x_NDD,2)),'k--','linewidth',2.5);
legend('NDD Evaluation');
xlabel('Test Time','Color','k');
ylabel('Relative Half-width','Color','k');
set(gca,'FontName','Times New Roman','FontSize',14);

figure;
% offline
fig_OffLib = plot(acc_rate_OffLib, 'b-', 'linewidth', 2.5);
ax1 = gca;
set(ax1,'XColor','b','YColor','k');
axis(ax1,[-inf, inf, 0, 2e-3]);
set(gca,'FontName','Times New Roman','FontSize',14);

% online
ax2 = axes('Position',get(ax1,'Position'),'XAxisLocation','top','color','none','XColor','r','YColor','none');
hold on
fig_OnLib = plot(acc_rate_OnLib, 'r-', 'linewidth',2.5,'Parent',ax2);
legend([fig_OffLib,fig_OnLib],'Offline Library Evaluation','Online Library Evaluation');
xlabel(ax1,'Test Time','Color','k');
ylabel(ax1,'Accident Rate','Color','k');
axis(ax2,[-inf, inf, 0, 2e-3]);
set(gca,'FontName','Times New Roman','FontSize',14);

% plot
figure;
% off line
fig_OffLib_hw = plot(hald_wid_OffLib(1:3e3), 'b-', 'linewidth', 2.5);
ax1 = gca;
set(ax1,'XColor','b','YColor','k');
axis(ax1,[-inf, inf, 0, 1]);
set(gca,'FontName','Times New Roman','FontSize',14);
% online
ax2 = axes('Position',get(ax1,'Position'),'XAxisLocation','top','color','none','XColor','r','YColor','none');
hold on
N_OnLib_plot = 300;
fig_OnLib_hw = plot(hald_wid_OnLib(1:N_OnLib_plot), 'r-', 'linewidth',2.5,'Parent',ax2);
hold on;
plot(1:N_OnLib_plot,0.2*ones(1,N_OnLib_plot),'k--','linewidth',2.5);
legend([fig_OffLib_hw,fig_OnLib_hw],'Offline Library Evaluation','Online Library Evaluation');
xlabel(ax1,'Test Time','Color','k');
ylabel(ax1,'Relative Half-width','Color','k');
axis(ax2,[-inf, inf, 0, 1]);
set(gca,'FontName','Times New Roman','FontSize',14);

figure;
plot(half,test_num_off,'b','linewidth',3);
hold on
plot(half,test_num_on,'r','linewidth',3);
legend('Offline Library Evaluation','Online Library Evaluation');
xlabel('Relative Half-width Requirement', 'fontsize',16);
ylabel('Testing Time Requirement','fontsize',16);
set(gca,'xdir','reverse');
set(gca,'FontName','Times New Roman','FontSize',14);