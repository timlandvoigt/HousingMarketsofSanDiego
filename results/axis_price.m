
% makes price plots
% needs fs definitions and axis init

hold on;
plot(prices00,prices00,'k:','LineWidth',2);  % plot 45 deg line
prices05data=(pindexA(6)/pindexA(end))*ppval(price05spline,(pindexA(end)/pindexA(6))*hvals*normfact)/1000;
capgain05data = (log(prices05data)-log(prices00)) * (100/5);
plot(prices00,prices05data,'g-','LineWidth',2);  % plot data

for j=1:length(listnow);
    i=listnow(j);
    prices= (pindexA(6)/pindexA(end))*ppval(pp_array{i},hvals*pindexA(1)/pindexA(6))*10;
    plot(prices00 ,prices, style_seq{i},'LineWidth',2);
    legendnow{j+2}=legend_seq{this_legend(i)};
end

set(gca,'XLim',[0,1200],'YLim',[0,2000],'fontsize',fs_ticks);
%xlabel('House Value in 2000 (thousands of 2008 dollars)','fontsize',16);
xlabel('Quality (= house value in 2000, $000s)','fontsize',fs_labels);
%ylabel('Value in 2005 (thousands of 2008 dollars)','fontsize',16);
ylabel('House value in 2005, $000s','fontsize',fs_labels);
axis([0 upperQ 0 1.5e3]);
legend(legendnow,'Location','Northwest','fontsize',fs_labels);
if experlist.(this_exper{i}).supply_survey_index==1;
      ShadePlot([quintiles0(1) quintiles0(2)],'y',.5);
      ShadePlot([quintiles0(3) quintiles0(4)],'y',.5);
else
      ShadePlot([quintiles5(1) quintiles5(2)],'y',.5);
      ShadePlot([quintiles5(3) quintiles5(4)],'y',.5);
end
if titleflag==1;
title('Equilibrium house prices in 2005','fontsize',fs_title);
end;