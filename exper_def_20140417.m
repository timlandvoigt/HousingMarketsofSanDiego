% define all experiments and save definitions in big structure for
% main_control
          
% vectors with function values at spline knots
serviceguess=[  3.00	0.99969
  6.00	3.48484
 10.00	8.02563
 12.00	10.56276
 17.00	16.41433
 25.00	24.5397
 40.00	34.47530
 60.00	43.13568
 80.00	48.94901
500.00	80.01942];

serv2005guess=[     5.0000    2.8209
   10.0000    10.6460
   14.0000   16.3899
   20.0000   23.8852
   27.0000   30.4764
   40.0000   37.8753
   70.0000   47.0878
  500.0000   75.3142];


baseguess=[  5.00	15.67452
  9.00	23.22436
 12.00	28.64282
 19.00	40.07008
 29.00	54.15156
 45.00	75.48625
 70.00	106.65998
 90.00	121.67981
500.00	700.38787];


newbaseguess2=[      5.0000   22.5852
    10.00   33.2962
    14.00   41.4156
    20.00   52.5110
    27.00   64.4827
    40.00   87.3612
    70.00	130.56590
    500.00	550.69790];


perfforeguess=[    5.0000   10.0100
   10.0000   16.1202
   14.0000   21.3000
   20.0000   28.8495
   27.0000   37.3843
   40.0000   52.9622
   70.0000   87.6982
  500.0000  550.8440];

credit_only_guess2=[    5.0000   14.0088
   10.0000   21.6405
   15.0000   28.7358
   20.0000   36.5485
   27.0000   47.5427
   37.0000   63.5274
   50.0000   85.1596
   90.0000  146.9205
  500.0000  550.5295];

supp2005_guess=[ 
    5.0000   14.9025
   10.0000   21.8298
   14.0000   26.8953
   20.0000   34.0615
   27.0000   41.8259
   40.0000   55.8083
   70.0000   83.0258
  500.0000  215.4492];

serv2005_price_guess2=[5.0000   15.3025
   10.0000   24.5298
   14.0000   30.6953
   20.0000   38.6615
   27.0000   46.7259
   40.0000   60.8083
   70.0000   87.0258
  500.0000  300.4492];

prices05data=[     5.0000   19.3522
    9.0000   28.8298
   12.0000   35.0258
   19.0000   47.8594
   29.0000   63.6553
   45.0000   85.8652
   70.0000  115.2976
   90.0000  134.4996
  500.0000  473.1008];



% service 2000 base structure
xpser=struct('fct_mode', 'service', ...
        'exp_mode', 'endog', ...
        'demand_survey_index', 1, ...
        'supply_survey_index', 1, ...
        'LR_price_points', [3.5 15 40 75], ...
        'LR_price_vals', log([3.5 15 40 75 500]), ...
        'delta', 0.2000, ...
        'delta_short', 0.2000, ...
        'Rf', 1.0927, ...
        'Rf_short', 1.0927, ...
        'xi',3*0.02,...
        'xi_short',3*0.02,...        
        'std_p_idio', 0.1472, ... sqrt(3*0.09^2)
        'serv_points', serviceguess(1:end-1,1)', ...
        'serv_vals', serviceguess(:,2)', ...
        'serv_search_guess', log(serviceguess(:,2)'), ...
        'price_search_points', [3.5000 8.5000 15 40 75], ...
        'price_search_guess', [2.4849 3.0176 3.3667 4.2605 4.6563 5.2755], ...
        'quant_points', [0.05,0.1,0.25,0.5,0.75,0.9,0.95]');
    
    
experlist=struct('service',xpser);

% case with long run paramters for credit conditions
xpbase=struct('fct_mode', 'price', ...
        'exp_mode', 'exog', ...
        'demand_survey_index', 4, ...
        'supply_survey_index', 4, ...
        'LR_price_points', [3.5000 15 40 75], ...
        'LR_price_vals', log([3.5000 15 40 75 500])+5*0.02, ...
        'delta',0.2, ...
        'delta_short', 0.2000, ...
        'Rf', 1.03^3, ...
        'Rf_short', 1.03^3, ...
        'xi',3*0.02,...
        'xi_short',3*0.02,...        
        'std_p_idio', 0.1472, ... sqrt(3*0.09^2)
        'serv_points', serviceguess(1:end-1,1)', ...
        'serv_vals', serviceguess(:,2)', ...
        'serv_search_guess', log(serviceguess(:,2)'), ...
        'price_search_points', newbaseguess2(1:end-1,1)', ...
        'price_search_guess', log(newbaseguess2(:,2)'), ...
        'quant_points', [0.05,0.15,0.3,0.5,0.7,0.85,0.95]');

experlist.base=xpbase;

% baseline case with actual credit conditions in 2005
xptmp=xpbase;
xptmp.Rf_short=1.01^3;
xptmp.delta=0.05;
xptmp.delta_short=0.05;
xptmp.xi=3*0.013;
xptmp.xi_short=3*0.013;
xptmp.LR_price_points=newbaseguess2(1:end-1,1)';
xptmp.LR_price_vals=log(newbaseguess2(:,2)');
xptmp.price_search_points= newbaseguess2(1:end-1,1)';
xptmp.price_search_guess=log(newbaseguess2(:,2)');
experlist.newbase=xptmp;

% credit only case
xptmp=xpbase;
xptmp.Rf_short=1.01^3;
xptmp.delta=0.05;
xptmp.delta_short=0.05;
xptmp.xi=3*0.013;
xptmp.xi_short=3*0.013;
xptmp.demand_survey_index=1;
xptmp.supply_survey_index=1;
xptmp.LR_price_points=credit_only_guess2(1:end-1,1)';
xptmp.LR_price_vals=log(credit_only_guess2(:,2)');
xptmp.price_search_points= credit_only_guess2(1:end-1,1)';
xptmp.price_search_guess=log(credit_only_guess2(:,2)');
experlist.credit_only=xptmp;


% 2005 supply, 2000 demand
xptmp=xpbase;
xptmp.LR_price_points=supp2005_guess(1:end-1,1)';
xptmp.LR_price_vals=log(supp2005_guess(:,2)');
xptmp.price_search_points= supp2005_guess(1:end-1,1)';
xptmp.price_search_guess=log(supp2005_guess(:,2)');
xptmp.demand_survey_index=1;
xptmp.supply_survey_index=4;
experlist.supp2005=xptmp;


% perfect foresight
xptmp=xpbase;
xptmp.Rf_short=1.01^3;
xptmp.Rf=1.01^3;
xptmp.delta=0.2;
xptmp.delta_short=0.05;
xptmp.xi_short=3*0.013;
xptmp.std_p_idio=0.2044;
xptmp.price_search_points= perfforeguess(1:end-1,1)';
xptmp.price_search_guess=log(perfforeguess(:,2)');
experlist.perffore=xptmp;


% service flow at 2005 prices
xptmp=experlist.newbase;
xptmp.fct_mode='service';
xptmp.LR_price_points=prices05data(1:end-1,1)';
xptmp.LR_price_vals=log(prices05data(:,2)');
xptmp.serv_points= serv2005guess(1:end-1,1)';
xptmp.serv_search_guess=log(serv2005guess(:,2)');
experlist.serv2005=xptmp;

% price function
xptmp=xpbase;
xptmp.exp_mode='endog';
xptmp.serv_points= serv2005guess(1:end-1,1)';
xptmp.serv_vals=serv2005guess(:,2)';
xptmp.price_search_points= serv2005_price_guess2(1:end-1,1)';
xptmp.price_search_guess=log(serv2005_price_guess2(:,2)');
experlist.serv2005_price=xptmp;



