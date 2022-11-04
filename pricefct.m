function p=pricefct(h,age,p_prices,gro,inffact)

p = inffact*exp((age-1)*gro) .* ppval(p_prices,h);

end