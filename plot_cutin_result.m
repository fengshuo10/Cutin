%% plot for cut-in results
% result_all = {class_M_Next_cell,f_x_new_cell,q_new_cell,F_err_Adap_cell,In_X_cell};

clear;clc;

Para_first2level;
F_FVDModel;
F_IDModel;
F_SurrModel = F_FVDM;
min_epislon = 0.05;
Lib_Off = Library_Generation(table,F_SurrModel, min_epislon);
F_ACCModel;
F_CAV = F_IDM;
Lib_Opt = Library_Generation(table,F_CAV,min_epislon);
F_err = F_CAV - F_SurrModel;

figure;
imagesc(y_label, x_label, F_FVDM);
axis xy
xlabel('Range Rate (m/s)');
ylabel('Range (m)');
colorbar;
set(gca,'FontName','Times New Roman','FontSize',14);

figure;
imagesc(y_label, x_label, F_err);
axis xy
xlabel('Range Rate (m/s)');
ylabel('Range (m)');
colorbar;
set(gca,'FontName','Times New Roman','FontSize',14);

figure;
imagesc(y_label, x_label, Lib_Off);
axis xy
xlabel('Range Rate (m/s)');
ylabel('Range (m)');
colorbar;
set(gca,'FontName','Times New Roman','FontSize',14);


load('lib_online.mat')
class_M_Next_cell = result_all{1};
f_x_new_cell = result_all{2};
q_new_cell = result_all{3};
F_err_Adap_cell = result_all{4};
In_X_cell = result_all{5};
slice = [5,50];

for i=1:2
    
    figure;
    imagesc(y_label, x_label, f_x_new_cell{slice(i)});
    axis xy
    xlabel('Range Rate (m/s)');
    ylabel('Range (m)');
    colorbar;
    set(gca,'FontName','Times New Roman','FontSize',14);
    
    figure;
    imagesc(y_label, x_label, q_new_cell{slice(i)});
    axis xy
    xlabel('Range Rate (m/s)');
    ylabel('Range (m)');
    colorbar;
    set(gca,'FontName','Times New Roman','FontSize',14);
    
    figure;
    imagesc(y_label, x_label, In_X_cell{slice(i)});
    axis xy
    xlabel('Range Rate (m/s)');
    ylabel('Range (m)');
    colorbar;
    set(gca,'FontName','Times New Roman','FontSize',14);
    
    figure;
    imagesc(y_label, x_label, F_err_Adap_cell{slice(i)});
    axis xy
    xlabel('Range Rate (m/s)');
    ylabel('Range (m)');
    colorbar;
    set(gca,'FontName','Times New Roman','FontSize',14);

end