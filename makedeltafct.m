function p_delta=makedeltafct(age,steps)

    global Hlower Hupper;
    global p_prices gro inffact delta;
    
    hvals=linspace(Hlower,Hupper,steps);
    deltavals=deltafct(hvals,delta);
    pvals=pricefct(hvals,age,p_prices,gro,inffact);
    p_delta=pchip(pvals,deltavals);


end