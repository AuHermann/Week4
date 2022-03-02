image = imread('BOMap.png');
grayimage = rgb2gray(image);
bwimage = grayimage < 0.5;
grid = binaryOccupancyMap(bwimage, 80);


show(grid)

save('awesomeMap.mat', "grid");