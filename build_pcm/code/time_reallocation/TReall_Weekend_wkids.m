% 4) The script assumes children in school and working parents adopt the 
% weekend contact patterns of adults with their kids.  Since we don't observe 
% people over multiple
% days, we create pools of (schedule) donors based on similar demographics to
% match people and reallocate time.
run TReall_Preamble

%%
%Predefining donor and toreplace matrix to guide time reallocation and
%creation of new contact matrix
atschool=(icontact.where==8 & icontact.actdur>0); %people at school
atwork=(icontact.co_sibs==1 & icontact.act1==5 & icontact.act2==1 & icontact.where~=1 & icontact.actdur>0 & icontact.weekend==0 & icontact.holiday==0); %people at school
ididx=unique(icontact.tucaseid(atschool | atwork));
matchvars={'agerng','hhinc','hhsize','educ','empo','metro','month'};
toreplace=icontact(atschool | atwork,[{'start','stop','actdur','tucaseid','actnum','where'} matchvars]); %id for teens who did report going to school set of target activities that will be modified 

%Find only activities that adult primary respondents do with kids.  Using
%unstack to convert from long to wide format and subset by age of activity
%participants

age_mat=unstack(dataset2table(kdat(:,{'tucaseid','person','actnum','age',})),'age','person');
act_wkids_index=age_mat(sum(table2array(age_mat(:,3:end))<13,2)>0 & ...
    sum(ismember(table2array(age_mat(:,3:end)),(18:60)),2)>0,{'tucaseid','actnum'});
donor=icontact(icontact.weekend==1 & icontact.where~=8 & icontact.x_mark==0 & ismember(icontact(:,{'tucaseid','actnum'}),table2dataset(act_wkids_index)),[{'start','stop','actdur','tucaseid','actnum','where'} matchvars]);

%calling weekend version of TimeFun which accepts a donor dataset with all
%weekend records and an additional cell vector of variable names to match
%on (toreplace and donor need to include the matchvars).
newact=TimeFun_weekend(toreplace,donor,matchvars);
%%
%Joining new activities to icontact dataset to create new actnum index
[newcontact,midx]=join(newact,icontact,'Keys',{'tucaseid','actnum'}); %Returns the merge index for locations in icontact dataset
newcontact.owhere=newcontact.where;
newcontact(:,{'start','stop','actdur','where'})=newcontact(:,{'nstart','nstop','nactdur','nwhere'}); %replacing old variable names with new values
newcontact(:,{'nstart','nstop','nactdur','nwhere'})=[]; %dropping new variable names
icontact(unique(midx),:)=[]; %removing the single activity in icontact that was replaced
icontact.owhere=icontact.where;
newcontact=[newcontact;icontact(ismember(icontact.tucaseid,unique(toreplace.tucaseid)),:)]; %then appending the icontact dataset (with replaced activities removed)
newcontact=sortrows(newcontact,{'tucaseid','start'}); %resort rows after append so activities are bunched within id
newcontact.oactnum=newcontact.actnum; %retaining original actnum for potential merge with original contact dataset below 
%relabeling actnum - note this relies on newcontact containing the full
%list of activities of only the individuals to replace
nlist=grpstats(newcontact(ismember(newcontact.tucaseid,unique(toreplace.tucaseid)),{'tucaseid','actnum'}),'tucaseid'); %calculating the number of elements in each group
temp1=num2cell(nlist.GroupCount); %converting the vector of element numbers to a cell vector
temp2=cellfun(@(x) (1:x)',temp1,'UniformOutput',0); %a function that operates on each element of the cell vector to generate a sequential list for each element
newcontact.actnum=cell2mat(temp2); %converting cell vector back into numerical vector and appending to newcontact
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Merging newcontact dataset back with original that includes family members.  
%If previous activity at school was done with a family member, new time spent
%at home includes that family member. All other activities are left as is
%but they need to be renumbered

%renumbering activities for family members present during time that was reallocated from school to home
fambridge=newcontact(ismember(double(newcontact(:,{'tucaseid','oactnum'})),unique(double(toreplace(:,{'tucaseid','actnum'})),'rows'),'rows') & newcontact.where==1,{'tucaseid','actnum','oactnum'}); %creating bridge between new actnum and old records of family members at school with respondent
fam2home=contact(ismember(double(contact(:,{'tucaseid','actnum'})),double(fambridge(:,{'tucaseid','oactnum'})),'rows') & contact.person~=1,:); %the subset of the original dataset excluding primary respondents for activities modified
fam2home.where=ones(size(fam2home.where)); %reallocating everyones activity to home
temp=join(fam2home,fambridge,'LeftKeys',{'tucaseid','actnum'},'RightKeys',{'tucaseid','oactnum'}); %using the bridge to assign new actnum values to other family members
fam2home.actnum=temp.actnum_right;

%renumbering activities for family members present for activities that had no reallocation

othbridge=newcontact(~ismember(double(newcontact(:,{'tucaseid','oactnum'})),unique(double(toreplace(:,{'tucaseid','actnum'})),'rows'),'rows'),{'tucaseid','actnum','oactnum'});
othacts=contact(ismember(double(contact(:,{'tucaseid','actnum'})),double(othbridge(:,{'tucaseid','oactnum'})),'rows') & contact.person~=1,:);
temp=join(othacts,othbridge,'LeftKeys',{'tucaseid','actnum'},'RightKeys',{'tucaseid','oactnum'});
othacts.actnum=temp.actnum_right;

%merging the new activity data with the original unchanged records and
%renumbered activities
tempcontact=contact(~ismember(contact.tucaseid,unique(toreplace.tucaseid)),:); %subseting original dataset for unmodified records
fullcontact=[newcontact(:,~ismember(get(newcontact,'VarNames'),{'oactnum','owhere'}));tempcontact;othacts;fam2home]; %merging different subsets
fullcontact=sortrows(fullcontact,{'tucaseid','actnum','person'}); %resorting data
contact=fullcontact;
%%
%Saving new mixing dataset
save(sprintf('%s%s',tupath,'MixingDataset_HH_weekend_wkids.mat'),'contact','cut','labels','loclabels','-v7.3')


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