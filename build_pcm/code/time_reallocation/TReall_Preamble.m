%Preable to running any of the Time Use Reallocation files (TRall_)

clearvars -except tupath Time_Comp

%Modifying the mixing dataset to readjust time spent in locations.  Need to
%save a new copy of the dataset and change path to new dataset
load('MixingDataset_HH.mat')
contact.actdur=contact.stop-contact.start;
ocontact=contact;
locs=unique(contact.where);
%
%call function to predict inflexibility 1=no.  Specify additional output
%argument for prediction accuracy tuple (in sample, out of sample)
contact.inflex=Pred_Flex(dataset2table(contact));

%%%%%
%Defining subset of primary respondents
icontact=contact(contact.person==1,:);
icontact=sortrows(icontact,{'tucaseid','actnum'});

%Defining ATUS subset
kdat=contact(contact.x_mark==0,:);