function [ Data_Sam_P, Id_Sam_P ] = Samp_P(x_label, y_label, P, N, N_Total )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
sampling_length = N_Total;
table = P;

% initialization
num_library = zeros(sampling_length,2);
value_library = zeros(sampling_length,2);
Id_lib = zeros(sampling_length,2);
newtable = zeros(size(table));
range = 60;
range_rate = 10;
range_num = find_num(range,x_label);
range_rate_num = find_num(range_rate,y_label);

% sampling
for i = 1:sampling_length
    for axis = 1:2
        if axis == 1
            col = table(:,range_rate_num);
            colpossi = sum(col);
            mypossi = colpossi*rand();
            sumpossi = 0;
            for j = 1:max(size(col))
                sumpossi = sumpossi+col(j);
                if sumpossi >= mypossi
                    range_num = j;
                    break;
                end
            end
        else
            row = table(range_num,:);
            rowpossi = sum(row);
            mypossi = rowpossi*rand();
            sumpossi = 0;
            for j = 1:max(size(row))
                sumpossi = sumpossi + row(j);
                if sumpossi >= mypossi
                    range_rate_num = j;
                    break;
                end
            end
        end
        
    end
    num_library(i,1) = range_num;
    num_library(i,2) = range_rate_num;
    value_library(i,1) = x_label(range_num);
    value_library(i,2) = y_label(range_rate_num);
    Id_lib(i,1:2) = [range_num, range_rate_num];
end

Data_Sam_P = value_library(end-N+1:end,:)';
Id_Sam_P = Id_lib(end-N+1:end,:)';
end

