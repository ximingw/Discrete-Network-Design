function [pred,dist] = Dijkstra(s,A,t)

% DIJKSTRA finds shortest path from node s to all nodes in the network
% using Dijkstra Algorithm
%
% INPUT PARAMETERS
%
%	s:      The starting node s
%	A:      Links, with direction from A(:,1) to A(:,2)
%	t:      Link travel time
%
% OUTPUT PARAMETERS
%
%	pred:	pred(j) = Predecessor of node j
%	dist:	distance from each node to s


m = length(unique(A));   % m = number of nodes
dist = Inf*ones(m,1);
pred = zeros(m,1);

dist(s) = 0;

S = s;   % S = permanently labeled nodes
B = [1:s-1 s+1:m];   % B = temporary labeled nodes

idx = find(A(:,1) == s);   % find the links starts with node s
for j = 1:length(idx)
    node = A(idx(j),2);
    dist(node) = t(idx(j));
    pred(node) = s;
end

while length(S) ~= m
    [min_dist k] = min(dist(B));
    i = B(k);   % i = the shortest temporary node to s
    S = [S i];   % add i to permanently labeled nodes
    B = [B(1:k-1) B(k+1:length(B))];   % eliminate i from temporary labeled nodes
    idx = find(A(:,1) == i);
    for j = 1:length(idx)
        node = A(idx(j),2);
        if dist(node) > dist(i)+t(idx(j))   % update the dist and pred
            dist(node) = dist(i)+t(idx(j));
            pred(node) = i;
        end
    end
end
