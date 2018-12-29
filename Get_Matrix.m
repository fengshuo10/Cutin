function [ Matrix ] = Get_Matrix(x_label, y_label,data,class);
%UNTITLED8 Summary of this function goes here
N1 = size(x_label,1);
N2 = size(y_label,2);
N = size(data,1);
Matrix = zeros(N1,N2);
for i=1:N
    id1 = find_num( data(i,1), x_label);
    id2 = find_num( data(i,2), y_label);
    Matrix(id1,id2) = class(i);
end

end

