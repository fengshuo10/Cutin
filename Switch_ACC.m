function a = Switch_ACC(x1,x2,v1,v2)
    global a_pre;
    global ttc_pre_err;
    dx = x1-x2;
    dv = v2-v1+0.01;
    ttc_now_err = dx/dv-5;
    Kpacc = -38.6;
    Kiacc = -1.35;
    Ts = 0.1;
    ttc_gate = 2;
    if ttc_now_err > 0
        a = a_pre+Kpacc*(ttc_now_err-ttc_pre_err)+Kiacc*(ttc_now_err+ttc_pre_err)*Ts/2;
    else
        a = -3;
    end
    
    if a > 3
        a = 3;
    elseif a < -3
        a = -3;
    end
    if a == NaN
        pause;
    end
    a_pre = a;
    ttc_pre_err = ttc_now_err;
end
