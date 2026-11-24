function nam2 = reorder(nams,delim);
%REORDER  Reorders rows of a character matrix that start with different
%         number of characters and a delimiting character(s), so that
%         the single characters before the delimiter are sorted before
%         the double characters, etc.  Useful for sorting a character
%         matrix that starts with text numbers so that it is sorted
%         numerically.
%
%         NAM2 = REORDER(NAMS,DELIM) given the character matrix NAMS
%         and a delimiting character(s) DELIM, returns the sorted rows
%         based on the number of characters before the delimiter.  The
%         delimiter defaults to an underscore (_).
%
%         NOTES:  1.  Every row of the character matrix must contain
%                 the delimiter character(s).
%
%         18-Mar-2011 * Mack Gardner-Morse
%

%#######################################################################
%
% Check for Inputs
%
if (nargin<1)
  error([' *** ERROR in reorder:  An input character matrix is', ...
         ' required!']);
end
%
if (nargin<2)
  delim = '_';
end
%
%  Verify that Inputs are Characters
%
if ~ischar(nams)|~ischar(delim)
  error(' *** ERROR in reorder:  Inputs must be characters!');
end
%
% Reorder Files So 10s, 100s, etc. Are Sorted Properly
%
[nfiles,nc] = size(nams);
idx = zeros(nfiles,1);
for k = 1:nfiles
   id = strfind(nams(k,:),delim);
   idx(k) = id(1);
end
idr = 1;
nam2 = ' ';
nam2 = nam2(ones(nfiles,nc));
for k = 2:max(idx)
   id = find(idx==k);
   nr = size(id,1);
   nam2(idr:idr+nr-1,:) = sortrows(nams(id,:));
   idr = idr+nr;
end
%
return