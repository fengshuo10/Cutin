 
function [f] = value_function_IDM(x)

    global v1;
    global v2;
    global omega;
    omega = 0.2;
    v2 = 20;
    global dt;
    dt = 1;
    global STEP;
    STEP = 10;
    global vmax;
    global vmin;
    vmax = 40;
    vmin = 0;
    global C;
    global Pb;
    Pb = 0.03;
    range = x(1);
    range_rate = x(2);
    v1 = v2+range_rate;
    global STEP;
    car1 = [range,v1];
    car2 = [0,v2];
    value_list = [];
    x1_list = [range];
    x2_list = [0];
    a2_list = [];
    v2_list = [];
    global a_pre;
    a_pre = 0;
    global ttc_pre_err;
    ttc_pre_err = ttc(range,0,v1,v2)-5;
    
    for i = 1:STEP
        a1 = 0;
        a2 = IDM(car1(1),car2(1),car1(2),car2(2));
        car1 = update_state(car1(1),car1(2),a1,dt,vmin,vmax);
        car2 = update_state(car2(1),car2(2),a2,dt,vmin,vmax);
        x1_list = [x1_list,car1(1)];
        x2_list = [x2_list,car2(1)];
        v2_list = [v2_list,car2(2)];
        a2_list = [a2_list,a2];
        value_list = [value_list,time_interval(car1(1),car2(1),car1(2),car2(2))];
    end
    f = min(value_list); 
    %plot(x1_list);
    %hold on;
    %plot(x2_list);
end
    



