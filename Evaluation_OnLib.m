%% test
%% testing Online Library
load('lib_online.mat')
N_OnLib = 1e3;
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