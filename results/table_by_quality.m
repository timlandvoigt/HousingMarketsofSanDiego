     
     % create format string for table 
     % assumes that number of quality bins the same for all and 
     %    given by length(bin_boundsQ0)-1
     
     mainf = repmat('   %7.3f',1,length(bin_boundsQ0)-1);
     
     form_quant = ['    %3.2f ' mainf '\n'];      
     form_mean =  ['    mean ' mainf '\n']; 
      
     disp('----------------cash: 2000 data -------------------');
     disp('      ( $000s of 2005 dollars )');
     disp('--- by bin: means')
     fprintf(form_mean,bin_meansHQD0(:,table_col)'/1000);   
     disp('--- by bin: conditional quantiles');
     fprintf(form_quant,[quantilesQ;squeeze(bin_quantilesHQD0(:,table_col,:))/1000]);
  
     disp('--------------- 2000 model -------------------------');
     disp('--- by bin: means')
     fprintf(form_mean,bin_meansHQM0(:,table_col)'/1000);   
     disp('--- by bin: conditional quantiles');
     fprintf(form_quant,[quantilesQ;squeeze(bin_quantilesHQM0(:,table_col,:))/1000]);

    
     disp('----------------2005 data -------------------');
     disp('--- by bin: means')
     fprintf(form_mean,bin_meansHQD5(:,table_col)'/1000);   
     disp('--- by bin: conditional quantiles');
     fprintf(form_quant,[quantilesQ;squeeze(bin_quantilesHQD5(:,table_col,:))/1000]);

    for i=1:num_models5;
     disp(['---------  ' model5names{i} ' -------------']);
     disp('--- by bin: means')
     fprintf(form_mean,bin_meansHQM5{i}(:,table_col)'/1000);   
     disp('--- by bin: conditional quantiles');
     fprintf(form_quant,[quantilesQ;squeeze(bin_quantilesHQM5{i}(:,table_col,:))/1000]);
    end;

    
 
