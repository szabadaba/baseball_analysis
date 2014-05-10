close all 
clear all

%get stats for a season 
resuls = get_baseball_stats('C:\Users\Steve\Documents\MATLAB\baseball\2001eve\PBP\');
bvp_at_bats = resuls.bvp_at_bats;
bvp_hits = resuls.bvp_hits;

batter_list = resuls.batter_list;
pitcher_list = resuls.pitcher_list;

AT_BATS_NEEDED_FOR_RATING = 3;
R = bvp_at_bats > AT_BATS_NEEDED_FOR_RATING;

%remove rows with no information 
remove_rows = find(sum(R') < 5);
bvp_at_bats(remove_rows, :) = [];
bvp_hits(remove_rows, :) = [];
R(remove_rows, :) = [];
batter_list(remove_rows) = [];

%remove columns with no rows
remove_cols = find(sum(R) < 5);
bvp_at_bats(:,remove_cols) = [];
bvp_hits(:,remove_cols) = [];
R(:,remove_cols) = [];
pitcher_list(remove_cols) = [];





Y = zeros(size(R));
Y(R == 1) = bvp_hits(R == 1)./bvp_at_bats(R == 1);

%Normalize rating 
[Ynorm, Ymean] = normalizeRatings(Y, R);


%  Useful Values
num_users = size(Y, 2);
num_movies = size(Y, 1);
num_features = 5;


% Set Initial Parameters (Theta, X)
X = randn(num_movies, num_features);
Theta = randn(num_users, num_features);

initial_parameters = [X(:); Theta(:)];


% Set options for fmincg
% options = optimset('GradObj', 'on', 'MaxIter', 100);
options = optimset('MaxIter', 1000);


% Set Regularization
lambda = .5;
theta = fmincg (@(t)(cofiCostFunc(t, Y, R, num_users, num_movies, ...
                                num_features, lambda)), ...
                initial_parameters, options);

% Unfold the returned theta back into U and W
X = reshape(theta(1:num_movies*num_features), num_movies, num_features);
Theta = reshape(theta(num_movies*num_features+1:end), ...
                num_users, num_features);
            
p = X * Theta';


total_cov = cov(X);
%get eigen values and vectors
[U, S, ~] = svd(total_cov);

DIM = X*U(:,1:3);

scatter3(DIM(:,1),DIM(:,2), DIM(:,3)); 

%find closest batters to ichiro 
i_idx = find(strcmp(batter_list, 'walkl001'));

i_X = X(i_idx, :);

for i = 1:size(X,1)
    i_diff(i) = norm(i_X - X(i,:));
end

figure;
plot(i_diff);

