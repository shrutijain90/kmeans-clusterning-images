function cost = computeCost(X,idx,centroids)

m = size(X,1);

cost = (1/m)*sum(sum((X - centroids(idx,:)).^2));

end
