function [clustIdx, nClusts, clustMass] = getClust(h,statistic)

[clustIdx, nClusts] = bwlabel(h);
clustMass = nan(nClusts,1);
for iClust = 1:nClusts
    clustMass(iClust) = sum(statistic(clustIdx==iClust));
end