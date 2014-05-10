close all 
clear all

%get stats for a season 
resuls = get_baseball_stats('C:\Users\Steve\Documents\MATLAB\baseball\2013eve\PBP\');
bvp_at_bats = resuls.bvp_at_bats;
bvp_hits = resuls.bvp_hits;

batter_list = resuls.batter_list;
pitcher_list = resuls.pitcher_list;

%% Get rid of less frequent batter and pitchers

%get total at bats for every player
at_bats = sum(bvp_at_bats')';

%get rid of batters below a thresh of at bats
AT_BAT_MIN = 300;
batters_above_thresh_idx = find(at_bats >= AT_BAT_MIN);

%remove batters from matrices
bvp_at_bats_reduced = bvp_at_bats(batters_above_thresh_idx,:);
bvp_hits_reduced = bvp_hits(batters_above_thresh_idx,:);
batter_list_reduced = batter_list(batters_above_thresh_idx);

%get total pitcher vs batters
batters_faced = sum(bvp_at_bats_reduced)';

%get rid of batters below a thresh of at bats
BATTERS_FACED_MIN = 40;
pitchers_above_thresh_idx = find(batters_faced >= BATTERS_FACED_MIN);

%remove pitchers from matrices
bvp_at_bats_reduced = bvp_at_bats_reduced(:,pitchers_above_thresh_idx);
bvp_hits_reduced = bvp_hits_reduced(:,pitchers_above_thresh_idx);
pitcher_list_reduced = pitcher_list(pitchers_above_thresh_idx);

%% Rank batters and pitchers
% batter_a_score = (hits_vs_pitcher_x*pitcher_x_score + hits_vs_pitcher_y*pitcher_y_score ...)/total_at_bats
% pitcher_a_score = sum(put_outs_vs_batter_x*batter_x_score + put_outs_vs_batter_y*batter_y_score)/total_batters_faced

%get total at bats for each batter (only vs eligable pitchers)
at_bats = sum(bvp_at_bats_reduced')';

%create the hits matrix
B_HITS = bvp_hits_reduced;

%create the put out matrix
P_POUTS = (bvp_at_bats_reduced - bvp_hits_reduced)';

%get the total batters faced (vs only eligable batter)
batters_faced = sum(bvp_at_bats_reduced)';


%Init the pitcher scores evenly
p_score = ones(size(P_POUTS,1),1);
p_score = p_score/norm(p_score);

%init the batter scores evenly 
b_score = ones(size(B_HITS,1),1);
b_score = b_score/norm(b_score);

p_last = p_score;
b_last = b_score;

p_error = [];
b_error = [];

for i = 1:100
    %update batter score and normalize
    b_score =  (B_HITS*p_score)./at_bats;
    b_score = b_score/norm(b_score);
    b_error = [b_error sum(abs(b_score - b_last))];
    
    %update pitcher score and normalize
    p_score =  (P_POUTS*b_score)./batters_faced;
    p_score = p_score/norm(p_score);
    p_error = [p_error sum(abs(p_score - p_last))];
    
    
    p_last = p_score;
    b_last = b_score;
end

[x, I] = sort(b_score);
 bat = batter_list_reduced(I);

[x, I] = sort(p_score);
 pitch = pitcher_list_reduced(I);
 
 %Caculate by taking the first eigen vector 
 
 H_NORM = diag(1./sum(bvp_at_bats_reduced'));
 P_NORM = diag(1./sum(bvp_at_bats_reduced));
 
 page_mtx = [zeros(size(H_NORM)), H_NORM*B_HITS; P_NORM*P_POUTS, zeros(size(P_NORM))];
 
 [e_vect, ~] = eig(page_mtx);
 
 
b_score_eig = e_vect(:,1:length(b_score))/norm(e_vect(:,1:length(b_score)));

p_score_eig = e_vect(:,length(b_score)+1:end)/norm(e_vect(:,length(b_score)+1:end));
 



