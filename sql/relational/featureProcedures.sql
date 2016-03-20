delimiter //

drop procedure if exists aggregateHomeTeamWinRate//
drop procedure if exists aggregateAwayTeamWinRate//
drop procedure if exists aggregateOverallTeamWinRate//
drop procedure if exists aggregateWinRateAgainstTeam//
drop procedure if exists aggregateHomeTurnoverRate//
drop procedure if exists aggregateAwayTurnoverRate//
drop procedure if exists aggregateOverallTurnoverRate//
drop procedure if exists homeScoringEfficiency//

/*Aggregates the home win rate (using the last 8 samples) of a team for a given game*/
create procedure aggregateHomeTeamWinRate(in teamID int, in gameID int, in numGames int, out winRate float)
begin
	select (count(*) / numGames) as home_win_rate from (select * from game 
		where home_team_id = teamID
        and game_id <= gameID
        order by game_eid desc
        limit numGames) as lastSeasonHomeGames
	where home_score_final > away_score_final
    into winRate;
end //

/*Aggregates the away win rate (using the last 8 samples) of a team for a given game*/
create procedure aggregateAwayTeamWinRate(in teamID int, in gameID int, in numGames int, out winRate float)
begin
	select (count(*) / numGames) from (select * from game 
		where away_team_id = teamID
        and game_id <= gameID
        order by game_eid desc
        limit numGames) as lastSeasonAwayGames
	where away_score_final > home_score_final
    into winRate;
end //

create procedure aggregateOverallTeamWinRate(in teamID int, in gameID int, in numGames int)
begin
	call aggregateHomeTeamWinRate(teamID, gameID, numGames / 2, @homeWinRate);
    call aggregateAwayTeamWinRate(teamID, gameID, numGames / 2, @awayWinRate);
    
    select (@homeWinRate + @awayWinRate) / 2;
end //

create procedure aggregateWinRateAgainstTeam(in homeTeam int, in awayTeam int, in gameID int,
	out homeTeamWinRate float, out awayTeamWinRate float)
begin
	declare numGamesBetweenTeams int;

	select count(*) from game where game_id <= gameID
    and home_team_id = homeTeam and away_team_id = awayTeam
    and home_score_final != away_score_final
    into numGamesBetweenTeams;
            
	select (count(*) / numGamesBetweenTeams) from game where game_id <= gameID
    and home_team_id = homeTeam and away_team_id = awayTeam
    and home_score_final > away_score_final
    order by game_eid desc
    into homeTeamWinRate;
    
    select (count(*) / numGamesBetweenTeams) from game where game_id <= gameID
    and home_team_id = homeTeam and away_team_id = awayTeam
    and away_score_final > home_score_final
    order by game_eid desc
    into awayTeamWinRate;
end //

create procedure aggregateHomeTurnoverRate(in teamID int, in gameID int,
	in numGames int, out turnoverRate float)
begin
	select sum(home_turnovers) / count(*) from (select * from game
		where home_team_id = teamID
        and game_id <= gameID 
        order by game_id desc
        limit numGames) as lastHomeGames
	into turnoverRate;
end //

create procedure aggregateAwayTurnoverRate(in teamID int, in gameID int,
	in numGames int, out turnoverRate float)
begin
	select sum(away_turnovers) / count(*) from (select * from game
		where away_team_id = teamID
        and game_id <= gameID 
        order by game_id desc
        limit numGames) as lastAwayGames
	into turnoverRate;
end //

create procedure aggregateOverallTurnoverRate(in teamID int, in gameID int,
	in numGames int, out turnoverRate float)
begin
	call aggregateHomeTurnoverRate(teamID, gameID, numGames / 2, @homeTurnoverRate);
    call aggregateAwayTurnoverRate(teamID, gameID, numGames / 2, @awayTurnoverRate);
    
    select (@homeTurnoverRate + @awayTurnoverRate) / 2
    into turnoverRate;
end //

create procedure homeScoringEfficiency(in teamID int, in gameID int,
	in numGames int)
begin
    
	select 1 - (lastHomeGames.home_turnovers + lastHomeGames.home_total_punts) / count(d.game_id)
		as scoring_efficiency
    from (select * from game
		where home_team_id = teamID
		and game_id <= gameID
		order by game_id desc
		limit numGames) as lastHomeGames
	left join drive d on lastHomeGames.game_id = d.game_id
    where d.team_id = teamID
    group by lastHomeGames.game_id
    order by lastHomeGames.game_id desc;    
end //

delimiter ;

call homeScoringEfficiency(20, 1792, 8);

-- call aggregateOverallTurnoverRate(13, 1512, 16, @otr);
-- select @otr;
-- 
-- call aggregateHomeTurnoverRate(1, 1792, 8, @htr);
-- select @htr;
-- call aggregateAwayTurnoverRate(1, 1792, 8, @atr);
-- select @atr;
-- 
-- call aggregateWinRateAgainstTeam(30, 32, 1792, @htwr, @atwr);
-- select @htwr as home_team_wr_against_away;
-- select @atwr as away_team_wr_against_home;
-- 
-- call aggregateHomeTeamWinRate(3, 1792, 8, @hwr);
-- select @hwr as home_win_rate;
-- call aggregateAwayTeamWinRate(3, 1792, 8, @awr);
-- select @awr as away_win_rate;
-- call aggregateOverallTeamWinRate(3, 1792, 16);