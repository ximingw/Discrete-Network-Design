function x = AllorNothing(A,t,OD,o,d)

% ALLORNOTHING gets the link flows by performing all-or-nothing
% assignment
% 
% INPUT PARAMETERS
%
%	A:      Links, with direction from A(:,1) to A(:,2)
%	t:      Link travel time
%	OD:     O-D trip matrix
%	o:      Origin node index (row index of O-D trip matrix)
%	d:      Destination node index (column index of O-D trip matrix)
%
% OUTPUT PARAMETERS
%
%	x:  	Link flows by performing all-or-nothing assignment


n = size(A,1);   % n = number of links
x = zeros(n,1);

for i = 1:size(OD,1)
    
    s = o(i);   % s = origin (starting) node
    [pred,dist] = Dijkstra(s,A,t);
    
    for k = 1:size(OD,2)
        e = d(k);   % e = destination (ending) node
        while pred(e) ~= 0   % get path from s to e and assign O-D flow
            idx = find(A(:,1) == pred(e));
            for j = 1:length(idx)
                if A(idx(j),2) == e
                    x(idx(j)) = x(idx(j))+OD(i,k);
                end
            end
            e = pred(e);
        end
    end
    
end
