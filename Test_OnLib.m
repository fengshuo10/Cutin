%% Obline Library Generation and Online Library Testing
clear;clc;

%% Library Generation 
% input NDD
Para_first2level;
NDD = table;

% obtain surrogate model performance and off-line library
F_FVDModel;
F_IDModel;
F_SurrModel = F_FVDM;
min_epislon = 0.05;
Lib_Off = Library_Generation(table,F_SurrModel, min_epislon);

% obtain ground truth: Switch_ACC performace and optimal library
F_ACCModel;
F_CAV = F_IDM;
Lib_Opt = Library_Generation(table,F_CAV,min_epislon);

F_err = F_CAV - F_SurrModel;
% Adaptive testing
N_Ini = 50;
N_test = 50;
[ F_Adap, Lib_Adap, Var_Adap, F_err_Adap, result_all ] = AdapGe_2_err_GC(N_Ini, N_test, x_label, y_label, F_SurrModel,F_CAV,Lib_Off,Lib_Opt, NDD);

save lib_online.mat






