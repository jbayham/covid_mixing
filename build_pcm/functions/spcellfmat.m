function [outmat] = spcellfmat(inmat,midx,data)
%CELLFMAT accepts the cell matrix that contains all of the information to
%calculate the family contact matrix and calculates the contact matrix for
%each family.

%Family contacts are calculated one case id at a time.  Within each
%activity all combinations of individuals present are assigned contacts for
%the duration of the activity.  Each family contact matrix is weighted by
%the respondent's household survey weight.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Definitions:
fwgt=data(1,5);
[~,aid,acts]=unique(data(:,2)); %list of activities done by family
dur=num2cell((data(aid,3)-data(aid,4))); %stop minus start
pmat=accumarray(acts,midx,[],@(x) {combinator(length(x),2,'p')}); %cell matrix where each element contains the probability combinations of individuals present by activity
cellmidx=accumarray(acts,midx,[],@(x) {x});
npeep=accumarray(acts,1,[],@(x) {sum(x)});
fmat=cellfun(@(x,y,z,n) accumarray([y(x(:,1)) y(x(:,2))],z,size(inmat{2}),[],[],true)/(n-1)*fwgt,pmat,cellmidx,dur,npeep,'UniformOutput',false);
outmat=spcellsum(fmat,1);
end
