%When schools are closed, all time at school is shifted to other
%activities. All scripts import the original mixing dataset with most missing 
%values imputed, modifications are made and the resulting dataset is
%written to a new contact datasets in Contact Mat folder 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Time reallocation scenarios: 
% 1) No policy so nothing changes, 
% 2) children go to work with their parents, and teens and adults adopt a mix of public and private activities; 
% 3) people reallocate their time to public and household locations, 
% 4) people adopt their weekend patterns,
% 5) people reallocate their time to their household
% 6) people self isolate.  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tupath='TU_Data/';

% 2a) The script reallocates children's time
% from school to a distribution over parents workplaces (since we don't
% observe where their parents work), and reallocates teens and adults from
% school to public and household activities.  This version neglects
% parent's workplace flexibility.
run TReall_Work.m


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2b) The script is similar to 2a but also reallocates working
% parents with flexibility from work to other activities
run TReall_Work_flex.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3) The script assumes children in school and working parents reallocate
% their time to a mixture of thier other public and private activities.
%%%Note: the only script that doesn't run the preamble
run TReall_PubHome.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4a) The script assumes children in school and working parents adopt their 
% weekend contact patterns.  Since we don't observe people over multiple
% days, we create pools of (schedule) donors based on similar demographics to
% match people and reallocate time.
run TReall_Weekend.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4b) The script assumes children in school and working parents adopt the 
% weekend contact patterns of other parents doing activities with their children.  
% Since we don't observe people over multiple
% days, we create pools of (schedule) donors based on similar demographics to
% match people and reallocate time.
run TReall_Weekend_wkids.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 5) anyone at school and parents of school aged kids reallocate their 
% time to their household
run TReall_Home.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 6) anyone at school and parents of school aged kids isolate.  
run TReall_Isolate.m
 
