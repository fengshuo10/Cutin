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
F_CAV = F_ACC;
Lib_Opt = Library_Generation(table,F_CAV,min_epislon);

F_err = F_CAV - F_SurrModel;
% Adaptive testing
N_Ini = 50;
N_test = 100;
[ F_Adap, Lib_Adap, Var_Adap, F_err_Adap ] = AdapGe_2_err_GC(N_Ini, N_test, x_label, y_label, F_SurrModel,F_CAV,Lib_Off,Lib_Opt, NDD);

%% testing Online Library
 
N_OnLib = 2e2;
[ ~, Id_Sam_OnLib ] = Samp_P(x_label, y_label, Lib_Adap, N_OnLib, 1e6);
Result_OnLib = zeros(1,N_OnLib);
acc_rate_OnLib = zeros(1,N_OnLib);
Likely_OnLib = zeros(1,N_OnLib);
tmp1 = Id_Sam_OnLib(1,:);
tmp2 = Id_Sam_OnLib(2,:);
for i=1:N_OnLib
    id1 = tmp1(i);
    id2 = tmp2(i);
    Result_OnLib(i) = F_CAV(id1, id2);
    Likely_OnLib(i) = NDD(id1, id2) / Lib_Adap(id1, id2);
    tmp = Result_OnLib .* Likely_OnLib;
    acc_rate_OnLib(i) = sum(tmp(1:i))/i;
end

save Test_Result_OnLib.mat Result_OnLib acc_rate_OnLib N_OnLib






