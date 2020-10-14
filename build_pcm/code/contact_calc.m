%This script loads the MixingDataset used to construct the PCMs and applies
%any filters to the data
pname=sprintf('build_pcm/cache/MixingDataset_HH.mat'); %This points to the location of the ATUS dataset relative to the working directory 
load(pname)
%contact=contact(contact.state==8,:);
yrlist=[(1992:1994) (2003:2018)];  %Use yrlist if you want to grab certain dates from each year

%Set date filter where date format is (Y,M,D)
start=[yrlist' repmat([9 1],numel(yrlist),1)]; 
stop=[yrlist' repmat([11 15],numel(yrlist),1)];
%%
%for debugging
%filtervar={'weekend'};
%filtervals=[0 1];
%ii=1

%Public location PCMs
[exposure,catpop,locations,pcount]=public_PCM(contact,cut,loclabels,labels,varlist,start,stop);

%filtervar={'dow'};
%filtervals=[1];
%ii=1

%Public location PCMs
%[exposure,catpop,locations,pcount]=public_PCM(contact,cut,loclabels,labels,varlist,start,stop,filtervar,filtervals(ii));

%Household PCMs
[~,~,fammat,fampop]=household_PCM(contact,cut,loclabels,labels,varlist,start,stop,2);





