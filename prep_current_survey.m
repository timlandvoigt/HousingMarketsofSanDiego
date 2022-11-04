% store formatted survey and grids for every period
survey_comp_all = cell(8,1);
stateBounds_all = cell(8,1);

% recall survey format: in all surveys
%  wgt_census / movedin / new / age / hhincome_inf / valueh_inf / wealth_inf / mortgage_dum / mortpmt


%^^^^^^^^^^^^^^^^^^^^^^^^^^ format surveys
sel_surveys=demand_survey_index;
for jj=1:length(sel_surveys);
    
    indnow = sel_surveys(jj);
    surv_yr = survey_years(indnow);
    survey = survey_all{indnow};

    % movers only
    moverflag=(survey(:,2)==1);
    survey=survey(moverflag,:);
    
    % normalize house weights to sum to one!
    survey(:,1)=survey(:,1)/sum(survey(:,1));

    numobs=size(survey,1);
    stateBounds=zeros(2,2);

    age=survey(:,4);
    inc=3*(1-tau)*survey(:,5)/normfact;
    cash=survey(:,7)/normfact + inc;
    %^^^^^^^^^^^^^^^^ age map
    mapAGE = sum(age*ones(1,length(age_bins)-1) > ones(numobs,1)*age_bins(1:end-1), 2);       
    
    % adjust state variables for age-specific growth
    cash_adj=cash.*exp((mapAGE-1)*gro);
    inc_adj=inc.*exp((mapAGE-1)*gro);
    
    % keep bounds for cash constant
    stateBounds(1,1) = .25;
    stateBounds(2,1) = 750;

    % set bounds for income based on survey
    stateBounds(1,2) = max(min(inc_adj)-0.01,0.1);
    stateBounds(2,2) = max(inc_adj)+0.01;
    inc_adj(inc_adj<stateBounds(1,2))=stateBounds(1,2)+0.01;

    %^^^^^^^^^^^^^^^^^ add into new array 
    survey_copy=[survey(:,1), ... weights,
        cash_adj, ...
        inc_adj, ...
        mapAGE, ...
        cash];
   
    survey_comp_all{indnow} = survey_copy;
    stateBounds_all{indnow}=stateBounds;

end;

% clean up
clear censusdata newacsdata cash inc ...
        cash_adj inc_adj mapAGE chebyterms survey_copy;



%------------------ grids and supply spline for target year

survey_comp=survey_comp_all{demand_survey_index};
stateBounds=stateBounds_all{demand_survey_index};

% form state bounds and separate interpolation segments
stateBoundsInterp=[stateBounds(1,1),60,stateBounds(2,1);
                   stateBounds(1,2),60,stateBounds(2,2);
                   Hlower,50,Hupper]';

% grid points per interpolated segment
numberGridPoints=[15,10; 15,10; 150,75]';

% build grids for interpolation segments               
lo_int=linspace(stateBoundsInterp(1,1),stateBoundsInterp(2,1),numberGridPoints(1,1));               
hi_int=linspace(stateBoundsInterp(2,1),stateBoundsInterp(3,1),numberGridPoints(2,1));               
gridW=[lo_int,hi_int(2:end)]';    
lo_int=linspace(stateBoundsInterp(1,2),stateBoundsInterp(2,2),numberGridPoints(1,2));               
hi_int=linspace(stateBoundsInterp(2,2),stateBoundsInterp(3,2),numberGridPoints(2,2));               
gridY=[lo_int,hi_int(2:end)]';
lo_int=linspace(stateBoundsInterp(1,3),stateBoundsInterp(2,3),numberGridPoints(1,3));               
hi_int=linspace(stateBoundsInterp(2,3),stateBoundsInterp(3,3),numberGridPoints(2,3));               
gridH=[lo_int,hi_int(2:end)]';

SSGridMov=grid.TensorGrid({gridW,gridY});
SSGridStay=grid.TensorGrid({gridW,gridY,gridH});

        
%------------- prepare supply 
%-- will be used for checking equilibrium quantities using bins
%-- we do the comparison of distribution in LOG quality space

supp_cdf = supplycdf_moved{supply_survey_index};
supp_cdf_inv=makeinverse(supp_cdf,100);


      

