maxIterations = 72834;

upScaleFactor = 2;
width = 1920;
height = 1080;
gridSizeX = width * upScaleFactor;
gridSizeY = height * upScaleFactor;
frameRate = 60; % frames per second
maxZoomFacPerSecond = 1.5;
maxZoom = 5.31e11;%5.3e+12;
startZoom = 5.3e11;
totalSeconds = (log(maxZoom) - log(startZoom))/log(maxZoomFacPerSecond);
totalFrames = ceil(totalSeconds*frameRate);
fprintf('Going to render %i frames\n', totalFrames);

zooms = exp(linspace(log(startZoom), log(maxZoom), totalFrames));

xCenter = -0.750045367143;
yCenter = 0.004786271734;

% Load the kernel
cudaFilename = 'pctdemo_processMandelbrotElement2.cu';
ptxFilename = ['pctdemo_processMandelbrotElement2.ptx'];
kernel = parallel.gpu.CUDAKernel( ptxFilename, cudaFilename );

% Make sure we have sufficient blocks to cover all of the locations
numElements = gridSizeX * gridSizeY;
kernel.ThreadBlockSize = [kernel.MaxThreadsPerBlock,1,1];
kernel.GridSize = [ceil(numElements/kernel.MaxThreadsPerBlock),1];

outR = zeros( [gridSizeY, gridSizeX ], 'gpuArray' );
outG = zeros( [gridSizeY, gridSizeX ], 'gpuArray' );
outB = zeros( [gridSizeY, gridSizeX ], 'gpuArray' );

frameCounter = 0;
parulas = parula(256);

minCountsNow = 72834;

vidCounter = 0;
framesPerVideo = 100;

for zoom = zooms
    maxIterations = minCountsNow + 500; % Max image depth of 500 iterations
    minCountsNew = maxIterations;
    xlim = [xCenter - width/zoom/2, xCenter + width/zoom/2];
    ylim = [yCenter - height/zoom/2, yCenter + height/zoom/2];
    
    % Setup
    t = tic();
    x = gpuArray.linspace( xlim(1), xlim(2), gridSizeX );
    y = gpuArray.linspace( ylim(1), ylim(2), gridSizeY );
    [xGrid,yGrid] = meshgrid( x, y );
    % Call the kernel
    [outR, outG, outB, minCountsNew] = feval( kernel, outR, outG, outB, minCountsNew, xGrid, yGrid, maxIterations, numElements, minCountsNow );
    % Show
    [outR, outG, outB, minCountsNew] = gather( outR, outG, outB, minCountsNew ); % Fetch the data back from the GPU
    minCountsNow = minCountsNew;
    imwrite( cat(3, outR, outG, outB), sprintf('G:\\frame%05d.bmp', frameCounter))
    gpuCUDAKernelTime = toc( t );
    fprintf( 'Frame %i/%i done in %1.3f s, fps: %d, time left: %.5d, min counts: %i\n', frameCounter + vidCounter*framesPerVideo, totalFrames, gpuCUDAKernelTime, 1/gpuCUDAKernelTime, (totalFrames - (frameCounter+ vidCounter*framesPerVideo))*gpuCUDAKernelTime, minCountsNow);
    frameCounter = frameCounter + 1;
    if (mod(frameCounter, framesPerVideo) == 0)
        system(strcat("g: && ffmpeg -r 60 -s 1920x1080 -i frame%05d.bmp -vcodec libx264  -vb 20M -pix_fmt yuv420p final", sprintf("%05d", vidCounter), ".mp4 -start_number 0"))
        system("g: && del frame*.bmp")
        vidCounter = vidCounter + 1;
        frameCounter = 0;
    end
    
   
    
    
end
dskfjasfjklsdf
system(strcat("g: && ffmpeg -r 60 -s 1920x1080 -i frame%05d.bmp -vcodec libx264  -vb 20M -pix_fmt yuv420p final", sprintf("%05d", vidCounter), ".mp4 -start_number 0"))
system("g: && del frame*.bmp")

myFiles = dir(fullfile('g:\\','final*.mp4')); %gets all wav files in struct
concatString = '';
for k = 1:length(myFiles)
    baseFileName = myFiles(k).name;
    concatString = strcat(concatString, '\nfile ''', baseFileName, '''');
end

fid = fopen('g:\\concat.txt','w');
fprintf(fid, concatString);
fclose(fid);

system('g: && ffmpeg -f concat -safe 0 -i concat.txt -c copy output.mp4');

system("g: && del concat.txt")
system("g: && del final*.mp4")



%xlim = [-0.748766713922161, ...
%        -0.748766707771757];
%ylim = [ 0.123640844894862,  0.123640851045266];
%ylim(2) = ylim(1) + (xlim(2)-xlim(1))/gridSizeX*gridSizeY;









