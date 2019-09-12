function cost = computeCost(X,idx,centroids)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

m = size(X,1);

cost = (1/m)*sum(sum((X - centroids(idx,:)).^2));

end

