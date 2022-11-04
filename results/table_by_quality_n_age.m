     % again assumes that number of qual bins from bin_boundsQ0 for both
     % years, and for model and data...

     mainf = repmat('   %8.3f',1,length(bin_boundsQ0)-1);
     
     form_quant = ['    %3.2f ' mainf '\n'];      

    % condition on age

     for coh=1:length(bin_boundsY)-1;    
     
     disp(' '); 
     disp(' ');
     disp('===============================================');
     disp(['cohort is now younger than ' num2str(bin_boundsY(coh+1))]);   
     disp('===============================================');
     
     disp(' ');
     disp('everything in 000s of 2005 dollars');
     disp('  ');
     
     disp('----------------2000 data -------------------');
%     disp('--- by bin: means')
%     disp(bin_meansHQD0(:,table_col)'/1000);  
     disp('---by bin: conditional quantiles');
     fprintf(form_quant,[quantilesY;squeeze(bin_quantilesHQD0y{coh}(:,table_col,:))/1000]);
     
     disp('--------- 2000 model -------------');
%     disp('--- by bin: means')
%     disp(bin_meansHQM0(:,table_col)'/1000);   
     disp('--- by bin: conditional quantiles');
     fprintf(form_quant,[quantilesY;squeeze(bin_quantilesHQM0y{coh}(:,table_col,:))/1000]);    
     
    
     disp('----------------2005 data -------------------');
%      disp('--- by bin: means')
%      disp(bin_meansHQD5y(:,table_col)'/1000);   
     disp('by bin: conditional quantiles');
     fprintf(form_quant,[quantilesY;squeeze(bin_quantilesHQD5y{coh}(:,table_col,:))/1000]);

    for i=1:num_models5;
     disp(['---------  ' model5names{i} ' -------------']);
%     disp('--- by bin: means')
%     disp(bin_meansHQM5{i}(:,table_col)'/1000);   
     disp('--- by bin: conditional quantiles [.25 .5 .75 .1 .9]');
     fprintf(form_quant,[quantilesY;squeeze(bin_quantilesHQM5y{i,coh}(:,table_col,:))/1000]);    
    end;

    end;