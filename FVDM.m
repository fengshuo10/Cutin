function a = FVDM(x1,x2,v1,v2)
    dv = v2-v1;
    dx = x1-x2;
    k = 0.85;
    V1 = 6.75;
    V2 = 7.91;
    C1 = 0.13;
    C2 = 1.57;
    L = 5;
    a = k*(V1+V2*tanh(C1*(dx-L)-C2)-v2);
    if a > 3
        a = 3;
    elseif a < -3
        a = -3;
    end
end