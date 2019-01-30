%% plot IDM library

clear;clc;

%% Library Generation 
% input NDD
Para_first2level;
NDD = table;

% F_IDModel;
F_FVDModel;
min_epislon = 0.05;

% obtain ground truth: Switch_ACC performace and optimal library
F_ACCModel;
F_CAV = F_FVDM;
Lib_Opt = Library_Generation(table,F_CAV,min_epislon);

%% plot
figure;
imagesc(y_label, x_label, Lib_Opt);
axis xy
xlabel('Range Rate (m/s)');
ylabel('Range (m)');
colorbar;
set(gca,'FontName','Times New Roman','FontSize',14);

%% region
figure;
region = Lib_Opt;
region(region>2.9e-5)=1;
region(region<=2.9e-5)=0;
lib_size = sum(sum(region))
imagesc(y_label, x_label, region);
axis xy
xlabel('Range Rate (m/s)');
ylabel('Range (m)');
set(gca,'FontName','Times New Roman','FontSize',14);

%% FVDM
figure;
imagesc(y_label, x_label, F_FVDM);
axis xy
xlabel('Range Rate (m/s)');
ylabel('Range (m)');
set(gca,'FontName','Times New Roman','FontSize',14);
