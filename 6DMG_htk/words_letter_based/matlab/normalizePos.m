% P, NP are of size 3 x N, 
function NP = normalizePos(P)
N = size(P,2);
P_max = max(P,[],2);
P_min = min(P,[],2);
diff = max(P_max-P_min);
scale = 2/diff;

cen = (P_max+P_min)/2;
NP = P - repmat(cen, 1, N);  % offset
NP = NP*scale;              % scale
