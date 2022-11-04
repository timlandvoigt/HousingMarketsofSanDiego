function V=hdemand(valfct,age)

    % parameters of utility function, probability of survival etc.
    global rho psi delta delta_short tc LPVBASE stateBoundsInterp
    global gridH numberGridPoints gridY gridW
    global vf_short 
    
    global process gamma beta xi xi_short Rf Rf_short YGR PRM DPR
    global p_prices p_prices_expec p_services gro inffact
    
    
    if isempty(valfct)
        termin=1;
    else
        termin=0;
    end
    
    V=cell(5,1);
       
    npth=length(gridH);
    nptw=length(gridW);
    npty=length(gridY);
    V_mov=zeros(nptw,npty,1);
    V_stay=zeros(nptw,npty,npth);
    pol_stay=zeros(nptw,npty,npth,3);
    pol_mov=zeros(nptw,npty,3);
    hi_mov=zeros(nptw,npty);
    
    if ~termin
        % get arguments ready for call to hdemand_grid ready
        % parameters
        if vf_short
            R_curr=Rf_short;
            delta_curr=delta_short;
            xi_curr=xi_short;
        else
            R_curr=Rf;
            delta_curr=delta;
            xi_curr=xi;
        end
        params=[gamma,rho,beta,tc,psi,xi_curr,R_curr,PRM(age),DPR(age),YGR(age)];
        % matrix for stayer function
        SgridHmat=[gridH';
            pricefct(gridH',age,p_prices,gro,inffact);
            pricefct(gridH',age,p_prices_expec,gro,inffact)*exp(gro);
            servicefct(gridH',age,p_services,gro);
            deltafct(gridH',delta_curr)]';
    end
    
% /**************************************************************/
% // arguments
% // 1: cons search mode flag
% // 2: 1 x 2 vector containing state pair [W,Y]
% // 3: NCH x 5 vector with grid of feasible choices for H (for movers)
% //    and associated values for prices, service flow, and delta;
% //    first row: choice points
% //    second: prices
% //    third: expected prices
% //    four: service flow
% //    five: delta      
% // 4: MinIndex: lowest index in choice grid at which to start searching
% // 5: NSH x 5 vector with grid of state points for H (for stayers)
% //    and associated values for prices, exp. prices, service flow, and delta;
% //    row order same as above
% // 6: 1 x NPARAM vector with scalar parameters to be passed in order
% // 7: matrix with stochastic process for innovations to income and housing, RV x NS
% //    first row: probabilities
% //    second row: innovation to permanent component
% //    third: temporary innovation
% // 8: matrix with bounds of state variable grids 3 x 3
% // 9: 1 x 2 cell array with value functions 
% //    first element: mover function, NPmov X 2
% //    second element: stayer function, NPstay x 3
% // 10: matrix with number of points for each equally-spaced segment, 2 x 3  
    
    if termin
        % compute bequest value
        for i=1:nptw
            W=gridW(i);
            lastPeriodVal = LPVBASE * W / (0.07 * pricefct(10,age,p_prices,gro,inffact))^rho;
            V_mov(i,:)=ones(npty,1)*lastPeriodVal;
        end

    else
        % parallel loop over wealth dimension
        parfor wi=1:nptw
            W=gridW(wi);
            lastPeriodVal = LPVBASE * W / (0.07 * pricefct(10,age,p_prices,gro,inffact))^rho;
            V_mov_tmp=zeros(npty,1);
            pol_mov_tmp=zeros(npty,3);
            V_stay_tmp=zeros(npty,npth);
            pol_stay_tmp=zeros(npty,npth,3);
            hi_mov_tmp=zeros(npty,1);
            hi_start_y=0;
            for yi=1:npty
                Y=gridY(yi);
                if wi<nptw
                    Wbound=gridW(wi+1);
                else
                    Wbound=gridW(nptw);
                end
                if Y<Wbound
                    % this point in state space
                    pointWY=[W,Y];
                    % choice grid for H and associated values
                    CgridHmat=SgridHmat;
                    % add LPV to params vectors
                    paramsW=[params,lastPeriodVal];
                    % call mex function; can impose monotonicity in both
                    % dimensions by specifying lower bound on optimal h index
                    Vtmp=hdemand_grid(1, pointWY, CgridHmat, hi_start_y, SgridHmat, paramsW, process{age}', stateBoundsInterp, ...
                        valfct, numberGridPoints);
                    %-----------------------------------
                    V_mov_tmp(yi)=Vtmp{1};
                    pol_mov_tmp(yi,:)=Vtmp{2};
                    V_stay_tmp(yi,:)=Vtmp{3};
                    pol_stay_tmp(yi,:,:)=Vtmp{4}';
                    hi_mov_tmp(yi)=Vtmp{5};
                else
                    % this can only happen for yi>1
                    V_mov_tmp(yi)=V_mov_tmp(yi-1);
                    pol_mov_tmp(yi,:)= pol_mov_tmp(yi-1,:);
                    V_stay_tmp(yi,:)= V_stay_tmp(yi-1,:);
                    pol_stay_tmp(yi,:,:)=pol_stay_tmp(yi-1,:,:);                 
                    hi_mov_tmp(yi)=hi_mov_tmp(yi-1);
                end
            end
            % sliced variables due to parallel loop
            V_mov(wi,:)=V_mov_tmp;
            pol_mov(wi,:,:)=pol_mov_tmp;
            V_stay(wi,:,:)=V_stay_tmp;
            pol_stay(wi,:,:,:)=pol_stay_tmp;
            hi_mov(wi,:)=hi_mov_tmp;  
        end
    end
    
    
    if termin
        V{1}=reshape(V_mov,npty*nptw,1); 
        V{2}=repmat(V{1},npth,1);
    else
        V_mov=reshape(V_mov,npty*nptw,1);    
        V_stay=reshape(V_stay,npty*nptw*npth,1);
        V{1}=V_mov;
        V{2}=V_stay;
        V{3}=pol_mov;
        V{4}=pol_stay;
        V{5}=hi_mov;
    end
    
end