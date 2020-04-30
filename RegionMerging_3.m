function  [segments,Rnum]=RegionMerging_3(Nseg,R0,img,LabIm,edge_map,FinalEdge,complex_map,textureImg,SaliencyMap,FCD)   
%% STAGE 1
    disp('=== STAGE 1 ===') ;
    L_bins=32 ; A_bins=32 ; B_bins=32 ;
    totalBins = L_bins * A_bins * B_bins ;
    quanImg = quantizeImg(LabIm, L_bins, A_bins, B_bins) ; % quantize color channel of Lab space with larger a&b weight
    %imagesc(quanImg) ;
    [area, LabHist] = get_Region_Initial_Info(R0, quanImg, totalBins) ; % region's quantImg histogram
    meanLGTex = getMeanTex(R0, textureImg) ; % mean of each texture in each region
    [LongContourMap40, ~] = GetLongContour(img, 40, 0.1, edge_map) ; % binary edge_map with edge length > 40
    LongContourMap40 = imdilate(LongContourMap40, strel('disk', 1)) ; 
    
    count=0 ; countTh=25 ;
    while count< countTh
        count = count + 1 ;
        [R1, area, LabHist, meanLGTex] = Merge_byHist(R0, LongContourMap40, textureImg, meanLGTex, area, LabHist) ;
        if isequal(R1, R0)
            break ;
        else
            R0 = R1 ;
        end
    end
    
    R1 = RenewLabel(R1) ;
    %figure; showSegment(img, R1);
    %[~,~,outputR1]=segoutput(img, R1);
    %figure, imshow(uint8(outputR1)); title(['merge01_',num2str(max(R1(:)))]);
    %imwrite(uint8(outputR1),[save_path,'merging01_',num2str(max(R1(:))),'.bmp'],'BMP');
    %[ output ] = display_mean( R1,img ); % Mean color 
    %[~,~,MeanImMarkup]=segoutput(output,R1);
    %imwrite(uint8(MeanImMarkup),[save_path,'merging01.bmp'],'BMP');
    
%% initial seeds growing
    disp('=== start Initial Seeds Growing ===') ;
    A_bins=32 ; B_bins=32 ; 
    totalBins = A_bins * B_bins ;
    quanABImg = quantizeImg_v2(LabIm, A_bins, B_bins) ;
    [area, LabHist] = get_Region_Initial_Info_v2(R1, quanABImg, totalBins) ;
    meanCC = getMeanLab(LabIm, R1) ;
    meanLGTex = getMeanTex(R1, textureImg) ;
    [LongContourMap80, ~] = GetLongContour(img, 80, 0.1, edge_map) ;
    LongContourMap80 = imdilate(LongContourMap80, strel('disk',1)) ;
    [RMT] = get_region_merge_times(R1, FCD) ; % for each superpixel, record it has merged how many times
    IsSeed = (RMT >= 3) ; % binary list for superpixel which has merged over 3 times
    
    count=0 ; countTh=10 ;
    while count < countTh
        count = count+1 ;
        [R2, IsSeed, meanCC, meanLGTex, LabHist, area] = GrowSeeds(R1, LabHist, area, textureImg, LabIm, ...
                                                                   FinalEdge, complex_map, IsSeed, meanCC, meanLGTex, LongContourMap80) ;
        if isequal(R2, R1)
            break ;
        else
            R1 = R2 ;
        end
    end

    R2 = RenewLabel(R2) ;  
    %figure; showSegment(img,R2);
    %[~,~,outputR2]=segoutput(img,R2);
    %figure, imshow(uint8(outputR2)); title('seeds growing');
    %imwrite(uint8(outputR2),[save_path,'merging02_',num2str(max(R2(:))),'.bmp'],'BMP');    
    %[ output ] = display_mean( R2,img ); % Mean color 
    %[~,~,MeanImMarkup]=segoutput(output,R2);
    %imwrite(uint8(MeanImMarkup),[save_path,'merging02.bmp'],'BMP');
    
    %%% Grow targetL according to the Hist (similar to Merge_byHist.m)
    if max(R2(:))>=260
        L_bins=16 ; A_bins=32 ; B_bins=32 ; 
        totalBins = L_bins * A_bins * B_bins ;
        quanImg = quantizeImg(LabIm, L_bins, A_bins, B_bins) ;
        [area, LabHist] = get_Region_Initial_Info(R2, quanImg, totalBins) ;
        meanLGTex = getMeanTex(R2, textureImg) ;
        [LongContourMap25, ~] = GetLongContour(img, 25, 0.1, edge_map) ;
        contour = LongContourMap40 | LongContourMap25 ;
        [RMT] = get_region_merge_times(R2, FCD) ;
        targetL = find(RMT<=2) ;
        
        R3 = Merge02(R2, targetL, contour, meanLGTex, LabHist, area) ;       
        R3 = RenewLabel(R3) ;
        %[~,~,outputR3]=segoutput(img,R3);
        %figure, imshow(uint8(outputR3)); title(['merge03_',num2str(Rnum)]);
        %imwrite(uint8(outputR3),[save_path,'merging03_',num2str(max(R3(:))),'.bmp'],'BMP');  
    else
        R3 = R2 ;
    end
    %figure; showSegment(img,R2);
%% Adaptive Region Merging
    disp('=== start Adaptive Region Merging ===') ;
    segments = RenewLabel(R3) ;
    
    Rnum = max(segments(:)) ;
    L_bins = 16 ; A_bins=32 ; B_bins=32 ;
    LabBins = L_bins * A_bins * B_bins ;
    abBins = A_bins * B_bins ;
    quanImg = quantizeImg(LabIm, L_bins, A_bins, B_bins) ;
    quanABImg = quantizeImg_v2(LabIm, A_bins, B_bins) ;
    [LongContourMap25, ~] = GetLongContour(img, 25, 0.1, edge_map) ;
    [LongContourMap30, ~] = GetLongContour(img, 30, 0.15, edge_map) ;
    LongContourMap30 = imdilate(LongContourMap30, strel('disk', 1)) ;
    adj = FindNeighbor(segments) ;
    [DTex, meanLGTex] = getDiffTexture(textureImg, segments) ;
    meanCC = getMeanLab(LabIm, segments) ;
    
    score1=[]; score2=[]; score3=[]; score4=[]; score5=[]; score6=[]; score7=[]; meanSaliency=[];
    Rlast = Rnum ;
    
    while (Rnum>Nseg)
        if Rnum>=100
            if isempty(score1)
                [Hist, HistDiff, area, Edge] = GetScoreData00(segments, LongContourMap25, LongContourMap80, edge_map, adj, quanImg, LabBins) ;
                score1 = getScore_v1(segments, HistDiff, area, Edge, DTex, adj) ;
            end
            [segments, score1, Hist, HistDiff, area, Edge, DTex, meanCC, meanLGTex, adj, Rnum] = FinalMerging_v1(segments, score1, Hist, ...
                                        HistDiff, area, Edge, DTex, LabIm, meanCC, textureImg, meanLGTex, adj, LongContourMap25, LongContourMap80, edge_map, Rnum, Nseg) ;
        elseif Rnum>=75
            clear score1
            if isempty(score2)
                [Hist, HistDiff, area, Edge] = GetScoreData00(segments, LongContourMap25, LongContourMap80, edge_map, adj, quanABImg, abBins) ;
                score2 = getScore_v2(segments, HistDiff, area, Edge, DTex, adj) ;
            end
            [segments, score2, Hist, HistDiff, area, Edge, DTex, meanCC, meanLGTex, adj, Rnum] = FinalMerging_v2(segments, score2, Hist, HistDiff, ...
                                area, Edge, DTex, LabIm, meanCC, textureImg, meanLGTex, adj, LongContourMap25, LongContourMap80, LongContourMap30, edge_map, Rnum, Nseg) ; 
        elseif Rnum>=44
            clear score2
            if isempty(score3)
                [Hist, HistDiff, area, Edge] = GetScoreData00(segments, LongContourMap25, LongContourMap30, edge_map, adj, quanABImg, abBins) ;
                score3 = getScore_v3(segments, HistDiff, area, Edge, DTex, meanCC, adj) ;
            end
            [segments, score3, Hist, HistDiff, area, Edge, DTex, meanCC, meanLGTex, adj, Rnum] = FinalMerging_v3(segments, score3, Hist, HistDiff, ...
                                area, Edge, DTex, LabIm, meanCC, textureImg, meanLGTex, adj, LongContourMap25, LongContourMap30, edge_map, Rnum, Nseg) ;
        elseif Rnum>=24
            clear  score3 
            if isempty(meanSaliency)
                meanSaliency = getMeanSV(SaliencyMap, segments) ;
            end
            if isempty(score4)
                [Hist, HistDiff, area, Edge] = GetScoreData00(segments, LongContourMap25, LongContourMap80, edge_map, adj, quanABImg, abBins) ;
                score4 = getScore_v4(segments, HistDiff, area, Edge, DTex, meanCC, adj) ;
            end
            [segments, score4, Hist, HistDiff, area, Edge, DTex, meanCC, meanLGTex, meanSaliency, adj,Rnum] = FinalMerging_v4(segments, score4, Hist, HistDiff, ...
                    area, Edge, DTex, LabIm, meanCC, textureImg, meanLGTex, SaliencyMap, meanSaliency, adj, LongContourMap25, LongContourMap80, edge_map, Rnum, Nseg) ;      
        elseif Rnum>15
            clear score4 
            if isempty(meanSaliency)
                meanSaliency = getMeanSV(SaliencyMap, segments) ;
            end
            if isempty(score5)
                [Hist,HistDiff,area,Edge]=GetScoreData00(segments,LongContourMap25,LongContourMap80,edge_map,adj,quanImg,LabBins);
                score5=getScore_v5(segments,HistDiff,area,Edge,DTex,meanCC,adj);
            end
            [segments,score5,Hist,HistDiff,area,Edge,DTex,meanCC,meanLGTex,meanSaliency,adj,Rnum]=FinalMerging_v5(segments,score5,Hist,HistDiff,area,Edge,DTex,LabIm,meanCC,textureImg,meanLGTex,SaliencyMap,meanSaliency,adj,LongContourMap25,LongContourMap80,edge_map,Rnum,Nseg);        
         elseif Rnum>9
            clear score5
            if isempty(meanSaliency)
                meanSaliency=getMeanSV(SaliencyMap,segments);
            end
            if isempty(score6)
                [Hist,HistDiff,area,Edge]=GetScoreData00(segments,LongContourMap25,LongContourMap80,edge_map,adj,quanABImg,abBins);
                score6=getScore_v6(segments,HistDiff,area,Edge,DTex,meanCC,adj);
            end
            [segments,score6,Hist,HistDiff,area,Edge,DTex,meanCC,meanLGTex,meanSaliency,adj,Rnum]=FinalMerging_v6(segments,score6,Hist,HistDiff,area,Edge,DTex,LabIm,meanCC,textureImg,meanLGTex,SaliencyMap,meanSaliency,adj,LongContourMap25,LongContourMap80,edge_map,Rnum,Nseg);     
        else
            clear score6
            if isempty(meanSaliency)
                meanSaliency=getMeanSV(SaliencyMap,segments);
            end
            if isempty(score7)
                [Hist,HistDiff,area,Edge]=GetScoreData00(segments,LongContourMap25,LongContourMap30,edge_map,adj,quanABImg,abBins);
                score7=getScore_v7(segments,HistDiff,Edge,DTex,adj);
            end
            [segments,score7,Hist,HistDiff,area,Edge,DTex,meanCC,meanLGTex,meanSaliency,adj,Rnum]=FinalMerging_v7(segments,score7,Hist,HistDiff,area,Edge,DTex,LabIm,meanCC,textureImg,meanLGTex,SaliencyMap,meanSaliency,adj,LongContourMap25,LongContourMap30,edge_map,Rnum,Nseg);
        end
        
        if Rnum == Rlast
            disp('fail to merge next.');
            break;
        else
            Rlast = Rnum;
        end
        
    end
    
    clear score1 score2 score3 score4 score5 score6 score7 meanSaliency
    segments = RenewLabel(segments) ;

end