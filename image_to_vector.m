function X_reshape = image_to_vector(I,n)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

imSz = size(I);
patchSz = [n n];
xIdxs = [1:patchSz(2):imSz(2) imSz(2)+1];
yIdxs = [1:patchSz(1):imSz(1) imSz(1)+1];
patches = cell(length(yIdxs)-1,length(xIdxs)-1);
for i = 1:length(yIdxs)-1
    Isub = I(yIdxs(i):yIdxs(i+1)-1,:,:);
    for j = 1:length(xIdxs)-1
        patches{i,j} = Isub(:,xIdxs(j):xIdxs(j+1)-1,:);
    end
end

varis = zeros(size(patches));
reds = zeros(size(patches));
greens = zeros(size(patches));
blues = zeros(size(patches));
reds_sd = zeros(size(patches));
greens_sd = zeros(size(patches));
blues_sd = zeros(size(patches));

for i = 1:size(patches,1)
  
    for j = 1:size(patches,2)
      
      x = patches{i,j};
      reds(i,j) = nanmean(nanmean(x(:,:,1)));
      greens(i,j) = nanmean(nanmean(x(:,:,2)));
      blues(i,j) = nanmean(nanmean(x(:,:,3)));
      
      if reds(i,j) == 0
          reds(i,j) = 1;
      end
      if blues(i,j) == 0
          blues(i,j) = 1;
      end
      if greens(i,j) == 0
          greens(i,j) = 1;
      end
      varis(i,j) = (greens(i,j) - reds(i,j))/(greens(i,j) + reds(i,j) - blues(i,j));
      
    end 
  
end

sz = size(reds);
X = zeros(sz(1)*sz(2),1);
X(:,1) = reshape(reds,[sz(1)*sz(2),1]);
X(:,2) = reshape(greens,[sz(1)*sz(2),1]);
X(:,3) = reshape(blues,[sz(1)*sz(2),1]);
X(:,4) = reshape(varis,[sz(1)*sz(2),1]);

%X(:,1) = (X(:,1)- mean(X(:,1)))/std(X(:,1));
%X(:,2) = (X(:,2)- mean(X(:,2)))/std(X(:,2));
%X(:,3) = (X(:,3)- mean(X(:,3)))/std(X(:,3));
%X(:,4) = (X(:,4)- mean(X(:,4)))/std(X(:,4));

X_reshape = X;

end

