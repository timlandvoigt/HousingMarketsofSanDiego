function delta_h=deltafct(h,delta)

    if numel(delta)==1
        delta_h=delta*ones(size(h));
    else
        delta_h=delta(2)+(delta(1)-delta(2))*exp(-delta(3)*h);
    end
    
end