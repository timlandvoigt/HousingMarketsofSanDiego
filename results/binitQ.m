   function [bin_inds,bin_shares,bin_means,bin_quantiles] = binitQ(spreadsheet,weights,bin_col,bin_bounds,quants)
   % bin indices, averages AND QUANTILES from spreadsheet  
   %
   % INPUTS:
   %  weights = col vector of same length as # rows on spreadsheet
   %  bin_col = column for binning
   %  bin_bounds = vector of bounds (includes endpoints!)
   %  quants = vector of quantiles to be computed conditional on bin
   %
   % OUPUTS:
   %  bin_inds = cell array of indices in spreadsheet for each bin
   %  bin_shares = mass in each bin (#bins x 1)
   %  bin_means = matrix of means (# bins x # columns)
   %  bin_quantiles = 3d array of quantiles (#bins x #columns x #quantiles)

    bins=length(bin_bounds)-1;
    
    bin_inds=cell(bins,1);
    cols = size(spreadsheet,2);
    bin_means=zeros(bins,cols);
    bin_shares=zeros(bins,1);
    bin_quantiles=zeros(bins,cols,length(quants));
    
    totalsum = sum(weights);
    
    bin_inds{1}=find(spreadsheet(:,bin_col)<=bin_bounds(2));
    bin_inds{end}=find(spreadsheet(:,bin_col)>bin_bounds(end-1));
        
    for bb=1:bins-2;
       bin_inds{bb+1}=find(spreadsheet(:,bin_col)>bin_bounds(bb+1)...
                          & spreadsheet(:,bin_col)<=bin_bounds(bb+2));
      % bin_col               
      % spreadsheet(1,bin_col)
      % bin_bounds(bb+1)
      % bin_bounds(bb+2)
      % pause;
    end;

    
    
    for bb=1:bins;
        %bb
        bin_shares(bb)=sum(weights(bin_inds{bb}))/totalsum;
        bweights = weights(bin_inds{bb})/(bin_shares(bb)*totalsum);
        bin_means(bb,:)=sum( (bweights*ones(1,cols)) .* spreadsheet(bin_inds{bb},:) );
        
        % uses our own routine for weighted quantiles
        bin_q = quantile_w(spreadsheet(bin_inds{bb},:),bweights,quants);

        bin_quantiles(bb,:,:)=bin_q';
                    
    end;