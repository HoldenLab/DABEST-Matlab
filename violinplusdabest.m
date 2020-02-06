function [stats, h, bootDiff_data, bootDiff_name, bootDiff_order]= violinplusdabest(data, cats, grouporder)
%violin plot plus median difference

nBoot= 1000;

[stats, bootDiff_data, bootDiff_name, bootDiff_order stats_delta delta_name_plot]=statmeddiff(cats, data,nBoot,grouporder);
keyboard
trueMedianDiff = [0;stats_delta.Value];
%TODO make colors the same - cant figure this out right now
h.fig=figure;
%set(h.fig.Color,[1 1 1]);
h.ax1=subplot(3,1,1:2);
h.v1=violinplot(data,cats,'GroupOrder',grouporder);
ylim(h.ax1,[min([ylim,0]), max(ylim)]);
set(h.ax1,'TickDir','out');

h.ax2=subplot(3,1,3);
h.v2=dabestviolinplot(bootDiff_data, bootDiff_name,trueMedianDiff,'ShowData',false,...
        'GroupOrder',grouporder,'DabestViolinColor', [0.5 0.5 0.5]);
ylim(h.ax2,[min([ylim,0]), max(ylim)]);

ylabel('Median difference');
set(h.ax2,'XAxisLocation','bottom');
set(h.ax2,'TickDir','out');

linkaxes([h.ax1,h.ax2],'x');
plot([xlim],[0 0],'k'); % add a line to identify zero difference
