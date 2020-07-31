% 5) anyone at school and parents of school aged kids reallocate their 
% time to their household

run TReall_Preamble
%%
%Predefining donor and toreplace matrix to guide time reallocation and
%creation of new contact matrix
atwork=(contact.co_sibs==1 & contact.act1==5 & contact.act2==1 & contact.where~=1 & contact.actdur>0 & contact.weekend==0 & contact.holiday==0); %people at school

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Reallocating ATUS children to home when parents stay home
respondent=contact(atwork & contact.person==1,:);
res_full=contact(ismember(contact.tucaseid,respondent.tucaseid),:);
kids=res_full(ismember(res_full.age,(5:12)),:);
[childset,cidx]=unique(double(kids(:,{'tucaseid','person'})),'rows');
childdat=kids(cidx,:);
ovarlist={'tucaseid','actnum','where','start','stop','act','act1','act2','act3'};
childdat(:,ovarlist)=[];
newact=cell(size(childset,1),2);
for ii=1:size(newact,1)
    newact{ii,1}=double(respondent(ismember(respondent.tucaseid,childset(ii,1)),ovarlist));
    newact{ii,2}=repmat(double(childdat(ii,:)),size(newact{ii,1},1),1); %maybe repmat
end
temp=mat2dataset(cell2mat(newact),'VarNames',[ovarlist get(childdat,'VarNames')]);
contact=sortrows([contact;temp],{'tucaseid','actnum','person'});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Recalculating the index of working people that now includes kids
atwork2=(contact.co_sibs==1 & contact.act1==5 & contact.act2==1 & contact.where~=1 & contact.actdur>0 & contact.weekend==0 & contact.holiday==0);
atschool=(contact.where==8 & contact.actdur>0); %people at school
%people might also limit their discretionary time in public (restaurants,
%other store, other place, personal service, gym)
discretion=(contact.act1~=5 & ismember(contact.where,locs([4 7 11 22 25]))); 
contact.where(atschool | atwork2 | discretion)=1;

%%
%Saving new mixing dataset
save(sprintf('%s%s',tupath,'MixingDataset_HH_home.mat'),'contact','cut','labels','loclabels','-v7.3')


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