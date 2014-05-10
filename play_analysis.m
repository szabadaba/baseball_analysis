function [stats, hit, ab] = play_analysis(play, stats)
hit = 0;
ab = 0;

if isempty(strfind(play, 'HR')) == 0
    stats.hits = stats.hits + 1;
    stats.at_bats = stats.at_bats + 1;
    stats.hr = stats.hr + 1;
    hit = 1;
    ab = 1;
elseif play(1) == 'K'
    stats.at_bats = stats.at_bats + 1;
    ab = 1;
elseif isempty(strfind(play, 'SB')) == 0 ...
    || isempty(strfind(play, 'CS')) == 0 ...
    || isempty(strfind(play, 'WP')) == 0 ...
    || isempty(strfind(play, 'PB')) == 0 ...
    || isempty(strfind(play, 'NP')) == 0 ...
    || isempty(strfind(play, 'DI')) == 0 ...
    || isempty(strfind(play, 'OA')) == 0 ...
    || isempty(strfind(play, 'BK')) == 0 ...
    || isempty(strfind(play, 'PO')) == 0

    %Stolen base, Caught steeling, or Pitch out
elseif isempty(strfind(play, 'SF')) == 0 ...
    || isempty(strfind(play, 'SH')) == 0 
    %Sacrifice fly or hit
elseif isempty(strfind(play, 'IW')) == 0 ...
    || isempty(strfind(play, 'HP')) == 0 
elseif play(1) == 'W'
%     stats.hits = stats.hits + 1;
%     stats.at_bats = stats.at_bats + 1;
elseif play(1) == 'S'
    stats.hits = stats.hits + 1;
    stats.at_bats = stats.at_bats + 1;
    ab = 1;
    hit = 1;
elseif play(1) == 'D'
    stats.hits = stats.hits + 1;
    stats.at_bats = stats.at_bats + 1;
    stats.doubles = stats.doubles + 1;
    ab = 1;
    hit = 1;
elseif play(1) == 'T'
    stats.hits = stats.hits + 1;
    stats.at_bats = stats.at_bats + 1;
    stats.triples = stats.triples + 1;
    ab = 1;
    hit = 1;
else
    stats.at_bats = stats.at_bats + 1;
    ab = 1;
end
% 
% if strcmp(stats.name, 'suzui001')
%    test = 1; 
% end

end