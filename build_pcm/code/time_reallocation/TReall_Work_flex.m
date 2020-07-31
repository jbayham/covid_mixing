% 2b) The script is similar to 2a but also reallocates working
% parents with flexibility from work to other activities
run TReall_Preamble
%%
for ii=1:length(locs)
    workdist(ii)=sum(icontact.actdur(icontact.co_sibs==1 & icontact.inflex==1 & icontact.act1==5 & icontact.act2==1 & icontact.weekend==0 & icontact.holiday==0 & icontact.where==locs(ii)));
end
reall_frac=workdist'/sum(workdist); %The fraction of work locations for people with children
reall_frac(1)=sum(reall_frac([1 8])); %moving parents who work at school to home
reall_frac(8)=0;

%subset children<13 to reallocate (school=where=8)
kids=contact(contact.age<13 & contact.where==8 & contact.x_mark==1,:);
chglist=unique(kids.tucaseid); %list of ids to change

%randomly sampling proportion whose parents have workplace flex and the
%chosen ids will be assigned reallocation to either home or other
%activities below
rng(1000);
kdat=kdat(ismember(kdat.age,(5:12)'),:);
[~,uidx]=unique(kdat(:,{'tucaseid','person'}));
prop=sum(kdat.co_sibs(uidx)==0)/length(uidx); %fraction of kids who have childcare and don't need to go to work with parents or necessarily be supervised by a parent working at home
prop_home=sum(kdat.co_sibs(uidx)==1 & kdat.inflex(uidx)==0)/sum(kdat.co_sibs(uidx)); %fraction of those who would need to go to parents work but parents work from home instead so they reallocate to home
[toreall,rmidx]=datasample(chglist,round(prop*numel(chglist)),'Replace',false);
chglist(rmidx)=[];
[toreall_home,rmidx]=datasample(chglist,round(prop_home*numel(chglist)),'Replace',false);
chglist(rmidx)=[];
chglocdist=round(reall_frac*numel(chglist));
if sum(chglocdist)> numel(chglist) %if under/overallocated, change largest category
    chglocdist(chglocdist==max(chglocdist))=max(chglocdist)-(sum(chglocdist)-numel(chglist));
elseif sum(chglocdist)< numel(chglist)
    chglocdist(chglocdist==max(chglocdist))=max(chglocdist)+(sum(chglocdist)-numel(chglist));
end
tempchglist=chglist;
chgcells=cell(numel(chglocdist),1); %shell for storing lists of samples
for ii=1:numel(chglocdist) %making this random for any time we aren't using the whole dataset
    rng(ii);
    [chgcells{ii},rmidx]=datasample(tempchglist,chglocdist(ii),'Replace',false); %sample without replacement from the list of tucaseids of children who meet the change criteria
    tempchglist(rmidx)=[]; %removing those selected from the pool (if correct, temp change list should be empty by the end)
end
rng('default');    
%Using the lists in chgcells to replace the locations of kids from school
%to workplace of parents
for ii=1:numel(chgcells)
    contact.where(ismember(contact.tucaseid,chgcells{ii}) & contact.where==8)=locs(ii);
end

%People with flexibility need to stay home to work and watch kids
atwork=(contact.co_sibs==1 & contact.inflex==0 & contact.act1==5 & contact.act2==1 & contact.weekend==0 & contact.holiday==0 & contact.where~=1);
kids_reall_home=(ismember(contact.tucaseid,toreall_home) & contact.where==8);
contact(kids_reall_home,:);
contact.where(kids_reall_home | atwork)=1; %sending them home

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Predefining donor and toreplace matrix to guide time reallocation and
%creation of new contact matrix.  School -> where==8
atschool=(icontact.age>12 & icontact.actdur>0 & icontact.where==8); %icontact.age<18 &
kids_reall=(ismember(icontact.tucaseid,toreall) & icontact.where==8);
toreplace=icontact(atschool | kids_reall,{'start','stop','actdur','tucaseid','actnum','where'}); %id for teens who did report going to school set of target activities that will be modified 
donor=icontact(~(atschool | kids_reall) & ismember(icontact.tucaseid,unique(toreplace.tucaseid)),{'tucaseid','actnum','where','actdur'}); %nonschool activities  creating the donor subset. limiting donor subset to only those who spent time at school during their diary day


%Calling TimeFun to generate new contact dataset for activities in toreplace
newact=TimeFun(toreplace,donor);
%Joining new activities to icontact dataset to create new actnum index
[newcontact,midx]=join(newact,icontact,'Keys',{'tucaseid','actnum'}); %Returns the merge index for locations in icontact dataset
newcontact.owhere=newcontact.where;
newcontact(:,{'start','stop','actdur','where'})=newcontact(:,{'nstart','nstop','nactdur','nwhere'}); %replacing old variable names with new values
newcontact(:,{'nstart','nstop','nactdur','nwhere'})=[]; %dropping new variable names
icontact(unique(midx),:)=[]; %removing the single activity in icontact that was replaced
icontact.owhere=icontact.where;
newcontact=[newcontact;icontact(ismember(icontact.tucaseid,unique(donor.tucaseid)),:)]; %then appending the icontact dataset (with replaced activities removed)
newcontact=sortrows(newcontact,{'tucaseid','start'}); %resort rows after append so activities are bunched within id
newcontact.oactnum=newcontact.actnum; %retaining original actnum for potential merge with original contact dataset below 
%relabeling actnum - note this relies on newcontact containing the full
%list of activities of only the individuals to replace
nlist=grpstats(newcontact(ismember(newcontact.tucaseid,unique(donor.tucaseid)),{'tucaseid','actnum'}),'tucaseid'); %calculating the number of elements in each group
temp1=num2cell(nlist.GroupCount); %converting the vector of element numbers to a cell vector
temp2=cellfun(@(x) (1:x)',temp1,'UniformOutput',0); %a function that operates on each element of the cell vector to generate a sequential list for each element
newcontact.actnum=cell2mat(temp2); %converting cell vector back into numerical vector and appending to newcontact
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Merging newcontact dataset back with original that includes family members.  
%If previous activity at school was done with a family member, new time spent
%at home includes that family member. All other activities are left as is
%but they need to be renumbered
%%
%renumbering activities for family members present during time that was reallocated from school to home
fambridge=newcontact(ismember(double(newcontact(:,{'tucaseid','oactnum'})),unique(double(toreplace(:,{'tucaseid','actnum'})),'rows'),'rows') & newcontact.where==1,{'tucaseid','actnum','oactnum'}); %creating bridge between new actnum and old records of family members at school with respondent
fam2home=contact(ismember(double(contact(:,{'tucaseid','actnum'})),double(fambridge(:,{'tucaseid','oactnum'})),'rows') & contact.person~=1,:); %the subset of the original dataset excluding primary respondents for activities modified
fam2home.where=ones(size(fam2home.where)); %reallocating everyones activity to home
temp=join(fam2home,fambridge,'LeftKeys',{'tucaseid','actnum'},'RightKeys',{'tucaseid','oactnum'}); %using the bridge to assign new actnum values to other family members
fam2home.actnum=temp.actnum_right;

%renumbering activities for family members present for activities that had no reallocation
othbridge=newcontact(ismember(double(newcontact(:,{'tucaseid','oactnum'})),unique(double(donor(:,{'tucaseid','actnum'})),'rows'),'rows'),{'tucaseid','actnum','oactnum'});
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
save(sprintf('%s%s',tupath,'MixingDataset_HH_work_flex.mat'),'contact','cut','labels','loclabels','-v7.3')

%%
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

