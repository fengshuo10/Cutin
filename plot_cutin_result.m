%% plot for cut-in results
% result_all = {class_M_Next_cell,f_x_new_cell,q_new_cell,F_err_Adap_cell,In_X_cell};

clear;clc;

load('lib_online.mat')
class_M_Next_cell = result_all{1};
f_x_new_cell = result_all{2};
q_new_cell = result_all{3};
F_err_Adap_cell = result_all{4};
In_X_cell = result_all{5};
slice = [10,30,50];

for i=1:3
    
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