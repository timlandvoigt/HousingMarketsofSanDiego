function s=servicefct(h,age,p_services,gro)

s = exp((age-1)*gro) * ppval(p_services,h);    

end