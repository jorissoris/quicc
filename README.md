# quicc

**Q**uick **U**ncomplicated **I**ntegral **C**urve **C**reator - Create 60fps 4K deep zooms of fractals in faster-than-realtime with CUDA and compute capability >= 3. Supports up to Real64 coordinate accuracy.

The uncomplicated part is currently a work in progress.

Requirements:
1. CUDA (with compute capability >= 3) capable GPU
2. NVCC in path (requires an NVIDIA developer account)
3. cl.exe in path (requires visual studio)
4. ffmpeg in path (download from `https://www.ffmpeg.org/`)
5. A >= 4GB ramdisk mounted on `g:` greatly increases the performance of the script. Using this on an SSD is not recommended as it may decrease the lifetime of the SSD. A typical render writes up to ~a terabyte of data in a few minutes.

Build steps:
1. Clone the repo with `git clone https://github.com/jorissoris/quicc.git`
2. Program the desired curve in the kernel, the default is the mandelbrot set with the default power of 2.
3. Compile the .cu file to .ptx with `nvcc --ptx pctdemo_processMandelbrotElement2.cu`
4. Configure the .m file as desired.
5. Mount the ramdisk
6. Run the .m file
7. Wait a few minutes
8. Collect the `output.mp4` on the ramdisk
