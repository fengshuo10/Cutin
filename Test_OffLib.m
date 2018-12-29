%% Testing Off-line Library

%% main
clear;clc;

%% Library Generation 
% input NDD
Para_first2level;
NDD = table;

% obtain surrogate model performance and off-line library
F_IDModel;
F_SurrModel = F_IDM;
min_epislon = 0.1;
Lib_Off = Library_Generation(table,F_SurrModel, min_epislon);

% obtain ground truth: Switch_ACC performace and optimal library
F_ACCModel;
F_CAV = F_ACC;
Lib_Opt = Library_Generation(table,F_CAV, 0);

% Offline library test

N_OffLib = 1e2;
[ ~, Id_Sam_OffLib ] = Samp_P(x_label, y_label, Lib_Off, N_OffLib, 1e6);
Result_OffLib = zeros(1,N_OffLib);
acc_rate_OffLib = zeros(1,N_OffLib);
Likely_OffLib = zeros(1,N_OffLib);
tmp1 = Id_Sam_OffLib(1,:);
tmp2 = Id_Sam_OffLib(2,:);
for i=1:N_OffLib
    id1 = tmp1(i);
    id2 = tmp2(i);
    Result_OffLib(i) = F_CAV(id1, id2);
    Likely_OffLib(i) = NDD(id1, id2) / Lib_Off(id1, id2);
    tmp = Result_OffLib .* Likely_OffLib;
    acc_rate_OffLib(i) = sum(tmp(1:i))/i;
end

save Test_Result_OffLib.mat Result_OffLib    acc_rate_OffLib    N_OffLib