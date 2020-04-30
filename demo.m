clear all ;
close all ;
clc ;

%%% add the fold path and its subfold path to this matlab path 
addpath(genpath('./')) ;
addpath(genpath('ExtractContour')) ;
addpath(genpath('Saliency_Optimization')) ;

%%% read numbers of segments used in the paper
fid = fopen(fullfile('results', 'myNsegs.txt'), 'r') ; % read the file .\results\BSDS300\myNsegs.txt
Nimgs = 300 ; % number of images in BSDS300
[BSDS_INFO] = fscanf(fid, '%d %d \n', [2, Nimgs]) ; % BSDS_INFO conclude image index and number of segmentation
fclose(fid) ;
clear fid ;

%%% Path for saving labels
result_mat_path = 'results\Label_mat\' ;
if ~exist(result_mat_path, 'dir')
    mkdir(result_mat_path) ;
end

%%% lists to save each evaluation and file to save all evaluation
PRI_all = zeros(Nimgs, 1) ;
VoI_all = zeros(Nimgs, 1) ;
GCE_all = zeros(Nimgs, 1) ;
BDE_all = zeros(Nimgs, 1) ;
fid_out = fopen(fullfile('results', 'Evaluations.txt'), 'w') ;

for idx = 1:20
    disp(['=== start idx ', num2str(idx), ' ===']) ;
    %%% read image
    img_name = int2str(BSDS_INFO(1, idx)) ;
    img_loc = fullfile('BSDS300', 'images', 'test', [img_name, '.jpg']) ;    
    if ~exist(img_loc, 'file')
        img_loc = fullfile('BSDS300', 'images', 'train', [img_name, '.jpg']) ;
    end
    img = imread(img_loc) ;
    LabIm = applycform(img, makecform('srgb2lab')) ; % change the color space rgb to Lab 
    disp(['Processing ', img_name]) ;
    
    %%% build the path for saving results 
    save_path = 'results\' ;
  
    %%% Basic Image Feature Construction
    disp('=== start Basic Image Feature Construction ===') ;
    para.hs = 5; para.hr = 7; para.M = 100 ;
    [S, initial_seg] = msseg(double(img), para.hs, para.hr, para.M) ; % [S, L]: S for segmented image and L for resulting label map
    R0 = double(initial_seg) ; % label map by MeanShift superpixel
    clear initial_seg ;
    SaliencyMapOld = getSaliencyMap(img) ;
    [edge_map, FinalEdge, complex_map, textureImg] = GetBasicInfo(img) ; % edge_map by structed edge detection, FinalEdge by gradientmap + edge_map, textureImg for the normalized texture map
    R0 = R0post(R0, img, edge_map) ; % check whether to post-process, and return img after superpixel post-processing
    [FCD] = Record_First_Coordinate(R0) ; % FCD: the index of first pixel within every super-pixel
    Nseg = BSDS_INFO(2, idx) ; % Read number of segments
    
    %%% Feature enhancement
    disp('=== start Feature Enhancement ===') ;
    SaliencyMap = getHDCSaliency(img) ; % HDCT saliency map
    E = useSketchToken(img) ; % return sketch token detection result
    R0dct = dctR0(LabIm(:, :, 1), R0) ; % return DCT texture strength
    R0gradHist = gradHistR0(LabIm(:, :, 1), R0) ; % return gradient histogram texture result
    featureAdjustment ; % check whether to enhance each map and if yes, update the map
    
    %%% Superpixel Growing and Adaptive Region Merging
    disp('=== start Superpixel Growing and Adaptive Region Merging ===') ;
    [segments, ~] = RegionMerging(Nseg, R0, img, LabIm, edge_map, FinalEdge, complex_map, textureImg, SaliencyMap, FCD) ;
    
    %%% save and show results
    disp('=== start Save and Show Results ===') ;
    show = 0 ;
    save = 0 ;
    save_all = 1 ;
    save_show_seg(segments, img, show, save, save_all, img_name, save_path, result_mat_path) ; % save and show the red boundary image and the mean color image
    clear LabIm R0 edge_map FinalEdge complex_map textureImg SaliencyMap FCD ;
    
    %%% evaluate segmentation
    [gt_imgs, ~] = view_gt_segmentation(img, BSDS_INFO(1, idx), save_path, img_name, 1) ;
    clear img ;
    out_vals = eval_segmentation(segments, gt_imgs) ; % ./Evals/eval_segmentaion.m, return all criterions for image segmentation
    clear gt_imgs ;
    fprintf('%6s: %2d %9.6f, %9.6f, %9.6f, %9.6f \n', img_name, Nseg, out_vals.PRI, out_vals.VoI, out_vals.GCE, out_vals.BDE) ;
    
    PRI_all(idx) = out_vals.PRI ;
    VoI_all(idx) = out_vals.VoI ;
    GCE_all(idx) = out_vals.GCE ;
    BDE_all(idx) = out_vals.BDE ;
    fprintf(fid_out, '%6d %9.6f, %9.6f, %9.6f, %9.6f \r\n', BSDS_INFO(1, idx), PRI_all(idx), VoI_all(idx), GCE_all(idx), BDE_all(idx));
   
end

%%% write the evaluation into Evaluations.txt
fprintf('Mean: %14.6f, %9.6f, %9.6f, %9.6f \n', mean(PRI_all), mean(VoI_all), mean(GCE_all), mean(BDE_all)) ;
fprintf(fid_out,'Mean: %10.6f, %9.6f, %9.6f, %9.6f \r\n', mean(PRI_all), mean(VoI_all), mean(GCE_all), mean(BDE_all)) ;
fclose(fid_out);