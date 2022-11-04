%^^^^^^^^^^^^^^^^^^^^^^^^^^ load survey data
%  sandiego code produces 2 files
%
%  censusdata contains 
%        splines        census_spline census_spline_movedI
%
%         I refers to "Improved"
%
%  newacsdata contains 
%        cell arrays    price00_spline price00_spline_moved
%

supplycdf = cell(1,8);
supplycdf_moved = cell(1,8);
load([empmatlab_dir,'censusdata2mn_21.mat']); 
supplycdf{1}=census_spline;
supplycdf_moved{1}=census_spline_moved;

load([empmatlab_dir,'newacsdata2mn_21.mat']);
supplycdf([4 6])=price00_spline;
supplycdf_moved([4 6])=price00_spline_moved;


% load data from stata-generated text files
% recall survey format: in all surveys, the first 8 columns are
%  wgt_census / movedin / new / age / hhincome3_inf / cash_inf / valueh_inf / valueh / hhincome / mortgage_dum / mortpmt / nw_imp
% suffix _08 stands for 2008 dollars (CPI)
%  also moveM is defined differently in 2 surveys
%        census: 1 = moved in last 2 years
%        acs:    1(2) = moved in SD (outside) in last year 

survey_years=[2000 2002 2003 2005:2008 2005];
survey_all=cell(1,8); % 00 Census, 02 AHS, 03, 05-08 ACS

survey_all{1}=dlmread([stata_dir 'census_demand.txt']);
survey_all{4}=dlmread([stata_dir 'acs05_demand.txt']);


% make age-model map
age_bins=[0,23:3:86];




