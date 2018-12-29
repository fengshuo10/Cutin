function a = IDM(x1,x2,v1,v2)
    dx = x1-x2;
    dv = v2-v1;
    alpha = 2;
    u = 18;
    c = 4;
    s0 = 2;
    L = 4;
    T = 1;
    b = 3;
    s = s0+v2*T+v2*dv/(2*sqrt(alpha*b));
    a = alpha*(1-(v2/u)^c-(s/(dx-L))^2);
    if a > 3
        a = 3;
    elseif a < -3
        a = -3;
    end
end
