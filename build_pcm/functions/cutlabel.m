function cutlabel=cutlabel(cutmat,labels)
%This program creates a cell matrix containing the subpopulation labels
%corresponding to the subgroup indices matrix.  

%Argument 1) The first argument is the set of indices in which each row
%uniquely identifies a subgroup. e.g., unique(cut(:,varlist),'rows') where
%varlist is a scalar or vector corresponding to the location of the
%variables chosen to create the matrix.

%Argument 2) The subset of labels corresponding to the subgroup
%identifiers e.g., labels(2,varlist).  

%cutmat and labels are created in DataIn.m


%Subsection checking whether cutmat contains any zeros.  Since the values in
%cutmat are used to index the labels, those values must be shifted up one.
for ii=1:size(cutmat,2)
    if min(cutmat(:,ii))==0
        cutmat(:,ii)=bsxfun(@plus,cutmat(:,ii),1);
    end
end 

%Creating the labels
labelmat=cell(size(cutmat));
nvar=size(cutmat,2);
for ii=1:nvar
    label=labels{ii};
    k=size(label,1);
    for jj=1:k
        labelmat(cutmat(:,ii)==jj,ii)=label(jj);
    end
end
cutlabel=labelmat;