function [num] = find_num(value,label)
num = [];
for i = 1:max(size(label))
    if label(i) >= value
        num = i;
        break
    end
end

