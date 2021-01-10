function [pvals, clustMass, clustIdx] = clusterMassOneSamp(x,nIter,varargin)

%compare the columns of x versus zero and return the
%cluster-corrected p-values (Maris & Oostenveld, 2007)

%Input
%x = nSamples x nTests data matrix
%nIter = integer number of null clusterMass values to compute (1000)

%Output
%pvals = 1 x nclust vector of p-values
%clustMass = 1 x nclust vector of cluster masses
%clustIdx = 1 x nTests vector of cluster indices

%MP 2019

nT = size(x,1);

thresh = 0.05;

if ~isempty(varargin) && strcmpi(varargin{1},'tail')
    [h, p, ~, stat] = ttest(x,0,'tail',varargin{2});
else
    [h, p, ~, stat] = ttest(x);
end

h(isnan(h)) = 0;
p(isnan(p)) = 1;
p = p <= thresh;    
    
[clustIdx, ~, clustMass] = getClust(p,stat.tstat);

nullMass = nan(nIter,1);
for iIter = 1:nIter
    tmpX = x;
    idx = rand(nT,1)>.5;
    tmpX(idx,:) = -1.*tmpX(idx,:);
    
    [tmpH, tmpP, ~, tmpStat] = ttest(tmpX);
    tmpH(isnan(tmpH)) = 0;
    tmpP(isnan(tmpP)) = 1;
    tmpP = tmpP <= thresh;
    
    
    [~, ~, tmpMass] = getClust(tmpP,tmpStat.tstat);
    if isempty(tmpMass)
        nullMass(iIter) = 0;
    else 
        nullMass(iIter) = max(abs(tmpMass));
    end
end

pvals = sum(nullMass>=abs(clustMass)')./nIter;

