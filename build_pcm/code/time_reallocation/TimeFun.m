function [newact] = TimeFun(toreplace,donor)
%This function reallocates individuals time from some set of activities to
%another.  The argument toreplace is the subset of records that correspond
%to the activity being reallocated.  The argument donor is the subset of
%all other activities by the same individuals.  The key to this function is
%that the activities in donor are those used to proportionately reallocate
%those from to replace

%Calculating the time the target group spends on other activities on their
%diary day
ididx=[unique(donor.tucaseid) (1:length(unique(donor.tucaseid)))']; %Creating newid to use as index in accumarray
newid=mat2dataset(ididx,'VarNames',{'tucaseid','ididx'}); %new dataset based on the unique id values later used to merge the newid back into the donor dataset
donor=join(donor,newid);
newid.timetotal=accumarray(donor.ididx,donor.actdur); %calculating totals for each id
donor=join(donor,newid);
wheretime=accumarray(double(donor(:,{'ididx','where'})),donor.actdur);  %creates a matrix of size unique(tucaseid) by where codes. note the column indices are based on the where codes which skip numbers... I am keeping them so the where codes can be used as reference later.
proptime=bsxfun(@rdivide,wheretime,newid.timetotal);

%commented out because it causes problems merging later on.
%Consolidating activities by location since we don't actually care about
%the activity codes here.
% toreplace=sortrows(toreplace,{'tucaseid','start'});
% n=1;
% while n<size(toreplace,1)
%     if toreplace.actnum(n)+1==toreplace.actnum(n+1) && toreplace.tucaseid(n)==toreplace.tucaseid(n+1)
%         toreplace.stop(n)=toreplace.stop(n+1);
%         toreplace(n+1,:)=[];
%     else
%         n=n+1;
%     end
% end
% toreplace.actdur=toreplace.stop-toreplace.start;

%Reallocating the time individuals spent at school
newid=[newid mat2dataset(proptime)]; %appending the matrix of time proportions to new id for merge back with toreplace for matrix multiplication conformity
toreplace=toreplace(ismember(toreplace.tucaseid,newid.tucaseid),:); %There are two ids that are strange.  We drop them so the datasets can be merged
toreplace=join(toreplace,newid); 
prop1idx=find(ismember(get(toreplace, 'VarNames'),'proptime1')); %finding the column number where proptime1 starts
toreplace(:,prop1idx:end)=mat2dataset(floor(bsxfun(@times,toreplace.actdur,double(toreplace(:,prop1idx:end)))));  %rounding time spent at all activities down
toreplace(:,prop1idx)=mat2dataset(toreplace.actdur-sum(double(toreplace(:,prop1idx+1:end)),2)); %sending residual time home
locidx=(1:31)'; %generating index for locations 
newtime=sparse(double(toreplace(:,prop1idx:end))); %converting the time reallocation matrix to sparse for speed
startstop=[toreplace.start toreplace.stop]; %putting start and stop in matrix for speed
newact=cell(size(toreplace,1),1); %creating shell to populate
for ii=1:size(newact,1) %looping through each person activity
    temp=locidx(newtime(ii,:)>0);  %subsetting the locations where people spent positive time
    temp(:,5)=toreplace.tucaseid(ii); %storing case id for later merge back with rest of dataset
    temp(:,6)=toreplace.actnum(ii); %storing activity number for same reason
    temp(1,2)=startstop(ii,1);     %assigning the activity to replace as the new activity start time
    temp(end,3)=startstop(ii,2);   %assigning the activity to replace stop time as the new ending time
    temp(:,4)=newtime(ii,temp(:,1)'); %applying the duration of each activity
    rp=randperm(size(temp,1));      %randomizing the order of the activities since we have no priors.  Without this, you would have everyone at home early on.
    temp(:,[1 4])=temp(rp,[1 4]);
    temp(1,3)=temp(1,2)+temp(1,4);
    jj=2;
    while jj<size(temp,1)
        temp(jj,3)=temp(jj-1,3)+temp(jj,4);
        jj=jj+1;
    end
    temp(2:end,2)=temp(1:end-1,3);
    newact{ii}=temp(:,[5 6 1:4]);
end
newact=mat2dataset(cell2mat(newact),'VarNames',{'tucaseid','actnum','nwhere','nstart','nstop','nactdur'});
end


