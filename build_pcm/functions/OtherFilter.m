function [ outdata ] = OtherFilter(data,filtervar,filtervals)
%OtherFilter accepts a time use dataset, a name of a variable to filter on
%and corresponding filter values and returns the filtered data

vnames=get(data,'VarNames');
nvarin=sum(ismember(vnames,filtervar));
if nvarin>0 && nvarin==size(filtervals,2)
    selvars=double(data(:,filtervar));
    grab=false(size(data,1),1);
    for ii=1:size(filtervals,1)
        grab(ismember(selvars,filtervals(ii,:),'rows'))=1;
    end
    outdata=data(grab,:);
else
    disp('Filter inputs not valid variable names')
end


end

