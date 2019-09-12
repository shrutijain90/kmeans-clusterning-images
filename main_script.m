clear
folder_Dom = 'C:\Users\shruti\Desktop\Dominican_Republic';
folder_Hat = 'C:\Users\shruti\Desktop\Haiti';

%%%%%%%%%%%%%%%%%%% Parameters to choose %%%%%%%%%%%%%%%%%%
patch_size = 128;
k_range = 2:10;
max_iters = 50;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% pick up all quad names
S_Dom = dir(fullfile(folder_Dom,'*.tif'));
S_Hat = dir(fullfile(folder_Hat,'*.tif'));

n = size(S_Dom,1) + size(S_Hat,1);

% make a single X dataset with all quads
X_tot = [];

for m = 1:numel(S_Dom)
    F = fullfile(folder_Dom,S_Dom(m).name);
    I = imread(F);
    I = I(:,:,1:3);
    X = image_to_vector(I,patch_size);
    X_tot = [X_tot; X];
end

for m = 1:numel(S_Hat)
    F = fullfile(folder_Hat,S_Hat(m).name);
    I = imread(F);
    I = I(:,:,1:3);
    X = image_to_vector(I,patch_size);
    X_tot = [X_tot; X];
end

% calculate cost to optimize the number of clusters
costs = zeros(1,length(k_range));
counter = 1;

for k = k_range(1,1):k_range(1,end)
    
    K = k;
    initial_centroids = kMeansInitCentroids(X_tot, K);
    [centroids, idx] = runkMeans(X_tot, initial_centroids, max_iters);
    idx = findClosestCentroids(X_tot, centroids);
    
    costs(1,counter) = computeCost(X_tot,idx,centroids);
    counter = counter + 1;

end

figure; hold on; plot(k_range,costs); xlabel('Number of clusters'); ylabel('Cost'); title('Cost vs number of clusters');

% visualize clustering with optimal number of clusters
K = 4; % choose this based on the cost curve

figure;
hold on;
sgtitle('Clustering with 4 clusters')

for m = 1:numel(S_Dom)
    F = fullfile(folder_Dom,S_Dom(m).name);
    I = imread(F);
    I = I(:,:,1:3);
    str = sprintf('DR: Quad %d',m);
    subplot(n/2,n/2,m); imagesc(I); axis equal; axis off; title(str);
end

for m = 1:numel(S_Hat)
    F = fullfile(folder_Hat,S_Hat(m).name);
    I = imread(F);
    I = I(:,:,1:3);
    str = sprintf('Haiti: Quad %d',m);
    subplot(n/2,n/2,(n+m)); imagesc(I); axis equal; axis off; title(str);
end

initial_centroids = kMeansInitCentroids(X_tot, K);
[centroids, idx, costs_iter] = runkMeans(X_tot, initial_centroids, max_iters);
idx = findClosestCentroids(X_tot, centroids);

for i = 1:n
    idx_recovered = reshape(idx(1 + (i-1)*(size(idx,1)/n) : i*(size(idx,1)/n),:), sqrt(size(idx,1)/n), sqrt(size(idx,1)/n));
    if i <= n/2
        str = sprintf('DR: Quad %d',i);
        subplot(n/2,n/2,(n/2+i)); imagesc(idx_recovered); axis equal; axis off; colormap(parula(K)); colorbar; title(str);
    else
        str = sprintf('Haiti: Quad %d',i-n/2);
        subplot(n/2,n/2,(n+i)); imagesc(idx_recovered); axis equal; axis off; colormap(parula(K)); colorbar; title(str);
    end
end

% visualize clusters one at a time
for c = 1:K
    figure;
    hold on;
    str = sprintf('Cluster %d',c);
    sgtitle(str)
    
    for m = 1:numel(S_Dom)
        F = fullfile(folder_Dom,S_Dom(m).name);
        I = imread(F);
        I = I(:,:,1:3);
        str = sprintf('DR: Quad %d',m);
        subplot(n/2,n/2,m); imagesc(I); axis equal; axis off; title(str);
    end

    for m = 1:numel(S_Hat)
        F = fullfile(folder_Hat,S_Hat(m).name);
        I = imread(F);
        I = I(:,:,1:3);
        str = sprintf('Haiti: Quad %d',m);
        subplot(n/2,n/2,(n+m)); imagesc(I); axis equal; axis off; title(str);
    end
    
    for i = 1:n
        idx_recovered = reshape(idx(1 + (i-1)*(size(idx,1)/n) : i*(size(idx,1)/n),:), sqrt(size(idx,1)/n), sqrt(size(idx,1)/n));
        if i <= n/2
            str = sprintf('DR: Quad %d',i);
            subplot(n/2,n/2,(n/2+i)); imagesc(idx_recovered == c); axis equal; axis off; title(str);
        else
            str = sprintf('Haiti: Quad %d',i-n/2);
            subplot(n/2,n/2,(n+i)); imagesc(idx_recovered == c); axis equal; axis off; title(str);
        end
    end
    
end

figure; hold on; plot(1:max_iters,costs_iter); xlabel('Number of iterations'); ylabel('Cost'); title('Cost vs number of iterations (4 clusters)');

% choose cluster(s) belonging to forest and calculate the forest percentage for each country
% cluster 3 belongs to forest - this may change with each run
idx_Dom = idx(1 : size(S_Dom,1)*(size(idx,1)/n),:);
idx_Hat = idx(1 + size(S_Dom,1)*(size(idx,1)/n) : end,:);

% forest cover in Dominican Republic = 48.95%, Hati = 6.10%
forest_Dom = sum((idx_Dom == 3))/(size(idx_Dom,1))
forest_Hat = sum((idx_Hat == 3))/(size(idx_Hat,1))
