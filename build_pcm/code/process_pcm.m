
%Outputing or prepping for plotting
%By location
location_pcms=cellfun(@full,spcellsum(exposure(1:12,:),2),'UniformOutput',false);
%loclabels(loc)

for ii=1:length(location_pcms)
    csvwrite(sprintf('build_pcm/outputs/pcm_csv/%s.csv',locations{ii}),location_pcms{ii})
end

%Collapsed into matrix
public=cell2mat(full(spcellsum(location_pcms,1)));
csvwrite('build_pcm/outputs/pcm_csv/All Public.csv',public)


%Exporting household matrix
csvwrite('build_pcm/outputs/pcm_csv/Household.csv',fammat)

%Exporting public + household matrix
csvwrite('build_pcm/outputs/pcm_csv/Public and Household.csv',fammat+public)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%By time
% time_pcms=spcellsum(exposure,1);
% 
% for ii=1:length(time_pcms)
%     csvwrite(sprintf('build_pcm/outputs/time_pcm_csv/time_%s.csv',num2str(ii,'%03.f')),full(time_pcms{ii}))
% end
% 
% 
% 
% 
% writetable(dataset2table(contact),'build_pcm/outputs/contact_dataset.csv')