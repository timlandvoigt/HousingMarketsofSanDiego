
T=22;

% general parameters
tc = 0.08;
psi = 3*0.015;
rho = 0.2;
gamma = 5;
L = 0.5;
beta = 0.95^3;

% express all dollar amounts in 10K for computation
normfact=10000;
% CPI factor to transform 2000 into 2008 dollars
inffact2000=218.6100/172.7000;
% highest possible house quality (at 2.5 million)
Hupper=500;
Hupper_census=121;
Hlower=0.1;
Plower=0.001;
Slower=0.001;

% tax rate
tau=0.2;

% adjust interest rates for taxes
Rf=1+(1-tau)*(Rf-1);
Rf_short=1+(1-tau)*(Rf_short-1);

% life-cycle mortality rates
DPR=[0.002
0.002867255
0.003086821
0.003585711
0.00431379
0.005240834
0.006545691
0.008187596
0.010383925
0.013072737
0.016716218
0.021977495
0.029005766
0.038194513
0.0487957
0.062456609
0.081108131
0.102138272
0.128035442
0.168018617
0.222314559
0.285706319
1];

% load additional input generated from census data
load([empmatlab_dir,'more_inputs.mat']); 

% deterministic part of labor income process
YGR=incgrowthrates;

% life-cycle mobility rates
PRM=mobprofile;

% mean growth rate
gro=3*0.02;
% std.dev. of permanent income shock
std_y_perm=0.2;
% std.dev. of transitory income shock
std_y_trans=0.25;

% effective means (after adjusting for 1/2 variance)
m_y_perm=gro-0.5*std_y_perm^2;
m_y_trans=-0.5*std_y_trans^2;
m_p_idio=-0.5*std_p_idio^2;

% Shocks low and high realizations
y_perm_shock=m_y_perm+[-std_y_perm,std_y_perm];
y_trans_shock=m_y_trans+[-std_y_trans,std_y_trans];
p_idio_shock=m_p_idio+[-std_p_idio,std_p_idio];

% aggregate house price shock; degenerate
p_aggr_shock=0;

% Probability matrix for households before retirement
process_pre = [1/8	 y_perm_shock(1)	y_trans_shock(1) p_aggr_shock(1) p_idio_shock(1);
           1/8	 y_perm_shock(1)	y_trans_shock(1) p_aggr_shock(1) p_idio_shock(2);
           1/8	 y_perm_shock(1)	y_trans_shock(2) p_aggr_shock(1) p_idio_shock(1);
           1/8	 y_perm_shock(1)	y_trans_shock(2) p_aggr_shock(1) p_idio_shock(2);
           1/8	 y_perm_shock(2)	y_trans_shock(1) p_aggr_shock(1) p_idio_shock(1);
           1/8	 y_perm_shock(2)	y_trans_shock(1) p_aggr_shock(1) p_idio_shock(2);
           1/8	 y_perm_shock(2)	y_trans_shock(2) p_aggr_shock(1) p_idio_shock(1);
           1/8	 y_perm_shock(2)	y_trans_shock(2) p_aggr_shock(1) p_idio_shock(2)];
       
% std.dev. of permanent income shock after retirement
std_y_perm_ret=0.1;
% std.dev. of transitory income shock after retirement
std_y_trans_ret=0.125;       
% effective means (after adjusting for 1/2 variance) post ret
m_y_perm_ret=gro-0.5*std_y_perm_ret^2;
m_y_trans_ret=-0.5*std_y_trans_ret^2;
% Shocks low and high realizations post ret
y_perm_shock_ret=m_y_perm_ret+[-std_y_perm_ret,std_y_perm_ret];
y_trans_shock_ret=m_y_trans_ret+[-std_y_trans_ret,std_y_trans_ret];

% Probability matrix for households after retirement
process_post = [1/8	 y_perm_shock_ret(1)	y_trans_shock_ret(1) p_aggr_shock(1) p_idio_shock(1);
           1/8	 y_perm_shock_ret(1)	y_trans_shock_ret(1) p_aggr_shock(1) p_idio_shock(2);
           1/8	 y_perm_shock_ret(1)	y_trans_shock_ret(2) p_aggr_shock(1) p_idio_shock(1);
           1/8	 y_perm_shock_ret(1)	y_trans_shock_ret(2) p_aggr_shock(1) p_idio_shock(2);
           1/8	 y_perm_shock_ret(2)	y_trans_shock_ret(1) p_aggr_shock(1) p_idio_shock(1);
           1/8	 y_perm_shock_ret(2)	y_trans_shock_ret(1) p_aggr_shock(1) p_idio_shock(2);
           1/8	 y_perm_shock_ret(2)	y_trans_shock_ret(2) p_aggr_shock(1) p_idio_shock(1);
           1/8	 y_perm_shock_ret(2)	y_trans_shock_ret(2) p_aggr_shock(1) p_idio_shock(2)];

process=cell(T,1);
process(1:14)={process_pre};
process(15:end)={process_post};
       
% rename bequest parameter            
LPVBASE = L;

        

