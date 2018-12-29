function [ F_Adap, Lib_Adap ] = AdapGe_2_err( x_label, y_label, F_SurrModel,F_CAV,Lib_Off,Lib_Opt, NDD )

% 2-dimension generation
% classification by performance error

f_x = F_CAV;
p_x = NDD;
q = Lib_Off;

[N_1,N_2] = size(F_SurrModel);
N_Ini = 100;
N_Ini_lib = 50;
N_Ini_rd = N_Ini - N_Ini_lib;
N_test = 100;
sce = zeros(2,N_Ini);
sce_id = zeros(2,N_Ini);
result = zeros(1,N_Ini);
var = zeros(1,N_Ini);
var_sum = zeros(1,N_test);

% delt_x = 1e-2;
F_err_sam = zeros(N_1,N_2);
%% step 1: initial sampling
% library sampling
[ ~, Id_Sam_P ] = Samp_P(x_label, y_label, q, N_Ini_lib);
% random sampling
id_x = randi(N_1,1,50);
id_y = randi(N_2,1,50);
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
    sigma = 0.3;
    %figure;
    svmStruct = svmtrain(TrainData, class_sce','kernel_function','rbf','rbf_sigma',...
    sigma,'showplot',false);
    class_pre = svmclassify(svmStruct,xs');
    class_M = Get_Matrix(x_label, y_label,xs',class_pre);
%     figure;
%     imagesc(class_M);
%     title('class-M')
    
    c_accident = xs(:,class_pre==1);
    c_safe = xs(:,class_pre==0);
    xs_Class = {c_accident, c_safe};
    
    % seperate testing data by classification
    sce_accident = sce(:,class_sce==1);
    sce_safe = sce(:,class_sce==0);
    Data_Class = {sce_accident, sce_safe};
    
    %% step: fitting
    meanfunc = [];                    % empty: don't use a mean function
    covfunc = @covSEiso;              % Squared Exponental covariance function
    likfunc = @likGauss;              % Gaussian likelihood

    hyp = struct('mean', [], 'cov', [0 0], 'lik', -10);
    mu_c = [];
    s2_c = [];
    f_c = [];
    m = 2;
    
    for c = 1:m
        x_sam_c = Data_Class{c}';
        
        if c==1
            y_sam_c = result(class_sce==1)';
        else
            y_sam_c = result(class_sce==0)';
        end

        xs_c = xs_Class{c}';
        hyp2 = minimize(hyp, @gp, -300, @infGaussLik, meanfunc, covfunc, likfunc, x_sam_c, y_sam_c);
        [mu,s2] = gp(hyp2, @infGaussLik, meanfunc, covfunc, likfunc, x_sam_c, y_sam_c, xs_c);
        
        mu_c = [mu_c;mu];
        s2_c = [s2_c;s2];
    end
    
    mu_c = [mu_c;mu(end,1)];
    s2_c = [s2_c;s2(end,1)];
    clear mu s2 f;
    
    mu = mu_c;
    s2 = s2_c;
    f = [mu+2*sqrt(s2); flipdim(mu-2*sqrt(s2),1)];
    clear mu_c s2_c f_c;
    
    % reformate the prediction
    ori_pre_perf = [c_accident,c_safe];
    for L = 1 : N_1*N_2
        id_x = find_num(ori_pre_perf(1,L),x_label);
        id_y = find_num(ori_pre_perf(2,L),y_label);
        Pre_Perf(id_x, id_y) = mu(L);
        Pre_Var(id_x, id_y) = s2(L);
    end
    
%     figure;
%     imagesc(Pre_Var);
%     title('Pre-Var')
%     figure;
%     imagesc(Pre_Perf);
%     title('Pre-Perf')
    %% compute E(M(X))
    EM_X = zeros(N_1,N_2);

    % calculate f(x) and q(x)
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

    EM_X = p_x ./ q_new .* (f_x_new.^2 + Pre_Var);

    % normalization
    EM_X = EM_X ./ max(EM_X(:));
%     figure;
%     imagesc(EM_X);
%     title('EM-X')
    
    %% compute weighted index
    w = 0.5;
    In_X = EM_X + w * Pre_Var ./ max(Pre_Var(:));
%     figure;
%     imagesc(In_X);
%     title('In-X')
    
    %% variance truth
    var = zeros(N_1, N_2);
    var = p_x.^2 .* f_x ./ q_new;
    u = sum(sum(p_x .* f_x));
    var_sum(j) = log10( sum(sum(var)) - u^2) ;
    %normalization
    var_norm = var ./ sum(var);

    %% error truth
    err = zeros(N_1,N_2);
    err = f_x - f_x_new;

    %% check feasibility of f_x_new
    d_pos = max(f_x_new(:)-1);
    d_neg = min(f_x_new(:));

    if d_pos > 0.1 || d_neg < -0.1
        if d_pos > -d_neg
            x_next_id = find(f_x_new-1 == d_pos,1);
            x_next_id_2 = mod(x_next_id, N_2);
            x_next_id_1 = (x_next_id-x_next_id_2) / N_1;
            x_next_id = [x_next_id_1, x_next_id_2];
            x_next = [x_label(x_next_id_1), y_label(x_next_id_2)];
        else
            x_next_id = find(f_x_new-1 == d_neg,1);
            x_next_id_2 = mod(x_next_id, N_2);
            x_next_id_1 = (x_next_id-x_next_id_2) / N_1;
            x_next_id = [x_next_id_1, x_next_id_2];
            x_next = [x_label(x_next_id_1), y_label(x_next_id_2)];
        end

    else
        % feasible
        x_next_id = find(In_X==max(In_X(:)),1);
        x_next_id_1 = mod(x_next_id, N_1);
        x_next_id_2 = (x_next_id-x_next_id_1) / N_1 + 1;
        x_next_id = [x_next_id_1, x_next_id_2];
        x_next = [x_label(x_next_id_1), y_label(x_next_id_2)];
    end

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
    
    class_M_Next = err;
    class_M_Next(x_next_id(1),x_next_id(2)) = 10;
    figure;
    imagesc(class_M_Next);
%     close all;
end
figure;
imagesc(Pre_Perf);
figure;
imagesc(f_x_new);
figure;
imagesc(q_new);
figure;
imagesc(err);
figure;
plot(var_sum,'linewidth',2.5);
    
F_Adap = f_x_new;
Lib_Adap = q_new;
end

