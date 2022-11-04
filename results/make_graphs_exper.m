clear;
close all;
make_slides=0; % = 1 for slides, = 0 for paper!
upperQ=800; % upper bound on quality, $000

% establish folder structure
current=pwd;% current dir
cd ..;
parent=pwd;
cd ..;
grandparent=pwd;
cd(current);


%----- set directories...
compute_dir = [parent '\'];
empmatlab_dir = [parent '\data\'];

% dir for the paper
print_dir = '.\';
% dir for the slides
Rf=1.03;
Rf_short=1.03;
std_p_idio=0.1472;
run([compute_dir 'set_parameters']);

%----- load cpi, BLS series CUUR0000SA0, not seas adj.
fid=fopen([empmatlab_dir 'cpitable2.txt']);
c=textscan(fid,'%*s%d8%s%f32');
fclose(fid);
pindex=c{3}(1:end-13);
% prepare price index 
pindexA = double(pindex(end-(2008-2000)*12:12:end));



load([empmatlab_dir 'Pricefunction.mat']);
price05spline = Pricefunction{5};

census_grid = log([1e3 10e3:5e3:40e3 50e3:10e3:1e5 125e3 150e3 175e3 200e3 ...
                                   250e3 300e3 400e3 500e3 750e3 1e6 5e6]);           
census_bins=length(census_grid)-1;

%--------------- supply cdf documentation
load([empmatlab_dir 'censusdata2mn_21']);
load([empmatlab_dir 'newacsdata2mn_21']);

quants0=pchip(cumsum([0 census_masses_moved{1}]),census_grid);
quants5=pchip(cumsum([0 census_masses_moved{2}(15:end)]),mean_census_grid{5}([1 16:end]));

quintiles0=exp(ppval(quants0,[.2 .4 .6 .8]))*(pindexA(6)/pindexA(1))/1000;
quintiles5=exp(ppval(quants5,[.2 .4 .6 .8]))*(pindexA(6)/pindexA(1))/1000;

% ------------------------------------------------------
% now load file containing actual experiments 

load('experlist_20140418.mat');

color_seq={'b-','c-','m-','r-','g-','m-'};
style_seq={'b-','b-.','b-.','b-.','b-.','b-.','b-.','b-.'};
legend_seq={'2005 model', 'perfect foresight','only credit conditions','only house density','2000 credit'};

%plotoption = 1; % subplots 
this_exper={'newbase','perffore','credit_only','supp2005','serv2005_price'};
this_legend=[1 2 3 4 5 6];
                              
% equilibrium service flow functions
serv_points0=experlist.service.serv_points;
serv_vals0=experlist.service.serv_vals;
approx_points0=[Hlower,serv_points0,Hupper];
pp0=pchip(approx_points0,[Slower,serv_vals0]);


% points for plotting
hvals=linspace(0.5,Hupper_census,150);

% 2000 service flow picture
figure;
plot((pindexA(6)/pindexA(end))*hvals*normfact/1000,ppval(pp0,hvals),'LineWidth',2);
xlabel('Quality ( = house value in 2000, $000s)','fontsize',16);
ylabel('Service Flow','fontsize',16);
set(gca,'YLim',[1,120],'XLim',[0,upperQ],'fontsize',14,'YTick',0:20:120,'XTick',0:200:upperQ);
axis tight;
cd(print_dir);
%print('-depsc','service2000pic');
cd(current);


serv_points5=experlist.serv2005.serv_points;
serv_vals5=exp(experlist.serv2005.serv_search_guess);
approx_points5=[Hlower,serv_points5,Hupper];
pp5=pchip(approx_points5,[Slower,serv_vals5]);


% make splines for all price experiments
nrexp=length(this_exper);
pp_array=cell(nrexp,1);
for j=1:nrexp
    points=experlist.(this_exper{j}).price_search_points;
    vals=exp(experlist.(this_exper{j}).price_search_guess);
    approx_points=[Hlower,points,Hupper];
    pp_array{j}=pchip(approx_points,[Plower,vals]);
end

% price function
prices00=hvals*10;  % this is now in 2005 prices
capgain=[];
legendnow=cell(nrexp+2,1);
legendnow{1}='2000 prices';
legendnow{2}='2005 data';


%======================== for the paper


numlist=4;
lists=cell(numlist,1);
lists{1}=1; 
lists{2}=[1 3 4];
lists{3}=2;
lists{4}=[5];
plotoption = [1 3 5 4];
picnames={'results_benchmark','results_credit_supp','results_expec','results_serv'};

for kk=1:numlist; 
    
    
    switch plotoption(kk)
        
        
        case 1      % narrow, price and capgain next to each other
            
            figure

            set(gcf,'PaperSize',[12 4],'PaperPosition',[0 0 12 4]);
             
            titleflag=0;
            
            listnow=lists{kk};
            legendnow=cell(length(listnow),1);
            legendnow{1}='2000 prices';
            legendnow{2}='2005 data';
            legendflag=1;
            
            fs_title=16;
            fs_labels=14;
            fs_ticks=10;
            
            subplot(1,2,1);
            axis_price;
            
            subplot(1,2,2);
            axis_capgain;
    
        case 2      % 4 way plot, capgain
            
            figure

            set(gcf,'PaperSize',[12 4],'PaperPosition',[0 0 12 4]);

            fs_title=14;
            fs_labels=10;
            fs_ticks=8;

            titleflag=0;
            
            for jj=1:4;
            
            listnow=lists{kk}([1 jj+1]);
            
            if jj==1;
            legendflag=1;
            legendnow=cell(length(listnow),1);
            legendnow{1}='2000 prices';
            legendnow{2}='2005 data';
            else
            legendflag=0;
            legendnow=cell(length(listnow)-1,1);
            legendnow{1}='2000 prices';
            end
            
            subplot(2,2,jj);
            
            axis_capgain;
             
            end;
            
        case 3   % 2 way plot, capgain    
            
            figure

            fs_title=16;
            fs_labels=14;
            fs_ticks=10;

            set(gcf,'PaperSize',[12 4],'PaperPosition',[0 0 12 4]);
            
            for jj=1:2;
            
            listnow=lists{kk}([1 jj+1]);
            
            titleflag=0;
            
            if jj==1;
            legendflag=1;
            legendnow=cell(length(listnow),1);
            legendnow{1}='2000 prices';
            legendnow{2}='data';
            else
            legendflag=0;
            legendnow=cell(length(listnow)-1,1);
            legendnow{1}='2000 prices';
            end
            
            subplot(1,2,jj);
            
            axis_capgain;
            end           
            
        case 4      % service flow - leave out now
             
            figure;
            set(gcf,'PaperSize',[12 4],'PaperPosition',[0 0 12 4]);

            fs_title=16;
            fs_labels=14;
            fs_ticks=10;            

            subplot(1,2,1)
            hold on;
            plot((pindexA(6)/pindexA(end))*hvals*normfact/1000,ppval(pp0,hvals),'b-','LineWidth',2);
            plot((pindexA(6)/pindexA(end))*hvals*normfact/1000,ppval(pp5,hvals),'g-','LineWidth',2);
            xlabel('Quality ( = house value in 2000, $000s)','fontsize',fs_labels);
            ylabel('Service flow','fontsize',fs_labels);
            set(gca,'YLim',[1,120],'XLim',[0,upperQ],'fontsize',fs_ticks,'YTick',0:20:120,'XTick',0:200:upperQ);
            legstring = {'from 2000 prices','from 2005 prices'};
            legend(legstring,'Location','SouthEast','FontSize',fs_labels);
      %      title('Service flow functions','Fontsize',fs_title);
            axis tight;
            
            subplot(1,2,2);
            hold on;
            
            listnow=lists{kk};
            
            titleflag=0;
            
            legendnow=cell(length(listnow),1);
            legendnow{1}='2000 prices';
            legendnow{2}='data = model';
            legendflag=1;
            
            axis_capgain;

        case 5        % single graph with capgain    
            figure

            fs_title=16;
            fs_labels=14;
            fs_ticks=10;

            set(gcf,'PaperSize',[12 4.5],'PaperPositionMode','auto');
            
            listnow=lists{kk};
            
            legendflag=1;
            legendnow=cell(length(listnow),1);
            legendnow{1}='2000 prices';
            legendnow{2}='data';
                        
            axis_capgain;
            
            
    end       
    
    cd(print_dir);
    %print('-depsc',picnames{kk});
    %print('-dpdf',picnames{kk});
    cd(current);
    
end






