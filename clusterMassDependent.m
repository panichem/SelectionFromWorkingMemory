function [pvals, clustMass, clustIdx] = clusterMassDependent(x,y,nIter,varargin)

%compare the columns of x and y with a t-test and return the
%cluster-corrected p-values (Maris & Oostenveld, 2007)

%Input
%x = nSamples x nTests data matrix
%y = nSamples x nTests data matrix
%nIter = integer number of null clusterMass values to compute (1000)

%Output
%pvals = 1 x nclust vector of p-values
%clustMass = 1 x nclust vector of cluster masses
%clustIdx = 1 x nTests vector of cluster indices

%MP 2019

nX = size(x,1);
nY = size(y,1);
nT = nX+nY;

cond = nan(nT,1);
cond(1:nX) = 1;
cond(nX+1:end) = 2;

thresh = 0.05;

if ~isempty(varargin) && strcmpi(varargin{1},'tail')
    [h, p, ~, stat] = ttest(x,y,'tail',varargin{2});
else
    [h, p, ~, stat] = ttest(x,y);
end

h(isnan(h)) = 0;
p(isnan(p)) = 1;
p = p <= thresh;

[clustIdx, ~, clustMass] = getClust(p,stat.tstat);

dat = [x;y];
nullMass = nan(nIter,1);
for iIter = 1:nIter
    tmpCond = cond(randperm(nT));
    tmpX = dat(tmpCond==1,:);
    tmpY = dat(tmpCond==2,:);
    
    [tmpH, tmpP, ~, tmpStat] = ttest(tmpX,tmpY);
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

