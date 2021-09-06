# Advanced-Image-Segmentation-Techniques-for-Ambiguous-Foreground-Images

## Introduction

In this paper, we propose a super-pixel-based image segmentation method that utilize color, edge, texture and saliency information as feature to merge super-pixels.
We can divide our method into two stages. One is super-pixel growing and the other is adaptive region merging.

First stage, we use Mean Shift[1] to generate the initial super-pixels, and then with the similarity measure by Lab color histogram, we use such constraint to determine whether to merge two adjacent super-pixels. Besides, we use dTex and ContourRate as threshold to reinforce the constraint to prevent over-merging.

Following, a foreground significance estimation is applied to determine whether the edge/texture enhancement should be used or not.

Second stage, we consider the information from the whole image instead of local regions and its adjacent regions. Therefore, we construct an N-by-N dissimilarity matrix for the images with N regions and merge regions according to the dissimilarity matrix.

Different numbers of regions need different criterion to decide whether merge or not. Therefore, we set three ways of calculating dissimilarity based on color, texture, edge and super-pixel size. More on that, we use adaptive threshold with ContactRate and dSV.

Every step, we only merge the closest two regions by dissimilarity matrix and then update the dissimilarity matrix. This process will not stop until there is no merging or the number of regions is equal to user’s setting.

In this paper, we proposed a novel super-pixel-based image segmentation that consider a variety of features like edge/contour, texture, color. Instead of using local features directly, we proposed different kind of similarity measure that can greatly illustrate the relation between two adjacent super-pixels. Furthermore, the input of this method can be any scales and doesn’t need additional parameter. This convenience make this method easy to be applied in any case.


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
