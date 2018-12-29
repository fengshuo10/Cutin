function f = time_interval( x1,x2,v1,v2)

if x1 > x2 && v2 > v1
    f = (x1-x2)/(v2-v1);
elseif x1 > x2 && v1 >= v2
    f = 65536;
else
    f = 0;
end
end

