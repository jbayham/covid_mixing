function [exposure,catpop,rloc,pcount] = public_PCM(contact,cut,loclabels,labels,varlist,start,stop,filtervar,filtervals)
%ContactMatrix generates public and/or household probabilistic contact
%matrices (PCM) from time-use data described in the data appendix of "Beyond Age".  
%The PCM provides an estimate of the average daily duration an individual in column (type) i 
%is exposed to population (type) j. Note: use Contact_Matrix_boot for
%bootstrapping (it breaks out several steps that are inefficient to
%repeat).

%The function arguments are as follows:
    %contact: the properly formatted ATUS dataset 
    %type: the matrix of types corresponding to observable characteristics
    %loclabels: cell matrix of location labels used to generate rloc
    %labels: used occationally to call variables from the contact dataset
    %varlist: vector of integers referencing the variables used to
        %construct the PCM
    %start: row vector (1x3) defining the starting date to filter ATUS data (use 
        %matrix if gaps in date filter).  Must be same size as stop.
    %stop: row vector (1x3) defining the stoping date to filter ATUS data (use 
        %matrix if gaps in date filter).  Must be same size as start.
    %choice: integer that determines which contact matrices to generate  
        %(1=public, 2=family, 3=both)
    %filtername: vector of auxillary filters (variable names) currently 
        %built for geographic filters only.  Add additional arguments for 
        %the filter values (e.g., filtername={'state';'county'}, additional
        %arguments=[6;6;8],[1;2;1]).
        
%ContactMatrix returns up to five outputs.  
    %public: the daily public PCM collapsed across all public locations
    %catpop: the vector of populations by type (or N)
    %family: the daily household PCM
    %fwgt2:  the population by type based on the ATUS household weights.  
        %This is only used to transform the household PCM from the exposure matrix. 
    %pcount: the number of primary ATUS respondents included in the
        %caluclation
    %publoc: the public PCM by location (returned as a cell array in sparse
        %form)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
contact=reweight(contact(:,[{'tucaseid','actnum','person','wgt','fwgt','where','start','stop','x_mark','year','month','day','dow','weekend','age','state'} labels(1,:)])); %reweighting ATUS data based on individual weights
contact=DateFilter(contact,start,stop);

if nargin>7
    contact=OtherFilter(contact,filtervar,filtervals);
end

cut=unique(cut(:,varlist),'rows'); %doing this here because it could be used in both matrix calculations

if nargout>=4
    pcount=numel(unique(contact.tucaseid));
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Computing Public Contact Matrix
disp('Calculating public PCM')
contactp=contact(contact.person==1,:);

%%%%%%%%%%%%%%%%%%%%
%Calculating population weights from all data 
[~,ridx]=unique(contactp.tucaseid); %index of each respondent to avoid double counting (single observation per respondent)
pop=[contactp.wgt(ridx) double(contactp(ridx,labels(1,varlist)))]; %use index to form matrix of weights and attributes
if numel(varlist)>1 
    [remap,~,nidx]=unique(pop(:,2:end),'rows'); 
    cpop=accumarray(nidx,pop(:,1));
    catpop=ones(size(cut,1),1);
    catpop(ismember(cut,remap,'rows'))=cpop;
else
    nidx=pop(:,2); 
    catpop=accumarray(nidx,pop(:,1));
end
%clear pop cpop remap nidx ridx;

%%%%%%%%%%%%%%%%%%%%%
exclude=[1 12 13 14 15 16 17 18 19 20 21 31 99 89]'; %warning: these indices correspond to values of "where" and not necessarily the vector index
locs=unique(contactp.where); %list of locations
lidx=~ismember(locs,exclude); %index of locations to keep
rloc=loclabels(lidx);    %location labels
[tidx]=ismember(contactp.where,exclude); %index of observations that should be excluded
contactp=contactp(~tidx,:); %keeping only the opposite of the exclude list
H=size(rloc,1);          %number of locations

%%%%%%%%%%%%%%%%%%%%
timeint=double(contactp(:,{'start','stop'}));
[loc,~,location]=unique(contactp.where); %converting to a sequential index for using later.  loc is the reference

[utypes,~,ptype]=unique(double(contactp(:,labels(1,varlist))),'rows');
[~,remap]=ismember(utypes,cut,'rows');
wgt=contactp.wgt;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculating the public PCM 
T=1440;   %number of time periods (minutes in day)
nt=size(cut,1); %Count of all types
qpd=cell(T,1); %Preallocating space for step 1 matrix
tic
for t=1:T
    tidx=(t>timeint(:,1) & t<=timeint(:,2)); %Selecting subset of the data to reduce search time in following loop
    qpd{t}=accumarray([ptype(tidx) location(tidx)],wgt(tidx,1),[],[],[],true); %calculating total number (weights) of people in each location at each minute by type
    %error checking
    if size(qpd{t},1)<size(cut,1)
        tempmat=qpd{t};
        qpd{t}=sparse(nt,H);
        repidx=unique([ptype(tidx) location(tidx)],'rows');
        for ll=1:size(repidx,1)
            qpd{t}(remap(repidx(ll,1)),repidx(ll,2))=tempmat(repidx(ll,1),repidx(ll,2));
        end
    end

end

exposure=cell(H,T);  %preallocating space
for kk=1:T
    for ff=1:size(qpd{kk},2)
        den=sum(qpd{kk}(:,ff));
        den(den==0)=1;
        exposure{ff,kk}=bsxfun(@rdivide,((qpd{kk}(:,ff)*qpd{kk}(:,ff)')/den),catpop');
    end
end
% pubmat1=spcellsum(exposure,2);
% pubmat2=spcellsum(pubmat1,1);
% public=full(pubmat2{1});
toc


end

