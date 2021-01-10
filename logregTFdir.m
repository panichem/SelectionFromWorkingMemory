function [acc, rawAcc, rawProb, wts] = logregTFdir(Y1,X1,Y2,X2,varargin)

%logregTFdir (logistic regression directed transfer test)
%train a binary logistic regression classifier on one data set and test on
%another 

%Input
%X1 = nTrainingTrials x nTimepoints x nCells matrix of training data 
%Y1 = nTrainingTrials x 1 binary vector of training labels 
%X2 = nTestTrials x nTimepoints x nCells matrix of testing data
%Y2 = nTestTrials x 1 binary vector of test labels

%Output
%acc = 1 x nTimepoints vector of mean classification accuracy
%rawAcc = nTestTrials x nTimepoints matrix of binary classification
%         success. acc = mean(rawAcc,1);
%rawProb = nTestTrials x nTimepoints matrix of classifier confidence
%wts     = nCells x nTimepoints matrix of classifier weights

%MP 2019

nInputs = length(varargin);
if nInputs > 0
    solver = varargin{1};
else
    solver = [];
end

[~, nTPs, nCells] = size(X1);

nTrials = size(X2,1);

acc = nan(1,nTPs);
rawAcc = nan(nTrials,nTPs);
rawProb = nan(nTrials,nTPs);

wts = nan(nCells,nTPs);

for iBin = 1:nTPs
    
    x1 = squeeze(X1(:,iBin,:));
    x2 = squeeze(X2(:,iBin,:));
    
    obj = fitclinear(x1,Y1,'Learner','logistic','Solver',solver);
    [yHat, prob] = predict(obj,x2);
    
    acc(iBin) = sum(Y2==yHat)./numel(yHat);
    rawAcc(:,iBin) = Y2==yHat;
    wts(:,iBin) = obj.Beta(:);
    
    tmpProb = prob(:,1); %tstY = 0
    tmpProb(Y2==1) = prob(Y2==1,2);
    rawProb(:,iBin) = tmpProb;
end
