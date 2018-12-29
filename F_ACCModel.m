%% generate the performance function of surrogate model

F_ACC = zeros(N_range,N_rangerate);
for i=1:N_range
    for j=1:N_rangerate
        test_range = x_label(i);
        test_range_rate = y_label(j);
        test_value = value_function_Switch_ACC([test_range,test_range_rate]);
        if test_value == 0
            F_ACC(i,j) = 1;
        else
            F_ACC(i,j) = 0;
        end
    end
end
