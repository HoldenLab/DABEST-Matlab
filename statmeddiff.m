function [stats, bootDiff_data, bootDiff_name, bootDiff_order stats_delta delta_name_plot]=statmeddiff(identifiers, data,nBoot,grouporder)

%SIMPLE MANUAL HACK TO CHANGE ESM SH 200128
%esm='md';
esm='median';

%% Repack into nan-padded columns if they are in vector form
if size(identifiers)==size(data)
    [celld, uidents] = repackData (identifiers, data);
else
    uidents = identifiers;
    celld = data;
end

%reorder the matrix as grouporder
for ii = 1:numel(grouporder)
    %uidentsTMP{ii} = uidents{strcmp(uidents,grouporder{ii})};
    celldTMP{ii} = celld{strcmp(uidents,grouporder{ii})};
end
celld=celldTMP;
uidents=reshape(grouporder,size(uidents));


%median and CIs
nex=length(celld);
for idx=1:nex
       
    curDat=celld{idx};
    [av(idx), moes, bci] = bootmoes_med(curDat);
    
    er(:, idx) = moes; 
    CI(idx, :) = bci;  
    Value(idx, :) = av(idx);
    N(idx, :) = length(curDat);
end
stats = table(uidents, Value, CI, N, 'VariableNames',{'Group','Value','CIs','N'});



% Get the median difference and median difference CIs
clear moes;

avr = zeros(2, length(celld));
moes = zeros(2, length(celld));
ci = zeros(2, length(celld));
N = NaN(length(celld)-1,1);

bootDiff_data=[0];
bootDiff_name={uidents{1}};
delta_name_plot={{' '}};
for idx = 2:length(celld)
    %[ss ]=mes(celld{idx},celld{1},esm,'nBoot',nBoot);
    [ss bootDiff]=mes(celld{idx},celld{1},esm,'nBoot',nBoot);
    avr(:,idx)=repmat(ss.median,2, 1);
    moes(:,idx)=abs(avr(:,idx)-ss.medianCi);
    ci(:,idx) = ss.medianCi;
    delta_name_table(idx-1,:) = {[uidents{idx}, ' minus ', uidents{1}]}; 
    delta_name_plot(idx-1,:) = {{uidents{idx}}, {'minus'}, {uidents{1}}}; 
    delta_name(idx-1,:) = {[uidents{idx}]};%disable plotting of proper minus names for now
    bootDiff_data=[bootDiff_data,bootDiff];
    bootDiff_name = [bootDiff_name,repmat(delta_name(idx-1),1,nBoot)];
end
stats_delta = table(delta_name_table, avr(1,2:end)', ci(:,2:end)', N, 'VariableNames', {'Group','Value','CIs','N'});
stats = [stats; stats_delta];

bootDiff_order=delta_name;    
