function [break_while] = criterion_v2(Rnum, score, segments, LongContourMap30, meanSaliency)
%%% simplified code of criterion
% Output:
%    break_while: (boolean) judge whether the final_merge loop breaks
%               true: break
%               false: continue
    break_while = false ;
    % score means the difference between two region
    threshold_v2 = 5 ;
    threshold_v3 = 5 ;
    threshold_v4_1 = -1.2 ;
    threshold_v4_2 = -0.77 ;
    threshold_v5 = -0.6 ;
    threshold_v6 = -0.7 ;
    threshold_v7 = -0.1 ;
    if Rnum == 98 || Rnum == 73 || Rnum == 42 || Rnum == 22 || Rnum == 13 || Rnum == 7
        disp(['======== ', int2str(Rnum), ' ========']) ;
    end
    
    [val, loc] = sort(score(:)) ;
    loc = loc(~isinf(val)) ;
    l_border = get_L_Border(segments) ;
    for order = 1:length(loc)
        [l1, l2] = ind2sub(size(score), loc(order)) ;
        adjBorder = get_Adj_Border(l_border, l1, l2) ;
        BndInd = find(adjBorder) ;
        l1_border_length = length(find(l_border==l1)) ;
        l2_border_length = length(find(l_border==l2)) ;
        contact_rate = length(BndInd)*0.5 / min(l1_border_length, l2_border_length) ;
        EdgeRate30 = sum(LongContourMap30(BndInd)) / length(BndInd) ;
        dSV = abs(meanSaliency(l1) - meanSaliency(l2)) ;
        % Rnum >= 98 && Rnum < 120: contact_rate >= 0.05 && Edge(L1,L2).Rate80 <= 0.6 && dSV <= 0.2
        if Rnum >= 74
            if contact_rate >= 0.05 && EdgeRate30 <= 0.6 && dSV <= 0.25
                %disp(score(l1, l2)) ;
                if score(l1, l2) > threshold_v2
                    break_while = true ;
                end
                break ;
            end
        elseif Rnum >= 43
            if contact_rate >= 0.06 && dSV <= 0.3
                %disp(score(l1, l2)) ;
                if score(l1, l2) > threshold_v3
                    break_while = true ;
                end
                break ;
            end
        elseif Rnum >= 23
            if contact_rate >= 0.04 && dSV <= 0.125
                %disp(score(l1, l2)) ;
                if score(l1, l2) > threshold_v4_1
                    break_while = true ;
                end
                break ;
            elseif contact_rate >= 0.06 && dSV <= 0.4 && dSV > 0.125
                %disp(score(l1, l2)) ;
                if score(l1, l2) > threshold_v4_2
                    break_while = true ;
                end
                break ;
            end
        elseif Rnum >= 14
            if contact_rate >= 0.05 && dSV <= 0.4
                %disp(score(l1, l2)) ;
                if score(l1, l2) > threshold_v5
                    break_while = true ;
                end
                break ;
            end
        elseif Rnum >= 8
            if Rnum > 11
                SVTh = 0.4 ;
            else
                SVTh = 0.5 ; 
            end
            if contact_rate >= 0.044 && dSV <= SVTh
                %disp(score(l1, l2)) ;
                if score(l1, l2) > threshold_v6
                    break_while = true ;
                end
                break ;
            end
        else
            if Rnum <= 5
                SVTh = 1 ;
            else
                SVTh = 0.6 ;
            end
            if dSV <= SVTh
                %disp(score(l1, l2)) ;
                if score(l1, l2) > threshold_v7
                    break_while = true ;
                end
                break ;
            end
        end
    end
    
end