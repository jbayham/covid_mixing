%This program imputes missing values for categorical variables in the ATUS
%and NHAPS data using hot deck methods.  Hot decking matches individuals
%with the same observed/reported characteristics, creates donor classes, and
%use the reported values from the donor class to replace missing values.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;

load('build_pcm/inputs/atus_data.mat','contact');
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Additional modifications to variables
%Capping household size at 5
contact.hhsize(contact.hhsize>5)=5;
%Creating the age rng variable
contact.age(contact.age>80)=80;
%contact.agerng=convertcon(double(contact(:,'age')),[0 5 13 18 25 35 45 55 65 100]');
contact.agerng=convertcon(double(contact(:,'age')),[0 19 39 64 100]');
%contact.agerng=contact.age+1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Creating category labels for stratifying characteristics
%labels(1,:)={'agerng','hhinc','hhsize'};  
labels(1,:)={'agerng'}; 
%labels{2,1}={'0-4';'5-12';'13-17';'18-24';'25-34';'35-44';'45-54';'55-64';'65+'};
labels{2,1}={'0-19';'20-39';'40-64';'65+'};
%labels{2,1}=string(unique(contact.agerng));
%labels{2,2}={'0-25';'25-50';'50-100';'100-150';'150+'};
%labels{2,3}={'1';'2';'3';'4';'5+'};

%Relabeling locations
[~,~,contact.where]=unique(contact.where);
loclabels={'Respondents home or yard';'Respondents workplace';'Someone elses home'...
    ;'Restaurant or Bar';'Place of Worship';'Grocery Store';'Other Store (Mall)'...
    ;'School';'Outdoors (not home)';'Public Building (Library)';'Other Place'...
    ;'Car, truck, or motorcycle';'Walking';'Bus';'Subway_train';'Bicycle';'Boat_ferry'...
    ;'Taxi_limousine service';'Airplane';'Other transportation';'Factory'...
    ;'Personal Services';'Health Facility';'Office Bldg (Bank)';'Gym-Health Club'};

%Creating population segments
cut=int8(unique(double(contact(:,labels(1,:))),'rows'));

%Making sure that all records are consistent e.g., all persons reporting the
%same location when doing the same activity.
contact=DataConsistencyCheck(contact);

contact(contact.agerng==0,:);

save('build_pcm/cache/MixingDataset_HH.mat','contact','labels','loclabels','cut','-v7.3');
save('build_pcm/cache/cut_labels.mat','cut','labels')
