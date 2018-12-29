function f = ttc( x1,x2,v1,v2)
if v1 ~= v2
    f = (x1-x2)/(v2-v1);
else
    f = (x1-x2)/0.01;

end