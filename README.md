# Advanced-Image-Segmentation-Techniques-for-Ambiguous-Foreground-Images

## Introduction

Our proposed algorithm is a superpixel-based image segmentation. The main goal is to segment an input image into several regions with much likely meanings under human perspective. Besides, we provide two methods. One is given the number of final segmentation regions seg by the user, and another is automatically detected by the program.

In our algorithm, the input image will be first performed with Mean Shift superpixel generation. Then, the basic features such as color, edge and texture information will be constructed. Meanwhile, we measuer the foreground significance to estimate the image condition and determine whether to perform edge/texture enhancement or not. After that, superpixels will grow according to the color, edge and texture information. Finally, the grown superpixels will be further merged by the calculation of dissimilarity between superpixels which is adaptive to the number of remain regions. 

The block diagram of our algorithm and the overview of our algorithm are shown below.

![](https://i.imgur.com/3JrSwbD.png)

![](https://i.imgur.com/xgaBq0E.png)

## Demo

There are two distinct datasets: BSDS300 and val2017.

* [demo.m](https://github.com/patrick0314/Image-Segmentation/blob/master/demo.m) : The example of BSDS300 image segmentation with number of final segmentation regions.
* [demo_1.m](https://github.com/patrick0314/Image-Segmentation/blob/master/demo_1.m) : The example of val2017 image segmentation with number of final segmentation regions.
* [demo_2.m](https://github.com/patrick0314/Image-Segmentation/blob/master/demo_2.m) : The example of BSDS300 image segmentation without number of final segmentation regions.
* [demo_3.m](https://github.com/patrick0314/Image-Segmentation/blob/master/demo_3.m) : The example of val2017 image segmentation without number of final segmentation regions.

And results, results1, results2 and result3 are the final image segmentation results corresponding to demo files respectively.

There are some parameters can be modified in the code.

* the save path

```matlab
save_path = 
```

* save image repectively or save all in a folder

```matlab
save = 
save_all = 
```

* some evaluation of the results corresponding to the ground truth

```matlab
gt_
```


## Usage

###### tags: `github`
