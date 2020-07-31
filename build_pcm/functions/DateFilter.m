function [outdata] = DateFilter(data,start,stop)
%DateFilter accepts an ATUS dataset and returns the subset of data that
%meet a set of criteria

newdate=datenum([data.year data.month data.day]);
grab=false(size(data,1),1);
for ii=1:size(start,1)
    grab(newdate>=datenum(start(ii,:)) & newdate<=datenum(stop(ii,:)))=1;
end
outdata=data(grab,:);
end

