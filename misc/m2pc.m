function [rM] = m2pc(aM, varargin)
%
% NAME
%
%       function [rM] = m2pc(aM, varargin)
%
%
% ARGUMENTS
%
%       INPUT
%       aM              matrix                  a matrix defining the values
%                                               (mass) of a set of ordered
%                                               points
%
%       OPTIONAL
%
%       OUTPUT
%       rM              matrix                  a 3D matrix ordered by 
%                                               indices of aM with the 3rd
%                                               column denoting the value at
%                                               each original index.
%
% DESCRIPTION
%
%       'm2pc' converts a matrix of size MxN into a 3D matrix of size MNx3
%       where each index of the original matrix is explicitly encoded into
%       a lookup with associated value.
%
% PRECONDITIONS
%
%
% POSTCONDITIONS
%
%       o "flattens" a matrix into an ordered lookup.
% 
% SEE ALSO
%
% HISTORY
% 05 February 2014
% o Initial design and coding.
% 
%

[rows cols]     = size(aM);

rM              = zeros(rows*cols, 3);

% Create one long row of final values
F               = aM'(:);

% Now build coordinate axes:
r               = [1:rows]';
c               = [1:cols];
C               = repmat(c, rows, 1);
R               = repmat(r, 1, cols);

% Make certain that the array is float!
rM              = double([R'(:) C'(:), F]);


%  index = 1;
%  for row=1:rows
%      for col=1:cols
%          rM(index, 1)    = row;
%          rM(index, 2)    = col;
%          rM(index, 3)    = aM(row, col);
%          index           = index + 1;
%      end
%  end
%  

