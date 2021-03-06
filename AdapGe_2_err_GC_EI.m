function [ F_Adap, Lib_Adap, Var_Adap, F_err_Adap, result_all ] = AdapGe_2_err_GC_EI( N_Ini, N_test, x_label, y_label, F_SurrModel,F_CAV,Lib_Off,Lib_Opt, NDD )

% 2-dimension generation
% classification by performance error
N_Ini_lib = N_Ini / 2;
N_Ini_rd = N_Ini - N_Ini_lib;


f_x = F_CAV;
p_x = NDD;
q = Lib_Off;
[N_1,N_2] = size(F_SurrModel);
sce = zeros(2,N_Ini);
sce_id = zeros(2,N_Ini);
result = zeros(1,N_Ini);
var = zeros(1,N_Ini);
Var_Adap = zeros(1,N_test+1);
class_M_Next_cell={};
f_x_new_cell={};
q_new_cell={};
F_err_Adap_cell={};
In_X_cell={};

var_off = p_x.^2 .* f_x.^2 ./ q;
u_off = sum(sum(p_x .* f_x));
Var_Adap(1) = log10( sum(sum(var_off)) - u_off^2) ;

% delt_x = 1e-2;
F_err_sam = zeros(N_1,N_2);

%% step 1: initial sampling
% library sampling
[ ~, Id_Sam_P ] = Samp_P(x_label, y_label, q, N_Ini_lib, 1e6);

% random sampling
id_x = randi(N_1,1,N_Ini_rd);
id_y = randi(N_2,1,N_Ini_rd);
id_rd = [id_x; id_y];
sce_id = [Id_Sam_P,id_rd];

for i=1:N_Ini
   
    id_1 = sce_id(1,i);
    id_2 = sce_id(2,i);
    % label
    sce(:,i) = [x_label(id_1); y_label(id_2)]; 
    % test
    result(i) = f_x(id_1,id_2) - F_SurrModel(id_1, id_2);
    F_err_sam(id_1,id_2) = result(i);
    % Var
    var(i) = f_x(id_1,id_2)^2 * p_x(id_1,id_2)^2 / q(id_1,id_2);
end

class_sce = result;
class_sce(result~=0)=1;
class_sce(result==0)=-1;

figure;
imagesc(F_err_sam);
title('F-err-sam')

xs = [];
for L=1:N_1
    xs = [xs,[x_label(L)*ones(1,N_2); y_label]];
end
x_next = [];
x_next_id = [];
for j=1:N_test
        
    
    
    %% classification
    TrainData = sce';
    
    meanfunc = @meanConst; hyp.mean = 0;
    covfunc = @covSEard; ell = 1.0; sf = 1.0; hyp.cov = log([ell ell sf]);
    likfunc = @likErf;
    hyp = minimize(hyp, @gp, -100, @infEP, meanfunc, covfunc, likfunc, TrainData, class_sce');
    [mean_tg, var_tg, c, d, lp] = gp(hyp, @infEP, meanfunc, covfunc, likfunc, TrainData, class_sce', xs', ones(N_1*N_2, 1));
    P_class_M = Get_Matrix(x_label, y_label, xs',exp(lp));
    var_tg_M = Get_Matrix(x_label, y_label, xs',var_tg);
    
    
    %% seperate the data by classification
%     th_class = 0.5;
    sc_0 = sce(:,class_sce==-1);
    y_0 = result(class_sce==-1);
    sc_n0 = sce(:,class_sce==1);
    y_n0 = result(class_sce==1);
    X_Class = {sc_0,sc_n0};
    Y_Class = {y_0, y_n0};
    
    % prediction points
%     pre_0 = xs(:,exp(lp')<th_class);
%     pre_n0 = xs(:,exp(lp')>=th_class);
%     xs_Class = {pre_0, pre_n0};
%     
    %% regression
    meanfunc = [];                    % empty: don't use a mean function
    covfunc = @covSEiso;              % Squared Exponental covariance function
    likfunc = @likGauss;              % Gaussian likelihood

    hyp_rg = struct('mean', [], 'cov', [0 0], 'lik', -10);
    mu_c = {};
    s2_c = {};
    f_c = [];
    m = 2;

    for c = 1:m
        x_sam_c = X_Class{c}';
        y_sam_c = Y_Class{c}';

        hyp_rg2 = minimize(hyp_rg, @gp, -100, @infGaussLik, meanfunc, covfunc, likfunc, x_sam_c, y_sam_c);
        [mu,s2] = gp(hyp_rg2, @infGaussLik, meanfunc, covfunc, likfunc, x_sam_c, y_sam_c, xs');
        
        mu_c{c} = mu;
        s2_c{c} = s2;
    end
    
    Pre_Perf_0 = Get_Matrix(x_label, y_label, xs',mu_c{1});
    Pre_Perf_n0 = Get_Matrix(x_label, y_label, xs',mu_c{2});
    Pre_Var_0 = Get_Matrix(x_label, y_label, xs',s2_c{1});
    Pre_Var_n0 = Get_Matrix(x_label, y_label, xs',s2_c{2});
    
%     % reformate the prediction
%     ori_pre_perf = [pre_0,pre_n0];
%     Pre_Perf = Get_Matrix(x_label, y_label, ori_pre_perf',mu);
%     Pre_Var = Get_Matrix(x_label, y_label, ori_pre_perf',s2);
    
    
    %% compute E(M(X))
    % calculate f(x) and q(x)
    Pre_Perf = P_class_M .* Pre_Perf_n0 + (1-P_class_M) .* Pre_Perf_0;
    f_x_new = Pre_Perf + F_SurrModel;
    
    % boundary adjustment
    f_x_new(f_x_new<0)=0;
    f_x_new(f_x_new>1)=1;
    
    tmp = p_x .* f_x_new;
    u_new = sum(tmp(:));
    q_new = f_x_new .* p_x ./ u_new;

    I_zero = q_new < 1 / (N_1*N_2);
    epsilon = 0.1;
    size_zero = sum(I_zero(:));
    q_new(I_zero) = epsilon / size_zero; 
    tmp = q_new(~I_zero);
    q_new(~I_zero) = (1-epsilon) .* tmp ./ sum(tmp(:));

%     EM_X = p_x ./ q_new .* (f_x_new.^2 + Pre_Var);
    In_X = P_class_M .*  p_x.^2 ./ q_new .* ( (F_SurrModel+Pre_Perf_n0).^2 + Pre_Var_n0 ) + (1-P_class_M) .* p_x.^2 ./ q_new .* ( (F_SurrModel+Pre_Perf_0).^2 + Pre_Var_0 );
    
    % 01-30-2019, 12:00, fail.
    % define a set
    lib_set = Lib_Off>2e-5;
    n0_set = P_class_M > 0.7;
    var_set = var_tg_M > 0.5;
    feasible_set = lib_set + n0_set + var_set;
    feasible_set(feasible_set>0)=1;
    In_X(feasible_set==0)=0;
    

    
    %% variance truth
    var = zeros(N_1, N_2);
    var = p_x.^2 .* f_x ./ q_new;
    u = sum(sum(p_x .* f_x));
    Var_Adap(j+1) = log10( sum(sum(var)) - u^2) ;
    %normalization
    var_norm = var ./ sum(var);

    %% error truth
    F_err_Adap = zeros(N_1,N_2);
    F_err_Adap = f_x - f_x_new;

%     %% check feasibility of f_x_new
%     d_pos = max(f_x_new(:)-1);
%     d_neg = min(f_x_new(:));
% 
%     if d_pos > 0.1 || d_neg < -0.1
%         if d_pos > -d_neg
%             x_next_id = find(f_x_new-1 == d_pos,1);
%             x_next_id_2 = mod(x_next_id, N_2);
%             x_next_id_1 = (x_next_id-x_next_id_2) / N_1;
%             x_next_id = [x_next_id_1, x_next_id_2];
%             x_next = [x_label(x_next_id_1), y_label(x_next_id_2)];
%         else
%             x_next_id = find(f_x_new-1 == d_neg,1);
%             x_next_id_2 = mod(x_next_id, N_2);
%             x_next_id_1 = (x_next_id-x_next_id_2) / N_1;
%             x_next_id = [x_next_id_1, x_next_id_2];
%             x_next = [x_label(x_next_id_1), y_label(x_next_id_2)];
%         end
% 
%     else
%         % feasible
%         x_next_id = find(In_X==max(In_X(:)),1);
%         x_next_id_1 = mod(x_next_id, N_1);
%         if x_next_id_1 == 0
%             x_next_id_1 = N_1;
%         end
%         x_next_id_2 = (x_next_id-x_next_id_1) / N_1 + 1;
%         x_next_id = [x_next_id_1, x_next_id_2];
%         x_next = [x_label(x_next_id_1), y_label(x_next_id_2)];
%     end

    %% decide next testing scenario
    x_next_id = find(In_X==max(In_X(:)),1);
    x_next_id_1 = mod(x_next_id, N_1);
    if x_next_id_1 == 0
        x_next_id_1 = N_1;
    end
    x_next_id_2 = (x_next_id-x_next_id_1) / N_1 + 1;
    x_next_id = [x_next_id_1, x_next_id_2];
    x_next = [x_label(x_next_id_1), y_label(x_next_id_2)];
        
    %% add random sample
    r0 = 0.1;
    seed = rand(1);
    if seed < r0
        x_next_id = [randi(N_1,1,1), randi(N_2,1,1)];
        x_next = [x_label(x_next_id(1)), y_label(x_next_id(2))];
    end
    
    sce = [sce, x_next'];
    sce_id = [sce_id, x_next_id'];
    new_samp = f_x(x_next_id(1),x_next_id(2))- F_SurrModel(x_next_id(1), x_next_id(2));
    result = [result, new_samp];
    class_sce = result;
    class_sce(result~=0)=1;
    class_sce(result==0)=-1;
    
    class_M_Next = F_err_Adap;
    class_M_Next(x_next_id(1),x_next_id(2)) = 10;
    
    class_M_Next_cell{j} = class_M_Next;
    f_x_new_cell{j} = f_x_new;
    q_new_cell{j} = q_new;
    F_err_Adap_cell{j} = F_err_Adap;
    In_X_cell{j} = In_X;
    
%     if mod(j,10)==0
%         %plot
% 
% %         figure;
% %         imagesc(class_M);
% %         title('class-M')
% %         colorbar;
% % 
% %         figure;
% %         imagesc(var_tg_M);
% %         title('var-tg-M')
% %         colorbar;
% % 
% %         figure;
% %         imagesc(Pre_Perf);
% %         title('Pre-Perf')
% %         colorbar;
% % 
% %         figure;
% %         imagesc(EM_X);
% %         title('EM-X')
% %         colorbar;
% % 
% %         
% 
% 
%         figure;
%         imagesc(class_M_Next);
%         xlabel('Range Rate (m/s)');
%         ylabel('Range (m)');
%         colorbar;
%         set(gca,'FontName','Times New Roman','FontSize',14);
%         
%         figure;
%         imagesc(f_x_new);
%         title('f-x-new')
%         colorbar;
%         
%         figure;
%         imagesc(q_new);
%         title('q-new')
%         colorbar
%         
%         figure;
%         imagesc(F_err_Adap);
%         title('err-ground-truth')
%         colorbar
%         
%         figure;
%         imagesc(In_X);
%         title('In-X')
%         colorbar;
%     end

end
figure;
imagesc(Pre_Perf);
title('Pre-Err')
colorbar;
figure;
imagesc(f_x_new);
title('f-x-new')
colorbar;
figure;
imagesc(q_new);
title('q-new')
colorbar
figure;
imagesc(F_err_Adap);
title('err-ground-truth')
colorbar
figure;
plot(Var_Adap,'linewidth',2.5);
    
F_Adap = f_x_new;
Lib_Adap = q_new;

result_all={class_M_Next_cell,f_x_new_cell,q_new_cell,F_err_Adap_cell,In_X_cell};

end

