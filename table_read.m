function [x_label,y_label,in_table] = table_read(whole_table)
    x_label = whole_table(:,1);
    x_label(1) = [];
    whole_table(:,1) = [];
    y_label = whole_table(1,:);
    whole_table(1,:) = [];
    in_table = whole_table;
end