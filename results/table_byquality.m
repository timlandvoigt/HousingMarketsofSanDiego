     disp('----------------cash: 2000 data -------------------');
     disp('--- by bin: means')
     disp(bin_meansHQD0(:,table_col)'/1000);   
     disp('by bin: conditional quantiles [.25 .5 .75 .1 .9]');
     disp(squeeze(bin_quantilesHQD0(:,table_col,:))'/1000);
  
     disp('--------- 2000 model -------------');
     disp('--- by bin: means')
     disp(bin_meansHQM0(:,table_col)'/1000);   
     disp('--- by bin: conditional quantiles [.25 .5 .75 .1 .9]');
     disp(squeeze(bin_quantilesHQM0(:,table_col,:))'/1000);    
     
    
     disp('----------------2005 data -------------------');
     disp('--- by bin: means')
     disp(bin_meansHQD5(:,table_col)'/1000);   
     disp('by bin: conditional quantiles [.25 .5 .75 .1 .9]');
     disp(squeeze(bin_quantilesHQD5(:,table_col,:))'/1000);

    for i=1:num_models5;
     disp(['---------  ' model5names{i} ' -------------']);
     disp('--- by bin: means')
     disp(bin_meansHQM5{i}(:,table_col)'/1000);   
     disp('--- by bin: conditional quantiles [.25 .5 .75 .1 .9]');
     disp(squeeze(bin_quantilesHQM5{i}(:,table_col,:))'/1000);    
    end;

  
