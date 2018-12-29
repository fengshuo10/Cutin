%% NDD testing

%% main
clear;clc;

%% Library Generation 
% input NDD
Para_first2level;
NDD = table;

% obtain ground truth: Switch_ACC performace and optimal library
%F_ACCModel;
F_IDModel;
F_CAV = F_IDM;

% NDD test
% NDD sampling
N_NDD = 1e6;
[ Data_Sam_NDD, Id_Sam_NDD ] = Samp_P(x_label, y_label, NDD, N_NDD, 1e8);
Result_NDD_cell = {};
acc_rate_NDD = zeros(1,N_NDD);
tmp1 = Id_Sam_NDD(1,:);
tmp2 = Id_Sam_NDD(2,:);
parfor i=1:N_NDD
    id1 = tmp1(i);
    id2 = tmp2(i);
    Result_NDD_cell{i} = F_CAV(id1, id2);
end
Result_NDD = zeros(1, N_NDD);
for i=1:N_NDD
    Result_NDD(i) = Result_NDD_cell{i};
    acc_rate_NDD(i) = sum(Result_NDD(1:i))/i;
end


save Test_Result_NDD.mat Result_NDD acc_rate_NDD N_NDD