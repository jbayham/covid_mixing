function newcontact=DataConsistencyCheck(contact)
%Data consistency check - there are some cases where the primary person
%records dont agree with the other persons within an activity which causes
%problems in reallocation scenarios.
contact=sortrows(contact,{'tucaseid','actnum','person'});
resp=contact(contact.person==1,:);
oth=contact(contact.person~=1,:);
[~,respidx,~]=intersect(resp,oth,{'tucaseid','actnum'});
personvars={'person','wgt','sex','age','school','emp','agerng'};
casevars=get(contact,'VarNames');
casevars=casevars(~ismember(casevars,personvars));
newoth=join(oth(:,[{'tucaseid','actnum'} personvars]),resp(respidx,[{'tucaseid','actnum'} casevars]),'Keys',{'tucaseid','actnum'});
newoth(:,{'tucaseid_1','actnum_1'})=[];
final=union(resp,newoth,{'tucaseid','actnum','person'});
newcontact=sortrows(final,{'tucaseid','actnum','person'});
end