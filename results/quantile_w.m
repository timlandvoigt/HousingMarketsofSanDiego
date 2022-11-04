function qs = quantile_w(data,weights,quants);

% finds quantiles with weighted data
%
% input:
%  data: matrix with obs in rows
%  weights: obs x 1 vector of common pop weights
%  quants: vector of quantiles to be computed
%
% output:
%  qs: matrix of quantiles
   qs = zeros(length(quants),size(data,2));
   
for kk=1:size(data,2);
 %kk
 % sort data column kk and weights by data column kk   
 sorted=sortrows([data(:,kk),weights],1);
 % make cdf of data column 2
 cumw=cumsum(sorted(:,2));
 % extract quantile indices of data column 2
 %   if many mentions of one variable, will pick arb index, but correct val 
 for qq=1:length(quants);    
  %quants(qq)   
  qindices(qq) = sum(cumw<=quants(qq)); 
 end;
 % record actual index values
 qindices(qindices==0)=1;
 qs(:,kk) = sorted(qindices,1);

end