function [MI, meanRho, xc] = phaseModulationIndex(rho,theta,nBins)
%ref: Tort, Komorowski, Eichenbaum, and Kopell
%J Neurophysiol 2010
%
% MP 2019

nTPs = size(rho,2);

xe = linspace(0,2*pi,nBins+1);
xc = xe(1:end-1) + (xe(2)-xe(1))/2;

binIdx = discretize(theta,xe);

if numel(unique(binIdx)) ~= nBins
    MI = nan;
    return;
end

%meanRho = accumarray(binIdx,rho,[],@mean);
meanRho = nan(nBins,nTPs);
for iBin = 1:nBins
    meanRho(iBin,:) = mean(rho(binIdx==iBin,:),1);
end

pObserved = meanRho ./ sum(meanRho);
pUniform  = ones(nBins,nTPs) ./ nBins;
tmp = pObserved .* log( pObserved ./ pUniform );
tmp( pObserved == 0 ) = nan;
klDistance = nansum(tmp);

MI = klDistance / log(nBins);

