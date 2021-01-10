%this demo loads example data, reproduces the low-D population
%representations of the upper and lower conditions as in figure 4a, and
%calculates the angle between their planes of best fit

%MP 2021

clear

%% load data
load('planesDemo','dat'); %dat is an nConditions x nNeurons matrix of firing rates for a particular timepoint

%% computation
%run pca across all 8 conditions in preparation for dimensionality reduction
[~, Y] = pca(dat);

%run pca across the 4 upper and 4 lower conditions separately in 3D in
%preparation for plane fitting
nDim = 3;
eigvecsUp = pca( Y( 1:4, 1:nDim ) );
eigvecsDn = pca( Y( 5:8, 1:nDim ) );

%compute the angle between the upper and lower plane of best fit
cosTheta = planeAngle(eigvecsUp(:,1),eigvecsUp(:,2),eigvecsDn(:,1),eigvecsDn(:,2));
fprintf(1,'cosine of the angle between the upper and lower planes is %.2f\n',cosTheta)

%% plotting 

%calculate colors for plotting data
xe = linspace(0, 2*pi, 5);
xc = xe(1:4) + diff(xe(1:2))/2;
[unitX, unitY] = pol2cart(xc,30);
cols = lab2rgb([70.*ones(numel(unitX),1),unitX',unitY']);
cols = [cols; cols];

%camera position
cp = [
    306.7153 -362.0354   70.4390
    594.3579   33.1912  114.6168
    ];

f = figure('units','inches','position',[1 1 10 5]);

%plot the marker for each condition 
for i = 1:8
    if i<=4 %upper
        ls = 'o';
        mfc = cols(i,:);
    else %lower
        ls = 'v';
        mfc = cols(i,:);
    end
    hold on
    plot3(Y(i,1),Y(i,2),Y(i,3),ls,'MarkerSize',10,'color',cols(i,:),'MarkerFaceColor',mfc);
end

%connect the markers at each location
plot3([Y(1,1) Y(2,1)], [Y(1,2) Y(2,2)], [Y(1,3) Y(2,3)],'-','color',[.5 .5 .5]);
plot3([Y(2,1) Y(3,1)], [Y(2,2) Y(3,2)], [Y(2,3) Y(3,3)],'-','color',[.5 .5 .5]);
plot3([Y(3,1) Y(4,1)], [Y(3,2) Y(4,2)], [Y(3,3) Y(4,3)],'-','color',[.5 .5 .5]);
plot3([Y(4,1) Y(1,1)], [Y(4,2) Y(1,2)], [Y(4,3) Y(1,3)],'-','color',[.5 .5 .5]);
plot3([Y(5,1) Y(6,1)], [Y(5,2) Y(6,2)], [Y(5,3) Y(6,3)],'-','color',[.5 .5 .5]);
plot3([Y(6,1) Y(7,1)], [Y(6,2) Y(7,2)], [Y(6,3) Y(7,3)],'-','color',[.5 .5 .5]);
plot3([Y(7,1) Y(8,1)], [Y(7,2) Y(8,2)], [Y(7,3) Y(8,3)],'-','color',[.5 .5 .5]);
plot3([Y(8,1) Y(5,1)], [Y(8,2) Y(5,2)], [Y(8,3) Y(5,3)],'-','color',[.5 .5 .5]);

%plot plane of best fit for each location
scaleFactor = 25;

mn = mean(Y(1:4,1:3),1);
x = eigvecsUp(1,1:2).*scaleFactor;
y = eigvecsUp(2,1:2).*scaleFactor;
z = eigvecsUp(3,1:2).*scaleFactor;
patch([x -x]+mn(1),[y -y]+mn(2),[z -z]+mn(3),.5.*[1 1 1],'EdgeColor','none','FaceAlpha',.5);

mn = mean(Y(5:8,1:3),1);
x = eigvecsDn(1,1:2).*scaleFactor;
y = eigvecsDn(2,1:2).*scaleFactor;
z = eigvecsDn(3,1:2).*scaleFactor;
patch([x -x]+mn(1),[y -y]+mn(2),[z -z]+mn(3),.5.*[1 1 1],'EdgeColor','none','FaceAlpha',.5);

%etc
grid on
axis square
xlabel('PC1');
ylabel('PC2');
zlabel('PC3');
set(gca,'xtick',[-20 0 20],'ytick',[-20 0 20],'ztick',[-20 0 20]);

campos(cp(1,:));

