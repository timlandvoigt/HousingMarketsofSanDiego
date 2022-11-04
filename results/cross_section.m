   
%-------------------------------------------------------------------------------------    
%==================== initialization and loading
%-------------------------------------------------------------------------------------    

    %
    % data are
    %          (i) census & acs data processed by sandiegoXX 
    %          (ii) census & acs data directly from stata
    %
    % makes also expenditure and quality grids
    %
    %  all expenditure data are converted to 2005 dollars after loading
    
    clear all; 
    close all;
    normfact=10000;
    modelflag=1; % one of models loaded
    modelflag5=1; % one of 2005 models loaded
    
    
    table4=1; % selects age bins: 4 vs 2 in default

    
    % establish folder structure
    current=pwd;% current dir
    cd ..;
    parent=pwd;
    cd ..;
    grandparent=pwd;
    cd(current);
    
    % point to data directories      
    empmatlab_dir = [parent '\data\'];
    compute_dir = [parent '\'];

    print_dir = '.';

    census_vals = [5e3 12.5e3:5e3:37.5e3 45e3:10e3:95e3...
                   1125e2 1375e2 1625e2 1875e2 225e3 275e3 35e4 45e4 625e3 875e3 1.3e6];

    census_grid = log([1e3 10e3:5e3:40e3 50e3:10e3:1e5 125e3 150e3 175e3 200e3 ...
                                   250e3 300e3 400e3 500e3 750e3 1e6 5e6]);           
    census_bins=length(census_grid)-1;

    
    %----- load census_data written by sandiegoXX 
    %  
    load([empmatlab_dir 'censusdata2mn_21.mat']); % what we need from this is mean_census_grid
    load([empmatlab_dir 'newacsdata2mn_21.mat']);  
    
    %----- load experlist structure with pars & policies
    %  load ([compute_dir 'exper_list_out_service5.mat']);          
    load ('experlist_20140418.mat');          
%    load ([compute_dir 'exper_list_out_0703.mat']);          


    %-------- set parameters
    
    Rf=experlist.service.Rf;
    Rf_short=Rf;
    std_p_idio=experlist.service.std_p_idio;
    run([compute_dir 'set_parameters.m']);

    
    
    %----- load cpi, BLS series CUUR0000SA0, not seas adj.
    fid=fopen([empmatlab_dir 'cpitable2.txt']);
    c=textscan(fid,'%*s%d8%s%f32');
    fclose(fid);
    pindex=c{3}(1:end-13);
    % prepare price index - here use one starting in 1998
    pindexAX = double(pindex(end-(2008-1998)*12:12:end));
    
    
    % quality and expenditure grids    
    expgrid0=exp(census_grid)*pindexAX(8)/pindexAX(3);
    expgrid5=exp(census_grid);
    qualgrid0=exp(census_grid);
    qualgrid5=exp(mean_census_grid{5});

                  
    % ----- read census & acs data written by check_census5_wealth and
    % check_acs5_wealth
    % stata command writing out data is
    % outsheet wgt_census moveM new age hhincome_inf valueh_inf wealth_inf ...
    %       mortgage_dum mortpmt using acs05_demand.txt, comma nonames replace noquote nolabel
    % so columns are
    % 
    % 1 weight
    % 2 movedin
    % 3 new 
    % 4 age
    % 5 income
    % 6 valueh
    % 7 wealth
    % 8 mortgage_dum
    % 9 mortg pmt    
    
    census_datasheet = dlmread([empmatlab_dir 'census_demand.txt']);
    census_moverflag=(census_datasheet(:,2)==1);
    census_obs = sum(census_moverflag);
    acs_datasheet5 = dlmread([empmatlab_dir 'acs05_demand.txt']);
    acs_moverflag5=(acs_datasheet5(:,2)==1);
    acs_obs5 = sum(acs_moverflag5);
    
    % convert to 2005 dollars - hvalue, income, wealth were in 2008 dollars
    % from stata, mortpay was in current dollars
    census_datasheet(:,5:7)=census_datasheet(:,5:7)*pindexAX(8)/pindexAX(end);
    census_datasheet(:,9)=census_datasheet(:,9)*pindexAX(8)/pindexAX(3);
    acs_datasheet5(:,5:7)=acs_datasheet5(:,5:7)*pindexAX(8)/pindexAX(end);
          
     
%-------------------------------------------------------------------------------------    
%======================= combine data and model info for 2000 into structure model0   
%-------------------------------------------------------------------------------------    

    % model0 is structure for 2000 service flow model
    %  model0.spreadsheet combines census data and model predictions    

    % spreadsheet columns (same for model0 and models 5 below):
    % 1:  weight
    % 2:  valueh
    % 3:  moveM 
    % 4:  new
    % 5:  age
    % 6:  inc 
    % 7:  mortdummy
    % 8:  mortpmt 
    % 9:  data hqual (bin)
    % 10: cash
    % 11: wealth
    % 12: data hqual(top of bin)    
    % 13: model implied hqual (raw level)
    % 14: housexp (expenditure)
    % 15: sav
    % and add below:
    % 16: hqualDbin WILL BE FILLED IN BELOW in quality grid vals for yr
    % 17: hqualMbin WILL BE FILLED IN BELOW
    % 18: house / income data
    % 19: house / income model
    % 20: house / cash data (cash annualized)
    % 21: house / cash model (cash annualized)
    % 22: mortpay/income
    % 23: cash annualized
    % 24: change in quality benchmark minus base MISSING
               
    model0=experlist.service;
    model0.spreadsheet = zeros(census_obs,21);    
    model0.spreadsheet(:,[1:8 11])=census_datasheet(census_moverflag,[1 6 2:5 8 9 7]);
    allhh_sheet0 = zeros(size(census_datasheet,1),17);    
    allhh_sheet0(:,[1:8 11])=census_datasheet(:,[1 6 2:5 8 9 7]);
    % cash using after tax income
    model0.spreadsheet(:,10) = 3*(1-tau)*census_datasheet(census_moverflag,5)...
                                     +census_datasheet(census_moverflag,7);
    model0.spreadsheet(:,18) = model0.spreadsheet(:,2)./model0.spreadsheet(:,6);
    model0.spreadsheet(:,23) = (1-tau)*census_datasheet(census_moverflag,5)...
                                     +census_datasheet(census_moverflag,7);
    model0.spreadsheet(:,20) = model0.spreadsheet(:,2)./model0.spreadsheet(:,10);

    if modelflag                        
     pol =  experlist.service.polsample;    
     model0.spreadsheet(:,13:15) = [pol(:,1)*normfact, pol(:,2:3)*pindexAX(8)/pindexAX(end)];    
     model0.spreadsheet(:,19) = model0.spreadsheet(:,14)./model0.spreadsheet(:,6);
     model0.spreadsheet(:,21) = model0.spreadsheet(:,14)./model0.spreadsheet(:,10);
     model0.spreadsheet(:,22) = model0.spreadsheet(:,9)./model0.spreadsheet(:,6);

    end;
    model0.spreadsheet(:,9) = sum(model0.spreadsheet(:,2)*ones(1,census_bins)...
                                   > ones(census_obs,1)*(expgrid0(1:end-1)-1), 2);
    %model0.spreadsheet(:,12)=  upper qual                    
            
       
%-------------------------------------------------------------------------------------    
%========== combine data and model info for 2005 into structure array models5   
%-------------------------------------------------------------------------------------    

          
    % models5 is a structure array containing various 2005 computations
    %  models5{i}.spreadsheet combines acs data and model predictions
       
        
    allhh_sheet5 = zeros(size(acs_datasheet5,1),17);
    allhh_sheet5(:,[1:8 11]) = acs_datasheet5(:,[1 6 2:5 8 9 7]);

    model5names={'newbase','perffore'};

    benchmark=1; % matters for computing change

    num_models5=length(model5names);    
    for i=1:num_models5;
    models5{i} = experlist.(model5names{i});
    models5{i}.spreadsheet = zeros(acs_obs5,24);
    models5{i}.spreadsheet(:,[1:8 11])=acs_datasheet5(acs_moverflag5,[1 6 2:5 8 9 7]);
    models5{i}.spreadsheet(:,10) = 3*(1-tau)*acs_datasheet5(acs_moverflag5,5)...
                                                     +acs_datasheet5(acs_moverflag5,7);
    models5{i}.spreadsheet(:,18) = models5{i}.spreadsheet(:,2)./models5{i}.spreadsheet(:,6);
    models5{i}.spreadsheet(:,23) = (1-tau)*acs_datasheet5(acs_moverflag5,5)...
                                                     +acs_datasheet5(acs_moverflag5,7);
    models5{i}.spreadsheet(:,20) = models5{i}.spreadsheet(:,2)./models5{i}.spreadsheet(:,10);

    if modelflag5; 
     pol =   experlist.(model5names{i}).polsample;   
     models5{i}.spreadsheet(:,13:15) = [pol(:,1)*normfact, pol(:,2:3)*pindexAX(8)/pindexAX(end)]; 
     models5{i}.spreadsheet(:,19) = models5{i}.spreadsheet(:,14)./models5{i}.spreadsheet(:,6);
     models5{i}.spreadsheet(:,21) = models5{i}.spreadsheet(:,14)./models5{i}.spreadsheet(:,10);
     models5{i}.spreadsheet(:,22) = models5{i}.spreadsheet(:,9)./models5{i}.spreadsheet(:,6);
    end;
    models5{i}.spreadsheet(:,9) = sum(models5{i}.spreadsheet(:,2)*ones(1,census_bins)...
                                   > ones(acs_obs5,1)*(expgrid5(1:end-1)-1), 2);          
    end;
  
    for i=1:num_models5;
        models5{i}.spreadsheet(:,24) = models5{i}.spreadsheet(:,13)-models5{benchmark}.spreadsheet(:,13);
    end;
   

 
%-------------------------------------------------------------------------------------    
%========== add comparable hqual data to spreadsheet (both 2000 and 2005)
%-------------------------------------------------------------------------------------    


    % write grid cell midpoints for both model and data!
    hqual_vals0 = (qualgrid0(1:end-1)+qualgrid0(2:end))/2;
    hqual_vals5 = (qualgrid5(1:end-1)+qualgrid5(2:end))/2;
    hqual_vals0(end) = 2.1*qualgrid0(end-1)/2;
    hqual_vals5(end) = 2.1*qualgrid5(end-1)/2;    
    hexp_vals0 = census_vals*pindexAX(8)/pindexAX(3);
    hexp_vals5 = census_vals;

    
    % first consider 2000 data
        
    %----- make values for data hqual and hexp bins 
    % for hqual, use the bin number (column 9) to assign value
    hqualDbin0 = hqual_vals0(model0.spreadsheet(:,9))';
    hqualDbin5 = hqual_vals5(models5{1}.spreadsheet(:,9))';
    model0.spreadsheet(:,16) = hqualDbin0;
    for i=1:num_models5;
     models5{i}.spreadsheet(:,16) = hqualDbin5;
    end;
    % for hexp, read off from col 2 (it is in 2008 dollars!)
    hexpDbin0 = model0.spreadsheet(:,2);
    hexpDbin5 = models5{1}.spreadsheet(:,2);
    
      
    %---- make discretized values for model hqual
    % here qualgrid# is used to define bins    
   if modelflag;
    weightnow=model0.spreadsheet(:,1);   
    hqualMnow=model0.spreadsheet(:,13);    
    [bin_indsM,bin_shares,bin_means] =  binit(hqualMnow,weightnow,1,qualgrid0);
    hqualMbin = hqualMnow;
    for j=1:length(qualgrid0)-1;
       hqualMbin(bin_indsM{j}) = hqual_vals0(j);
    end;
    model0.spreadsheet(:,17) = hqualMbin;
   end;
   if modelflag5;
    
    for i=1:num_models5;
     hqualMnow=models5{i}.spreadsheet(:,13);
     weightnow=models5{i}.spreadsheet(:,1);
     [bin_inds,bin_shares,bin_means] =  binit(hqualMnow,weightnow,1,qualgrid5);
     hqualMbin = hqualMnow;
     for j=1:length(qualgrid5)-1;
        hqualMbin(bin_inds{j}) = hqual_vals5(j);
     end;
     models5{i}.spreadsheet(:,17) = hqualMbin;
    end;
   end;
   
  
   
%--------------------------------------------------------------------------------------
%============================== create binwise properties for all the models    
%--------------------------------------------------------------------------------------

     % binitQ generares cell arrays with bin properties
     

     % ------------- total -------------------------------
     bin_boundsT = [0 100];   % use age here as bin col but doesn't actually matter 
         
     weight=model0.spreadsheet(:,1);
     [bin_indsT0,bin_sharesT0,bin_meansT0,bin_quantilesT0] = ...
                     binitQ(model0.spreadsheet,weight,5,bin_boundsT,[.01 .1 .25 .5 .75 .9 .99]);
                 
     weight=allhh_sheet0(:,1);
     [bin_indsT0all,bin_sharesT0all,bin_meansT0all,bin_quantilesT0all] = ...
                     binitQ(allhh_sheet0,weight,5,bin_boundsT,[.01 .1 .25 .5 .75 .9 .99]);
                 
  
      weight=allhh_sheet5(:,1);
      [bin_indsT5all,bin_sharesT5all,bin_meansT5all,bin_quantilesT5all] = ...
                     binitQ(allhh_sheet5,weight,5,bin_boundsT,[.01 .1 .25 .5 .75 .9 .99]);

     for i=1:num_models5;
      weight=models5{i}.spreadsheet(:,1);
      [bin_indsT5{i},bin_sharesT5{i},bin_meansT5{i},bin_quantilesT5{i}] = ...
                     binitQ(models5{i}.spreadsheet,weight,5,bin_boundsT,[.01 .1 .25 .5 .75 .9 .99]);
     end;                 
   
     
     disp('============= population stats ===============');
     disp('variables are housevalue, income, wealth');
     disp('2005 $000')
     disp('means, 2000 census')
     disp(bin_meansT0([2 6 11])/1000);
     disp('quantiles [.01 .1 .25 .5 .75 .9 .99], 2000 census');
     disp(squeeze(bin_quantilesT0(1,[2 6 11],:))'/1000);
     disp('===========================================')
     disp('variables are housevalue, income, wealth');
     disp('means, 2005 acs')
     disp(bin_meansT5{1}([2 6 11])/1000);
     disp('quantiles [.1 .25 .5 .75 .9], 2005 census');
     disp(squeeze(bin_quantilesT5{1}(1,[2 6 11],:))'/1000);

                
     % ------------- by age -------------------------------

     if table4
      bin_boundsA = [0 35 50 65 100];
      bin_pointsA = [20 42 57 80];
     else   
      bin_boundsA = [0  35 100];    
      bin_pointsA = [27.5 67.5];
     end;

     quantilesA = [.1 .5 .9];
     
     weight=model0.spreadsheet(:,1);
     [bin_indsA0,bin_sharesA0,bin_meansA0,bin_quantilesA0,bin_topsharesA0] = ...
                     binitQ2(model0.spreadsheet,weight,5,bin_boundsA,quantilesA,11);
                          
     weight=allhh_sheet0(:,1);
     [bin_indsA0all,bin_sharesA0all,bin_meansA0all,bin_quantilesA0all,bin_topsharesA0all] = ...
                     binitQ2(allhh_sheet0,weight,5,bin_boundsA,quantilesA,11);
                     

      weight=allhh_sheet5(:,1);
      [bin_indsA5all,bin_sharesA5all,bin_meansA5all,bin_quantilesA5all,bin_topsharesA5all] = ...
                     binitQ2(allhh_sheet5,weight,5,bin_boundsA,quantilesA,11);

     
     for i=1:num_models5;
      weight=models5{i}.spreadsheet(:,1);
      [bin_indsA5{i},bin_sharesA5{i},bin_meansA5{i},bin_quantilesA5{i},bin_topsharesA5{i}] = ...
                     binitQ2(models5{i}.spreadsheet,weight,5,bin_boundsA,quantilesA,11);
     end;                 
                 
     
     % ------------- by house expenditure bin ------------------------
     % note that points here are for plotting only!
     bin_boundsE0=[0 expgrid0(18:end)-1];
     bin_pointsE0 = (bin_boundsE0(1:end-1)+bin_boundsE0(2:end))/2;
     bin_pointsE0(end)=bin_pointsE0(end-1)*1.1;
     bin_boundsE5=[0 expgrid5(18:end)-1];
     bin_pointsE5 = (bin_boundsE5(1:end-1)+bin_boundsE5(2:end))/2;
     bin_pointsE5(end)=bin_pointsE5(end-1)*1.1;   
     
     quantilesE = [.25 .5 .75];
     
     % 2000: census, scf          
     [bin_indsHE0,bin_sharesHE0,bin_meansHE0,bin_quantilesHE0]...
              = binitQ(model0.spreadsheet,model0.spreadsheet(:,1),2,bin_boundsE0,quantilesE);    
     % 2005: acs, scf     
     [bin_indsHE5,bin_sharesHE5,bin_meansHE5,bin_quantilesHE5]...
              = binitQ(models5{1}.spreadsheet,models5{1}.spreadsheet(:,1),2,bin_boundsE5,quantilesE);    

     

     % ------------- by house quality bin ------------------------
     
     bin_boundsQ0=[0 qualgrid5([21:end-2 end])];

     bin_pointsQ0 = (bin_boundsQ0(1:end-1)+bin_boundsQ0(2:end))/2;
     bin_pointsQ0(end)=bin_pointsQ0(end-1)*1.1;
     bin_boundsQ5=[0 qualgrid5([21:end-2 end])];
     bin_pointsQ5 = (bin_boundsQ5(1:end-1)+bin_boundsQ5(2:end))/2;
     bin_pointsQ5(end)=bin_pointsQ5(end-1)*1.1;    
     
     quantilesQ = [.25 .5 .75 .1 .9];
     
     % data (2000, 2005)     
     bin_col = 16;
     [bin_indsHQD0,bin_sharesHQD0,bin_meansHQD0,bin_quantilesHQD0]...
              = binitQ(model0.spreadsheet,model0.spreadsheet(:,1),bin_col,bin_boundsQ0,quantilesQ);  
     [bin_indsHQD5,bin_sharesHQD5,bin_meansHQD5,bin_quantilesHQD5]...
              = binitQ(models5{1}.spreadsheet,models5{1}.spreadsheet(:,1),bin_col,bin_boundsQ5,quantilesQ);  

     % model     
     if modelflag
         bin_col = 13;
         [bin_indsHQM0,bin_sharesHQM0,bin_meansHQM0,bin_quantilesHQM0]...
             = binitQ(model0.spreadsheet,model0.spreadsheet(:,1),bin_col,bin_boundsQ0,quantilesQ);
     end
     if modelflag5
         bin_col = 13;
         for i=1:num_models5;
             [bin_indsHQM5{i},bin_sharesHQM5{i},bin_meansHQM5{i},bin_quantilesHQM5{i}]...
                 = binitQ(models5{i}.spreadsheet,models5{i}.spreadsheet(:,1),bin_col,bin_boundsQ5,quantilesQ);
         end;
     end;
     

     %----------------- by age and bin double sort
     % data (2000, 2005)     
     % make new age cutoffs
     bin_boundsY = [0 35 100];
     
     quantilesYm=[.5];
     quantilesY=[.25 .5 .75 .1 .9];
     
     [bin_indsY0,bin_sharesY0,bin_meansY0,bin_quantilesY0] = ...
                     binitQ(model0.spreadsheet,model0.spreadsheet(:,1),5,bin_boundsY,quantilesYm);
     [bin_indsY5,bin_sharesY5,bin_meansY5,bin_quantilesY5] = ...
                     binitQ(models5{1}.spreadsheet,models5{1}.spreadsheet(:,1),5,bin_boundsY,quantilesYm);
     
     %bin_col = 16;
     for coh=1:length(bin_boundsY)-1;         
         
     [bin_indsHQD0y{coh},bin_sharesHQD0y{coh},bin_meansHQD0y{coh},bin_quantilesHQD0y{coh}]...
              = binitQ(model0.spreadsheet(bin_indsY0{coh},:),model0.spreadsheet(bin_indsY0{coh},1),...
                          16,bin_boundsQ0,quantilesY);                             
     [bin_indsHQD5y{coh},bin_sharesHQD5y{coh},bin_meansHQD5y{coh},bin_quantilesHQD5y{coh}]...
              = binitQ(models5{1}.spreadsheet(bin_indsY5{coh},:),models5{1}.spreadsheet(bin_indsY5{coh},1),...
                          16, bin_boundsQ5,quantilesY);  

     % model     
     if modelflag
     [bin_indsHQM0y{coh},bin_sharesHQM0y{coh},bin_meansHQM0y{coh},bin_quantilesHQM0y{coh}]...
              = binitQ(model0.spreadsheet(bin_indsY0{coh},:),model0.spreadsheet(bin_indsY0{coh},1),...
                           13,bin_boundsQ0,quantilesY);  
     end
     if modelflag5;
     for i=1:num_models5;                      
      [bin_indsHQM5y{i,coh},bin_sharesHQM5y{i,coh},bin_meansHQM5y{i,coh},bin_quantilesHQM5y{i,coh}]...
              = binitQ(models5{i}.spreadsheet(bin_indsY5{coh},:),models5{i}.spreadsheet(bin_indsY5{coh},1),...
                            13,bin_boundsQ5,quantilesY);                                            
     end;
     end;
     end;
     

%--------------------------------------------------------------------------------------
%============================== supply cdf documentation   
%--------------------------------------------------------------------------------------
     
       
    quants0=pchip(cumsum([0 census_masses_moved{1}]),census_grid);
    quants5=pchip(cumsum([0 census_masses_moved{2}(15:end)]),mean_census_grid{5}([1 16:end]));

    disp('2000 supply quantiles, 5/10/25/50/75/90 95');
    disp(exp(ppval(quants0,[.05 .1 .25 .5 .75 .9 .95])));
    disp('2005 supply quantiles, 5/10/25/50/75/90 95');
    disp(exp(ppval(quants5,[.05 .1 .25 .5 .75 .9 .95])));
    
    quintiles0=exp(ppval(quants0,[.2 .4 .6 .8]));
    quintiles5=exp(ppval(quants5,[.2 .4 .6 .8]));

%--------------------------------------------------------------------------------------
%============================== tables with pop stats   
%--------------------------------------------------------------------------------------
    
    
    
    %================= picture by age
    if table4
      age_profiles;
      return
    end


    %======================== tables by quality
    
  
    %-------------- table on cash by quality
    disp('  ');
    disp('  ');
    disp('========================================================');
    disp('====================== cash (ann.) by quality ==========');
    disp('========================================================');
    table_col=23;   
    table_by_quality
    disp('  ');
    disp('  ');
    disp('  ');
    disp('  ');
    disp('========================================================');
    disp('================ cash (ann.) by quality AND AGE ========');
    disp('========================================================');
    disp('  ');
    table_by_quality_n_age
    %-------------- table on age by quality
    disp('  ');
    disp('  ');
    disp('========================================================');
    disp('====================== income by quality ===============');
    disp('========================================================');
    table_col=6;   
    table_by_quality
    disp('  ');
    disp('  ');
    disp('  ');
    disp('  ');
    disp('========================================================');
    disp('================ income by quality AND AGE =============');
    disp('========================================================');
    disp('  ');
    table_by_quality_n_age
  
    