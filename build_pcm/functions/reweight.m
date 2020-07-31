function newdata=reweight(data,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Update 1-7-14: I no longer think that I need individual weights for
% family contacts.  Instead, I can go through the steps to calculate the
% family exposure, then contact matrix (based on the individual family
% population) for each family.  The family weights can then be used to
% calculate a weighted average family contact matrix that should be
% representative of the US population.


% This program accepts the merged ATUS-NHAPS dataset and creates two sets
% of weights.  Individual respondent weights from the ATUS and NHAPS are
% first modified so the two datasets can be used together to calculate the
% public exposure matrix.  Family weights (on which respondent weights are
% built) are modified to calculate the family exposure matrix.  The family
% and public exposure matrices are representative of the US population and
% are summed to create the WAIFW matrix by dividing the summed exposure
% matrix by the population in each segment bin.
% 
% Since the NHAPS data is from 1992-1994, the weights need to be rescaled
% to 2008 population levels (the midpoint in the ATUS years).  The ATUS
% data is from 2003 to 2012 and each year needs to be rescaled to make them
% all comparable.
% 
% Respondent weights are adjusted to accommodate the NHAPS data.
% Specifically, NHAPS respondents <15 are over weighted because this
% population is not surveyed in the ATUS.  This may contribute to larger
% variance in those populations.
% 
% The more primitive household weights are used to construct the family
% exposure matrix.  These weights are common to all members of the
% household and are appropriate for household-level characteristics like
% family income and # of children or adults in household.  Using these
% household weights as a base, we can adjust these weights to account for
% the composition of the household such that the individual level
% population is representative of the US population and the household-level
% characteristic distributions maintain.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Limit dataset to primary respondents only.
datar=data(data.person==1,:);
[~,ri]=unique(datar.tucaseid);
datar=datar(ri,:);

wgt=datar.wgt;
mark=datar.x_mark;
age=datar.age;
year=datar.year;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%recalculating the weights for the NHAPS data mark==1
N90=248709873;  %1990 US Census Pop
N08=304059728;  %2008 US Census Pop (ACS)
adj=N08/N90;    %Adjustment factor for rescaling the NHAPS population
%Converting the NHAPS sampling weights into population figures and 
%rescaling the population to 2008 levels
wgt(mark==1)=(wgt(mark==1)*N90*adj)/sum(mark==1); 
%assigning wgts to kids treated as primary respondents. nwgts come from
%KidsToPrimary.m
if sum(mark==2)>0
    nwgt=[836.694764985045;746.357923585912;728.097214367517;702.145958232932;695.627361803713;672.630871392659;663.841946675487;640.329995149967;657.857467562694;628.891947602632;668.047221453954;658.578165440352;674.146120117374;678.571102855263;689.661824683118];
    for ii=1:15
        wgt(age==ii-1 & mark==2)=nwgt(ii);
    end
end
%Converting person days in quarter into person days so treating each day
%the same representative day - and converting to persons in year to be
%comparable with NHAPS
wgt(mark==0)=wgt(mark==0)/91.25/4; 
%Rescaling the ATUS population weights to coincide with the 2008 population
yrlist=(2003:2012)';
for ii=1:length(yrlist)
    yrpop(ii)=sum(wgt(mark==0 & year==yrlist(ii)));
    wgt(mark==0 & year==yrlist(ii))=wgt(mark==0 & year==yrlist(ii))*(N08/yrpop(ii));
end
%Downweighting the data where the ATUS and NHAPS overlap
wgt(age>=15)=wgt(age>=15)/11;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Reweighting the data to approximate the age distribution in 2008
%2008 age distribution from Census 
age08=[0.069 0.066 0.068 0.072 0.069 0.069 0.065 0.07 0.073 0.076 0.07 0.06...
    0.048 0.036 0.029 0.061];
%Converting the age variable into categories matching the Census
%distribution
agerng=convertcon(datar.age,[(0:5:75) 95]');
for ii=1:numel(age08)
    pop(ii)=sum(wgt(agerng==ii));
end
%Obtaining population distribution based on existing weights
pdata=pop'/sum(pop);
for ii=1:numel(pop)
    wgt(agerng==ii)=wgt(agerng==ii)*(age08(ii)/pdata(ii));
end
%Rescaling again to match the 2008 census population
wgt=wgt*(N08/sum(pop));
%Checking
for ii=1:numel(unique(agerng))
    popcheck(ii)=sum(wgt(agerng==ii));
end
pwgtsum=sum(popcheck);
if nargin>1
    bar(popcheck)
    pwgtsum
end
%Remerging the new weights with the orginial dataset
datar.wgt=wgt;
datar=datar(:,{'tucaseid','wgt'});
data.wgt=[];
newdata=join(data,datar,'Keys',{'tucaseid'});

clear age agerng mark ri wgt year pop pdata;


%Excluding this section because there is no need to adjust family weights
%to individuals.  Instead of calculating family exposure matrices to be
%combined with public exposure matrices, we weight each family contact
%matrix by the family weight to calculate an average family contact matrix
%in minutes.  One minute is split between all people in room.





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Reweighting the household weights such that the ATUS data including the
%family members also represents the US population distribution and absolute
%number.  This enables us to sum the public and family exposure matrix and
%use the respondent weights to create the WAIFW matrix.
%Limit dataset to ATUS only.
%{
newdata_f=newdata_p(newdata_p.x_mark==0,:);
[~,ri]=unique([newdata_f.tucaseid newdata_f.person],'rows');
datar=newdata_f(ri,:);

fwgt=datar.fwgt;
year=datar.year;

%Normalizing weights to 2008
yrlist=(2003:2012)';
for ii=1:length(yrlist)
    yrpop(ii)=sum(fwgt(year==yrlist(ii)));
    fwgt(year==yrlist(ii))=fwgt(year==yrlist(ii))*(N08/yrpop(ii));
end
fwgt=fwgt/10;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Deconstructing individual weights
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Age
age08=[0.069 0.066 0.068 0.072 0.069 0.069 0.065 0.07 0.073 0.076 0.07 0.06...
    0.048 0.036 0.029 0.061];
%Converting the age variable into categories matching the Census
%distribution
agerng=convertcon(datar.age,[(0:5:75) 95]');
for ii=1:numel(age08)
    agepop(ii)=sum(fwgt(agerng==ii));
end
%Obtaining population distribution based on existing weights
pdata=agepop'/sum(agepop);
for ii=1:numel(agepop)
    fwgt(agerng==ii)=fwgt(agerng==ii)*(age08(ii)/pdata(ii));
end
fwgt=fwgt*(N08/sum(agepop));

%Remerging the new weights with the orginial dataset
datar.fwgt=fwgt;
datar=datar(:,{'tucaseid','person','fwgt'});
newdata_f.fwgt=[];
newdata_f2=join(newdata_f,datar,{'tucaseid','person'});
newdata=newdata_p;
newdata.fwgt(newdata.x_mark==0)=newdata_f2.fwgt;
%}



%Number of Children
%In order to adjust weights according to multiple objectives, we need to
%optimize over the weights to minimize the distance between the data
%distribution and the desired distribution.


% noc08=[0.484 0.175 0.190 0.149];
% var=datar.childnum;
% idx=unique(var);
% for ii=1:numel(noc08)
%     nocpop(ii)=sum(fwgt(var==idx(ii)));
% end
% nocdata=nocpop'/sum(nocpop);
% for ii=1:numel(nocpop)
%     fwgt(var==idx(ii))=fwgt(var==idx(ii))*(noc08(ii)/nocdata(ii));
% end


%For checking distributions
%{
newage=convertcon(datar.age,[0 15 (20:10:70) 95]');
newdat=[year newage datar.age double(datar(:,{'sex','hhinc','childnum','educ'})) (datar.childnum+datar.adults)];
tab=cell(size(newdat,2),1);
for jj=1:size(newdat,2)
    var=newdat(:,jj);
    idx=unique(var);
    data=zeros(size(idx));
    for ii=1:size(idx,1)
        data(ii)=sum(fwgt(var==idx(ii)));
    end
    tab{jj}=[data data./sum(data)];
end

%}


