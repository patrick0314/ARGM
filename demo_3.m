clear all ;
close all ;
clc ;

%%% add the fold path and its subfold path to this matlab path 
addpath(genpath('./')) ;
addpath(genpath('ExtractContour')) ;
addpath(genpath('Saliency_Optimization')) ;

%%% read numbers of segments used in the paper
fid = fopen(fullfile('results3', 'myNsegs.txt'), 'r') ; % read the file .\result3\myNsegs.txt
Nimgs = 150 ;
[IMG_INFO] = fscanf(fid, '%d %d \n', [2, Nimgs]) ; % IMG_INFO conclude image index and number of segmentation
fclose(fid) ;
clear fid ;

%%% Path for saving labels
result_mat_path = 'results3\Label_mat\' ;
if ~exist(result_mat_path, 'dir')
    mkdir(result_mat_path) ;
end

%%% list for adaptive Nsegs
fid_outout = fopen(fullfile('results3', 'Nseg.txt'), 'w') ;

for idx = 1:50
    disp(['=== start idx ', num2str(idx), ' ===']) ;
    %%% read image
    img_name = int2str(IMG_INFO(1, idx)) ;
    l = length(img_name) ;
    while l < 12
        img_name = ['0', img_name] ;
        l = length(img_name) ;
    end
    img_name = [img_name, '.jpg'] ;
    img_loc = fullfile('val2017', img_name) ;
    img = imread(img_loc) ;
    LabIm = applycform(img, makecform('srgb2lab')) ; % change the color space rgb to Lab
    disp(['Processing ', img_name]) ;
    
    %%% build the path for saving results 
    save_path = 'results3\' ;
  
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
    %Nseg = IMG_INFO(2, idx) ; % Read number of segments
    Nseg = 0 ;
    
    %%% Feature enhancement
    disp('=== start Feature Enhancement ===') ;
    SaliencyMap = getHDCSaliency(img) ; % HDCT saliency map
    E = useSketchToken(img) ; % return sketch token detection result
    R0dct = dctR0(LabIm(:, :, 1), R0) ; % return DCT texture strength
    R0gradHist = gradHistR0(LabIm(:, :, 1), R0) ; % return gradient histogram texture result
    featureAdjustment ; % check whether to enhance each map and if yes, update the map
    
    %%% Superpixel Growing and Adaptive Region Merging
    disp('=== start Superpixel Growing and Adaptive Region Merging ===') ;
    disp(['tmp_Nsegs: ', int2str(max(max(R0)))]) ;
    [segments, ~] = RegionMerging_2(Nseg, R0, img, LabIm, edge_map, FinalEdge, complex_map, textureImg, SaliencyMap, FCD) ;

    %%% save and show results
    disp('=== start Save and Show Results ===') ;
    show = 1 ;
    save = 1 ;
    save_all = 1 ;
    save_show_seg(segments, img, show, save, save_all, img_name, save_path, result_mat_path) ; % save and show the red boundary image and the mean color image
    clear LabIm R0 edge_map FinalEdge complex_map textureImg SaliencyMap FCD ;
    
    %%% print and save auto-segment Nsegs result
    Nseg = max(max(segments)) ;
    fprintf('%d  %6d:  %2d\r\n', idx, IMG_INFO(1, idx), Nseg);
    fprintf(fid_outout, '%d  %6d:  %2d\r\n', idx, IMG_INFO(1, idx), Nseg);

end

%%%
fclose(fid_outout) ;