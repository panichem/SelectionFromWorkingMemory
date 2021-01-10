function zPhaseMI = computePhaseModulationIndex(rho,theta,nIter)

%compute z-scored "phase modulation index" describing how much a neuron's firing
%rate is modulated by color

%Input
%rho = nTrials x nTimepoints matrix of firing rates 
%theta = nTrials x 1 vector of color angles (radians) 
%nIter = number of null samples to compute (for z-scoring)

%Output
%zPhaseMI = 1 x nTimepoints vector of z-scored phase modulation indices 

%MP 2019

nBins = 8;
[nTrials, nTP] = size(rho);

tmpPhaseMI = phaseModulationIndex( rho, theta, nBins);

nullPhaseMI = nan(nIter,nTP);
for iIter = 1:nIter
    nullTheta = theta(randperm(nTrials));
    nullPhaseMI(iIter,:) = phaseModulationIndex( rho, nullTheta, nBins);
end

zPhaseMI = ( tmpPhaseMI-mean(nullPhaseMI,1) ) ./ std(nullPhaseMI,[],1);
