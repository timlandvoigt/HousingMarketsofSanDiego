function [obj,hpol,housexp,sav,...
           polmat_out,valfct,dem_quants]=calc_ex_dem_interp(find_coefs,fct_mode,LR_val_coef,LR_prices,doc)
    
    global Plower  
    global gridW  gridY
    global survey_comp Slower approx_points
    global p_services p_prices p_prices_expec p_delta gro
    global print_flag T current_vals
    global quant_points supp_cdf_inv normfact inffact vf_short
        
    %----- make service or price spline using find_coefs at approx_points
    ap_vals=find_coefs;
    current_vals=ap_vals;
    if strcmp(fct_mode,'service')
        p_services=pchip(approx_points,[Slower,exp(ap_vals)]);
        p_prices_expec=p_prices; % service flow computation always with "endogenous" expectations
    else
        % fct_mode=='prices'
        p_prices=pchip(approx_points,[Plower,exp(ap_vals)]);
        if ~isempty(LR_prices)
           p_prices_expec=LR_prices; % "exogenous" expectations
        else
           p_prices_expec=p_prices; % "endogenous" expectations
        end
    end
    
   
   disp(' ');
   disp('Function spec.:');
   for i=1:length(ap_vals)
       fprintf('%6.2f\t%6.5f\n',approx_points(i+1),exp(ap_vals(i)));
   end
   disp('==================================================================');
       
    nobs=size(survey_comp,1);
    pol=zeros(nobs,1);
    hpol=zeros(nobs,1);
    
    cpol=zeros(nobs,1);
    housexp=zeros(nobs,1);
    sav=zeros(nobs,1);
      
    valfct=cell(T+1,2);
    polmat_out=cell(T,2);

    
    disp('Computing demand ...');
    tic;
    V=hdemand([],T+1);  % only used for endog expec. case
    % approx value functions
    for i=1:2
        valfct{T+1,i}=V{i};
    end
 
    
    for t=T:-1:1
        % deltafunction for this age
        p_delta=makedeltafct(t,100);
        % if exog. expectations then LR_val_coef contains coefs of long-run VF
        if isempty(LR_val_coef)
            vf_short=0;
            V=hdemand(valfct(t+1,:),t);
        else
            vf_short=1;
            V=hdemand(LR_val_coef(t+1,:),t);
        end
        
        for i=1:2
            valfct{t,i}=V{i};
        end
        % age-bin and mover-flag selector
        agesel=(survey_comp(:,4)==t);

        cash_sel=survey_comp(agesel,2);
        inc_sel=survey_comp(agesel,3);
        hpolmat=squeeze(V{3}(:,:,1));
        poltmp=interpn(gridW,gridY',hpolmat,cash_sel,inc_sel,'linear');

        % deal with guys who are just too rich
        tr_sel=(cash_sel>gridW(end));
        if sum(tr_sel)>0
            tr_cash=cash_sel(tr_sel);
            tr_inc=inc_sel(tr_sel);
            tr_obs=length(tr_cash);
            tr_polmax=interpn(gridW,gridY',hpolmat,ones(tr_obs,1)*gridW(end)-0.01,tr_inc);
            tr_hwrat=tr_polmax/gridW(end);
            tr_pol=tr_cash.*tr_hwrat;
            poltmp(tr_sel)=tr_pol;
        end
        if sum(isnan(poltmp))>0
            disp('stupid');
        end
        hpol(agesel)=poltmp;
        pol(agesel)=pricefct(hpol(agesel),t,p_prices,gro,inffact);
        polmat_out{t,1}=hpolmat;
        
        if doc
            % transform policy into actual housing expenditure, in raw $$
            housexp(agesel) = normfact * pol(agesel)./exp((t-1)*gro);
            % to define savings, need consumption policyalso
            cpolmat=squeeze(V{3}(:,:,2));
            cpoltmp=interpn(gridW,gridY',cpolmat,cash_sel,inc_sel,'linear');
            % deal with guys who are just too rich
            if sum(tr_sel)>0
                tr_polmax=interpn(gridW,gridY',cpolmat,ones(tr_obs,1)*gridW(end)-0.01,tr_inc);
                tr_hwrat=tr_polmax/gridW(end);
                tr_pol=tr_cash.*tr_hwrat;
                cpoltmp(tr_sel)=tr_pol;
            end
            if sum(isnan(cpoltmp))>0
                disp('stupid cons');
            end
            cpol(agesel)=cpoltmp;
            polmat_out{t,2}=cpolmat;
            % compute savings, use unadjusted wealth from survey_comp & transformed consumption
            sav(agesel) = survey_comp(agesel,5)*normfact - housexp(agesel)...
                - normfact * cpol(agesel) ./ exp((t-1)*gro);
        end
                
    end
    toc;
    
    %---------------- form aggregate demand
    
    % total sum of weights
    weights=survey_comp(:,1);
    totw=sum(weights);
          
    % make empirical cdf of demand using weights
    B=sortrows([hpol,weights],1);
    x=cumsum(B(:,2))/totw;
    [demdist,ind]=unique(B(:,1),'last');
    x=x(ind);
    
    % evaluate inverse supply cdf at quant points
    supp_quants=ppval(supp_cdf_inv,quant_points);
    supp_quants=exp(supp_quants)/normfact;
    
    % evaluate demand cdf at these points
    dem_quant_points=interp1(demdist,x,supp_quants);
    dem_quants=interp1(x,demdist,quant_points);
    
    % excess demand (as deviation of cdfs)
    diff_obj=quant_points-dem_quant_points;
    obj=sum(diff_obj.^2);
    
    % additional stats characterizing fit
    avg_dev=sqrt(obj/length(quant_points));
    [max_dev,max_ind]=max(abs(diff_obj));
        
    
    %^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ reporting of results
    disp('----------------------------------------------');
    disp(['Object. Function: ',num2str(obj)]);
    if ~strcmp(fct_mode,'linear')
        disp(['Max. Deviation: ',num2str(max_dev),' at quantile ', num2str(quant_points(max_ind))]);
        disp(['Avg. Deviation: ',num2str(avg_dev)]);
    end
    % report more output if flag is set
    if print_flag
        fprintf('Supp.CDF\tDem.CDF.\tSupply\tDemand\n');
        if strcmp(fct_mode,'linear')
            disp(num2str([dem_quants,supp_mean]));
        else
            for i=1:length(quant_points)
                fprintf('%6.3f\t\t%6.3f\t\t%6.3f\t\t%6.3f\n',quant_points(i),dem_quant_points(i),supp_quants(i),dem_quants(i));
            end
        end
        diary off; diary on;
    end
        
end