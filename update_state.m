function [state] = update_state(x,v,a,dt,vmin,vmax)
    if v == vmax && a > 0
		a = 0;
	elseif v == vmin && a < 0
        a = 0;
    end
	x = x+v*dt+0.5*a*dt*dt;
	v = v+a*dt;
	if v > vmax
		v = vmax;
    elseif v < vmin
		v = vmin;
    end
    state = [x,v];
end
