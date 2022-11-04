
    %------------- model inputs by age (income & wealth)    
    
    figure;
    subplot(2,2,1);
    hold on;
    plot(bin_pointsA,bin_meansA0(:,6),'b-o','LineWidth',2);
    plot(bin_pointsA,bin_meansA0(:,11),'r-o','LineWidth',2);
    plot(bin_pointsA,bin_meansA0(:,10),'g-o','LineWidth',2);
    plot(bin_pointsA,bin_quantilesA0(:,6,2),'b:*','LineWidth',2);
    plot(bin_pointsA,bin_quantilesA0(:,11,2),'r:*','LineWidth',2);
    plot(bin_pointsA,bin_quantilesA0(:,10,2),'g:*','LineWidth',2);
    legend('income','wealth','cash');
    title('means (solid) and medians (dotted) by age');
    axis tight;
    
    subplot(2,2,2);
    hold on;
    plot(bin_pointsA,bin_meansA0(:,6),'b-o','LineWidth',2);
    plot(bin_pointsA,bin_topsharesA0(:,6).*bin_meansA0(:,6),'b-.','LineWidth',2);
    plot(bin_pointsA,bin_quantilesA0(:,6,2),'b:*','LineWidth',2);
    plot(bin_pointsA,bin_quantilesA0(:,6,1),'b:','LineWidth',1);
    plot(bin_pointsA,bin_quantilesA0(:,6,3),'b:','LineWidth',1);
    legend('mean','top10%','median');
    title('2000 Income: mean and quartiles');
    axis tight;

    subplot(2,2,3);
    hold on;
    plot(bin_pointsA,bin_meansA5{1}(:,6),'b-o','LineWidth',2);
    plot(bin_pointsA,bin_meansA5{1}(:,11),'r-o','LineWidth',2);
    plot(bin_pointsA,bin_meansA5{1}(:,10),'g-o','LineWidth',2);
    plot(bin_pointsA,bin_quantilesA5{1}(:,6,2),'b:*','LineWidth',2);
    plot(bin_pointsA,bin_quantilesA5{1}(:,11,2),'r:*','LineWidth',2);
    plot(bin_pointsA,bin_quantilesA5{1}(:,10,2),'g:*','LineWidth',2);
    legend('income','wealth','cash');
    title('means (solid) and medians (dotted) by age');
    axis tight;

    subplot(2,2,4);
    hold on;
    plot(bin_pointsA,bin_meansA5{1}(:,6),'b-o','LineWidth',2);
    plot(bin_pointsA,bin_quantilesA5{1}(:,6,2),'b:*','LineWidth',2);
    plot(bin_pointsA,bin_quantilesA5{1}(:,6,1),'b:','LineWidth',1);
    plot(bin_pointsA,bin_quantilesA5{1}(:,6,3),'b:','LineWidth',1);
    legend('mean','median');
    title('2005 Income: mean and quartiles');
    axis tight;

    % comparing housing by age & model choices
    colorscheme='rcmgykbr';
    legs = cell(num_models5+1,1);
    legs{1}='data';
    legs(2:end)=model5names;
    figure; 
    
    subplot(2,2,1);
    hold on;
    plot(bin_pointsA,bin_meansA0(:,16),'b-o','LineWidth',2);
    plot(bin_pointsA,bin_meansA0(:,17),'r-o','LineWidth',2);
    plot(bin_pointsA,bin_topsharesA0(:,16).*bin_meansA0(:,16),'b-.o','LineWidth',2);
    plot(bin_pointsA,bin_topsharesA0(:,17).*bin_meansA0(:,17),'r-.o','LineWidth',2);
    plot(bin_pointsA,bin_quantilesA0(:,16,2),'b:*','LineWidth',2);
    plot(bin_pointsA,bin_quantilesA0(:,17,2),'r:*','LineWidth',2);
    legend('data','model(service)');
    title('2000 house quality (midpoints of gridcells)');
    axis tight;

    subplot(2,2,3);
    hold on;
    plot(bin_pointsA,bin_meansA5{1}(:,16),'b-o','LineWidth',2);
    for i=1:num_models5;
    plot(bin_pointsA,bin_meansA5{i}(:,17),'-o','color',colorscheme(i),'LineWidth',2);
    end;
    plot(bin_pointsA,bin_quantilesA5{1}(:,16,2),'b:*','LineWidth',2);
    for i=1:num_models5;
     plot(bin_pointsA,bin_quantilesA5{i}(:,17,2),':*','color',colorscheme(i),'LineWidth',2);
    end;
    legend('data','model(base)','model(lowdelta)');
    title('2005 house quality (midpoints of gridcells)');
    axis tight;
    
    subplot(2,2,2);
    hold on;
    plot(bin_pointsA,(bin_meansA0(:,14)+bin_meansA0(:,15))./bin_meansA0(:,10),'b-o','LineWidth',2);
    plot(bin_pointsA,bin_meansA0(:,14)./bin_meansA0(:,10),'b:o','LineWidth',2);
    plot(bin_pointsA,bin_meansA0(:,15)./bin_meansA0(:,10),'b-.o','LineWidth',2);
    plot(bin_pointsA,bin_meansA0(:,2)./bin_meansA0(:,10),'k--','LineWidth',2);

    plot(bin_pointsA,zeros(length(bin_pointsA),1),'k-');
    axis tight;
    legend('savings','housing exp','bonds');
    title('use of cash');
    axis tight;

    subplot(2,2,4);
    hold on;
    for i=1:num_models5;
     plot(bin_pointsA,(bin_meansA5{i}(:,14)+bin_meansA5{i}(:,15))./bin_meansA5{i}(:,10),'-o',...
                                                                         'color',colorscheme(i),'LineWidth',2); 
    end;    
    for i=1:num_models5;
     plot(bin_pointsA,bin_meansA5{i}(:,14)./bin_meansA5{i}(:,10),':o', 'color',colorscheme(i),'LineWidth',2);
     plot(bin_pointsA,bin_meansA5{i}(:,15)./bin_meansA5{i}(:,10),'-.o', 'color',colorscheme(i),'LineWidth',2);
    end;
    plot(bin_pointsA,bin_meansA5{i}(:,2)./bin_meansA5{i}(:,10),'k--','LineWidth',2);
    plot(bin_pointsA,zeros(length(bin_pointsA),1),'k-');
    axis tight;
    legend(legs(2:end));%'savings','housing exp','bonds','savings (lowdelta)','housing exp (lowdelta)','bonds (lowdelta)');
    title('savings (solid), housing (dotted), bonds (dashdot)');
    axis tight;
        
    disp('housing / cash ann. by age');
    disp(['upper bounds of age bins are ' num2str(bin_boundsA(2:end))]);
    disp('2000 data');
    disp(bin_meansA0(:,2)'./bin_meansA0(:,23)');
    disp('2000 model');
    disp(bin_meansA0(:,14)'./bin_meansA0(:,23)');
    disp('====================================');
    disp('2005 data');    
    disp(bin_meansA5{1}(:,2)'./bin_meansA5{1}(:,23)');
    disp('2005 model');
    for i=1:num_models5;
     disp(model5names{i});   
     disp(bin_meansA5{i}(:,14)'./bin_meansA5{i}(:,23)');
    end;
    
    
        