function [spsummed] = spcellsum(cellmat,dim)
% spcellsum 
% This function accepts a cell array of sparse matrices and sums across the
% dimension of choice.  When the matrices are not sparse, the matrices can
% be concatenated using the cat() function.  This is useful for summing
% over higher dimensional sparse matrices.



if dim==2
    tempmat=cellmat(:,1); %shell to populate by summing dim 2 sparse matrices
    if size(cellmat,2)>1
        for ii=2:size(cellmat,2)  %start at 2 because cumulative sum
            tempmat=cellfun(@(x1,x2) x1+x2,tempmat,cellmat(:,ii),'UniformOutput',false);
        end
    end
elseif dim==1
    tempmat=cellmat(1,:); %shell to populate by summing dim 1 sparse matrices
    if size(cellmat,1)>1
        for ii=2:size(cellmat,1)  %start at 2 because cumulative sum
        tempmat=cellfun(@(x1,x2) x1+x2,tempmat,cellmat(ii,:),'UniformOutput',false);
        end
    end
end
spsummed=tempmat;
end

