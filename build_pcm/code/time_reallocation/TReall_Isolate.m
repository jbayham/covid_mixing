% 6) anyone at school and parents of school aged kids isolate.  
run TReall_Preamble

%%
%Predefining donor and toreplace matrix to guide time reallocation and
%creation of new contact matrix
atschool=(contact.where==8 & contact.actdur>0); %people at school
atwork=(contact.co_sibs==1 & contact.act1==5 & contact.act2==1 & contact.where~=1 & contact.actdur>0 & contact.weekend==0 & contact.holiday==0); %people at school
%people might also limit their discretionary time in public (restaurants,
%other store, other place, personal service, gym)
discretion=(~(contact.act1==5 & contact.act2==1) & ismember(contact.where,locs([4 5 7 10 11 12:20 22 24 25]))); 
contact(atschool | atwork | discretion,:)=[];

%{
%check
sum(contact.where==8 & contact.person==1);
actnummax=grpstats(contact(:,{'tucaseid','actnum'}),{'tucaseid'},'max');
%}
%%
%Saving new mixing dataset
save(sprintf('%s%s',tupath,'MixingDataset_HH_isolate.mat'),'contact','cut','labels','loclabels','-v7.3')


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Time_Comp==1
%Checking time distribution after modification
figure(1)
check1=time_dist(ocontact(ocontact.person==1,:),locs);
[check2,total]=time_dist(contact(contact.person==1,:),locs);
idx=[2:12 21 23 24];
bar([check1(idx) check2(idx)]*100,1)
xlim([0.5 size(check1(idx),1)+1])
ylim([0 13])
tick_loc=(1:size(check1(idx),1));
set(gca,'XTick',[],'FontSize',7,'Position',[.1 .3 .88 .63])
set(gcf,'Position',[100 400 880 350]);
text(tick_loc,ones(length(tick_loc),1)-1.5,loclabels(idx),'Rotation',-50,'FontSize',7)
box('off')
legend({'Original','Post-Reallocation'})

[check1(1) check2(1)]
end