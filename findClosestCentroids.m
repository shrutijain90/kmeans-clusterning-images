function idx = findClosestCentroids(X, centroids)
%FINDCLOSESTCENTROIDS computes the centroid memberships for every example
%   idx = FINDCLOSESTCENTROIDS (X, centroids) returns the closest centroids
%   in idx for a dataset X where each row is a single example. idx = m x 1 
%   vector of centroid assignments (i.e. each entry in range [1..K])
%

% Set K
K = size(centroids, 1);

idx = zeros(size(X,1), 1);

m = size(X,1);

for i = 1:m
    dist = zeros(K,1);
    for k = 1:K
        dist(k,1) = sum((X(i,:) - centroids(k,:)).^2);
    end
    k_min = find(dist == min(dist));
    idx(i,1) = k_min(1);
end

end
