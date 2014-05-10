function [ out ] = get_baseball_stats( season_folder )

f_dir = dir(season_folder);

file_list = {};

for i = 1:length(f_dir)
    %is this a file?
    if f_dir(i).isdir == 0
        file_list{length(file_list) + 1} = [season_folder f_dir(i).name];
    end
end

%open file
pitchers = {};

%init the current pitcher cell, this keeps track of the current pitcher for
%each team
current_pitcher{1} = '';
current_pitcher{2} = '';

%this is how the stat structure gets init when a new batter is discovered
stat_init = struct('hr', 0, 'at_bats', 0, 'hits', 0, 'name', '', 'doubles',0, 'triples',0);

%initialize lists for pitchers and batters
pitcher_list = {};
batter_list = {};

%batter vs pitcher mtx
bvp_at_bats = [];
bvp_hits = [];

%init wait bar
h = waitbar(0,'Number of Team');

%loop through all team files
for i = 1:length(file_list)
    
    %turn the play by play file into a cell for each line 
    c = csv2cell(file_list{i},'fromfile');
    [N, ~] = size(c);
    
    %loop through all lines in the play by play cells
    for j = 1:N
        
        %type of information 
        type = c{j,1};
        
        %is this describing the start of a player
        if strcmp(type, 'start') || strcmp(type, 'sub')
            
            %is it the pitcher position?
            if str2num(c{j,6}) == 1
                
                %update current pitcher for reported team
                current_pitcher{str2num(c{j,4}) + 1} = c{j,2};
                
                %is this a new pitcher?
                if isempty(find(strcmp(pitcher_list, c{j,2})))
                    
                    %add pitcher to list
                    pitcher_list{length(pitcher_list) + 1} = c{j,2};
                    
                    %expand the batter vs pitcher matrix
                    bvp_at_bats = [bvp_at_bats zeros(size(bvp_at_bats,1), 1)];
                    bvp_hits = [bvp_hits zeros(size(bvp_hits,1), 1)];
                end
                
                %set the idx to map the current pitcher to pitcher list and
                %bvp matrix
                pitcher_idx(str2num(c{j,4}) + 1) = find(strcmp(pitcher_list, c{j,2}));
            end
            
        %is this a play?
        elseif strcmp(type, 'play')
            %is this a new batter?
            if isempty(find(strcmp(batter_list, c{j,4})))
                %add them to the batter list
                batter_list{length(batter_list) + 1} = c{j,4};
                
                %expand the batter vs pitcher matrix 
                bvp_at_bats = [bvp_at_bats; zeros(1,size(bvp_at_bats,2))];
                bvp_hits = [bvp_hits; zeros(1,size(bvp_hits,2))];
                
                %set the batter stats to the stats init structure, and then
                %set the batter id
                stats{length(batter_list)} = stat_init;
                stats{length(batter_list)}.name = c{j,4};
            end
            
            %set the batter index to map to the batter list and bvp matrix
            batter_idx = find(strcmp(batter_list, c{j,4}));
            
            %modify the stats by analyzing the play 
            [stats{batter_idx}, hit, ab] = play_analysis(c{j,7}, stats{batter_idx});
            
            %Did this count as an at bat?
            if ab
                %add the at bat to the batter vs pitcher matrices 
                if c{j,3} == '1'
                    p_idx = pitcher_idx(1);
                else
                    p_idx = pitcher_idx(2);
                end
                bvp_at_bats(batter_idx, p_idx) = bvp_at_bats(batter_idx, p_idx) + 1;
                
                %was it a hit?
                if hit
                    bvp_hits(batter_idx, p_idx) = bvp_hits(batter_idx, p_idx) + 1;
                end
            end
        end
    end
    perc = i/length(file_list);
    waitbar(perc,h,sprintf('%f%% along...',perc*100));
    
end

%close the waitbar
close(h);

out.stats = stats;
out.bvp_hits = bvp_hits;
out.bvp_at_bats = bvp_at_bats;
out.batter_list = batter_list;
out.pitcher_list = pitcher_list;

end

