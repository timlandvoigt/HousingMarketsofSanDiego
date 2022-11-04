function ppf=makeinverse(pp,nrpoints)
    
    lbound=pp.breaks(1);
    ubound=pp.breaks(end);
    hvals=linspace(lbound,ubound,nrpoints);
    pvals=ppval(pp,hvals);
    [pvals_uni,index]=unique(pvals,'last');
    hvals_uni=hvals(index);

    ppf=pchip(pvals_uni,hvals_uni);

end