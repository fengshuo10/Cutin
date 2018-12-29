%% parameters of functional and environmental scenarios

% obtain NDD data
[x_label,y_label,table] = table_read(csvread('6-11cutin_table.csv'));

N_range = size(table,1);
N_rangerate = size(table,2);