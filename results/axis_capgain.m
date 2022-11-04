
% makes capital gain plots
% needs fs definitions and axis initiation

hold on;

if legendflag==1;
   plot(prices00,capgain05data,'g-','LineWidth',2);
   for j=1:length(listnow)
    i=listnow(j);
    prices= (pindexA(6)/pindexA(end))*ppval(pp_array{i},hvals*pindexA(1)/pindexA(6))*10;
    capgain= (log(prices)-log(prices00)) * (100/5);
    plot(prices00 ,capgain, style_seq{i},'LineWidth',2);
    legendnow{j+2}=legend_seq{this_legend(i)};
   end

else
   for j=length(listnow):-1:1;
    i=listnow(j);
    prices= (pindexA(6)/pindexA(end))*ppval(pp_array{i},hvals*pindexA(1)/pindexA(6))*10;
    capgain= (log(prices)-log(prices00)) * (100/5);
    plot(prices00 ,capgain, style_seq{i},'LineWidth',2); 
   end
   plot(prices00,capgain05data,'g-','LineWidth',2);
   legendnow{2}=legend_seq{this_legend(listnow(end))};    
end

plot(prices00,zeros(length(prices00),1),'k-');
%xlabel('House Value in 2000 (thousands of 2008 dollars)','fontsize',16);
xlabel('Quality ( = house value in 2000, $000s)','fontsize',fs_labels);
ylabel('Capital gain 2000-2005, % p.a.','fontsize',fs_labels);
set(gca,'XLim',[0,Hupper_census*10],'YLim',[-5,50],'fontsize',fs_ticks);

legend(legendnow(2:end),'Location','Northeast','fontsize',fs_labels);

if titleflag==1;
 title('Equilibrium capital gains 2000-5','fontsize',fs_title);
end;
axis([35 upperQ -5 25]);
if experlist.(this_exper{i}).supply_survey_index==1;
      ShadePlot([quintiles0(1) quintiles0(2)],'y',.5);
      ShadePlot([quintiles0(3) quintiles0(4)],'y',.5);
else
      ShadePlot([quintiles5(1) quintiles5(2)],'y',.5);
      ShadePlot([quintiles5(3) quintiles5(4)],'y',.5);
end
