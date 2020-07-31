function con=convertcon(vec,cut)
%This function takes a continuous variable like age and a vector of cutoff
%values and outputs a categorical variable based on the provided cutoff
%values.  The vector of cutoffs values needs to be in order, the first
%value is the lower bound, and the last value is the upper bound.  Any
%values outside of the cutoff values will be returned as zero so NA
%categories should be applied to output(i)==0

%Setting up categorical brackets
start=[cut(1) cut(2:end-1)']; 
stop=[cut(2:end-1)' cut(end)]; 
n=length(start);

con=zeros(length(vec),n);
for i=1:n
    con(:,i)=(vec>=start(i) & vec<stop(i))*i;
end
con=squeeze(sum(con,2));

