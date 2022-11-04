   % bin indices and averages from spreadsheet  
   %
   % INPUTS:
   %  weights = col vector of same length as # rows on spreadsheet
   %  bin_col = column for binning
   %  bin_bounds = vector of bounds (includes endpoints!)
   function [bin_inds,bin_shares,bin_means] = binit(spreadsheet,weights,bin_col,bin_bounds)
    
    bins=length(bin_bounds)-1;
    
    bin_inds=cell(bins,1);
    cols = size(spreadsheet,2);
    bin_means=zeros(bins,cols);
    bin_shares=zeros(bins,1);
    
    totalsum = sum(weights);
    
    bin_inds{1}=find(spreadsheet(:,bin_col)<=bin_bounds(2));
    bin_inds{end}=find(spreadsheet(:,bin_col)>bin_bounds(end-1));
    
    for bb=1:bins-2;
       bin_inds{bb+1}=find(spreadsheet(:,bin_col)>bin_bounds(bb+1)...
                          & spreadsheet(:,bin_col)<=bin_bounds(bb+2));
    end;

    
    
    for bb=1:bins;
        bin_shares(bb)=sum(weights(bin_inds{bb}))/totalsum;
        bweights = weights(bin_inds{bb})/(bin_shares(bb)*totalsum);
        bin_means(bb,:)=sum( (bweights*ones(1,cols)) .* spreadsheet(bin_inds{bb},:) );
    end;